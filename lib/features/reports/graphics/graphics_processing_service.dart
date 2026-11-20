import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class GraphicsProcessingService {
  const GraphicsProcessingService();

  Future<GraphicsProcessingResult> process(File originalScan) async {
    if (!await originalScan.exists()) {
      throw const GraphicsProcessingException(
        'The scanned image does not exist.',
      );
    }

    final Uint8List inputBytes;
    try {
      inputBytes = await originalScan.readAsBytes();
    } on FileSystemException catch (error) {
      throw GraphicsProcessingException(
        'Could not read the scanned image: ${error.message}',
      );
    }

    final original = _decode(inputBytes);
    if (original.width == 0 || original.height == 0) {
      throw const GraphicsProcessingException(
        'The scanned image has invalid dimensions.',
      );
    }

    final qualityBefore = _measure(original);
    final enhanced = _enhance(original, qualityBefore);
    final threshold = _adaptiveThreshold(enhanced);
    final enhancedBytes = img.encodeJpg(enhanced, quality: 92);
    final thresholdBytes = img.encodeJpg(threshold, quality: 95);
    final qualityAfter = _measure(_decode(enhancedBytes));

    final processedDirectory = Directory(
      _joinPath(originalScan.parent.path, 'processed'),
    );
    final enhancedFile = File(
      _joinPath(processedDirectory.path, 'enhanced.jpg'),
    );
    final thresholdFile = File(
      _joinPath(processedDirectory.path, 'threshold.jpg'),
    );
    if (_normalizedPath(originalScan) == _normalizedPath(enhancedFile) ||
        _normalizedPath(originalScan) == _normalizedPath(thresholdFile)) {
      throw const GraphicsProcessingException(
        'Processed output must not overwrite the original scan.',
      );
    }

    try {
      await processedDirectory.create(recursive: true);
      await enhancedFile.writeAsBytes(enhancedBytes, flush: true);
      await thresholdFile.writeAsBytes(thresholdBytes, flush: true);
    } on FileSystemException catch (error) {
      throw GraphicsProcessingException(
        'Could not save processed report images: ${error.message}',
      );
    }

    return GraphicsProcessingResult(
      originalFile: originalScan,
      enhancedFile: enhancedFile,
      adaptiveThresholdFile: thresholdFile,
      qualityBefore: qualityBefore,
      qualityAfter: qualityAfter,
    );
  }

  Future<ImageQualityMetrics> analyze(File source) async {
    if (!await source.exists()) {
      throw const GraphicsProcessingException(
        'The scanned image does not exist.',
      );
    }

    try {
      return _measure(_decode(await source.readAsBytes()));
    } on FileSystemException catch (error) {
      throw GraphicsProcessingException(
        'Could not read the scanned image: ${error.message}',
      );
    }
  }

  img.Image _decode(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const GraphicsProcessingException(
          'The scanned file is not a supported image.',
        );
      }
      return decoded;
    } on GraphicsProcessingException {
      rethrow;
    } on Exception catch (error) {
      throw GraphicsProcessingException(
        'Could not decode the scanned image: $error',
      );
    }
  }

  ImageQualityMetrics _measure(img.Image image) {
    const gridLimit = 12;
    const darkPixelThreshold = 80;
    final columns = math.min(gridLimit, image.width);
    final rows = math.min(gridLimit, image.height);
    final tileHistograms = List<Int32List>.generate(
      columns * rows,
      (_) => Int32List(256),
      growable: false,
    );
    var brightnessSum = 0.0;
    var brightnessSquaredSum = 0.0;
    var darkPixels = 0;
    final pixelCount = image.width * image.height;

    for (var y = 0; y < image.height; y++) {
      final tileY = y * rows ~/ image.height;
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final brightness = _luminance(pixel.r, pixel.g, pixel.b);
        final level = brightness.round().clamp(0, 255);
        brightnessSum += brightness;
        brightnessSquaredSum += brightness * brightness;
        if (level < darkPixelThreshold) darkPixels++;
        final tileX = x * columns ~/ image.width;
        tileHistograms[tileY * columns + tileX][level]++;
      }
    }

    final averageBrightness = brightnessSum / pixelCount;
    final variance = math.max(
      0.0,
      brightnessSquaredSum / pixelCount - averageBrightness * averageBrightness,
    );
    final illuminationGrid = List<double>.generate(
      tileHistograms.length,
      (index) => _paperBrightness(tileHistograms[index]),
      growable: false,
    );
    final illuminationMean =
        illuminationGrid.reduce((a, b) => a + b) / illuminationGrid.length;
    final illuminationVariance =
        illuminationGrid
            .map(
              (value) =>
                  (value - illuminationMean) * (value - illuminationMean),
            )
            .reduce((a, b) => a + b) /
        illuminationGrid.length;
    final sortedIllumination = List<double>.of(illuminationGrid)..sort();
    final medianIllumination =
        sortedIllumination[sortedIllumination.length ~/ 2];
    final shadowTiles = illuminationGrid
        .where((value) => value < medianIllumination - 24)
        .length;
    final shadowRegionRatio = shadowTiles / illuminationGrid.length;
    final illuminationVariation = math.sqrt(illuminationVariance);

    return ImageQualityMetrics(
      averageBrightness: averageBrightness,
      contrast: math.sqrt(variance),
      illuminationVariation: illuminationVariation,
      darkRegionRatio: darkPixels / pixelCount,
      shadowRegionRatio: shadowRegionRatio,
      unevenLightingDetected:
          illuminationVariation >= 14 || shadowRegionRatio >= 0.08,
    );
  }

  double _paperBrightness(Int32List histogram) {
    final total = histogram.fold<int>(0, (sum, count) => sum + count);
    final targetCount = math.max(1, (total * 0.35).round());
    var collected = 0;
    var sum = 0;
    for (var level = 255; level >= 0 && collected < targetCount; level--) {
      final count = math.min(histogram[level], targetCount - collected);
      collected += count;
      sum += level * count;
    }
    return sum / collected;
  }

  img.Image _enhance(img.Image original, ImageQualityMetrics metrics) {
    const gridLimit = 12;
    final columns = math.min(gridLimit, original.width);
    final rows = math.min(gridLimit, original.height);
    final histograms = List<Int32List>.generate(
      columns * rows,
      (_) => Int32List(256),
      growable: false,
    );
    for (var y = 0; y < original.height; y++) {
      final tileY = y * rows ~/ original.height;
      for (var x = 0; x < original.width; x++) {
        final pixel = original.getPixel(x, y);
        final level = _luminance(
          pixel.r,
          pixel.g,
          pixel.b,
        ).round().clamp(0, 255);
        final tileX = x * columns ~/ original.width;
        histograms[tileY * columns + tileX][level]++;
      }
    }
    final illumination = histograms.map(_paperBrightness).toList();
    final targetIllumination =
        illumination.reduce((a, b) => a + b) / illumination.length;
    final output = img.Image.from(original, noAnimation: true);

    for (var y = 0; y < original.height; y++) {
      for (var x = 0; x < original.width; x++) {
        final pixel = original.getPixel(x, y);
        final brightness = _luminance(pixel.r, pixel.g, pixel.b);
        var correction = 1.0;
        if (metrics.unevenLightingDetected) {
          final localIllumination = _interpolateGrid(
            illumination,
            columns,
            rows,
            x,
            y,
            original.width,
            original.height,
          );
          final rawCorrection =
              targetIllumination / math.max(1.0, localIllumination);
          correction = (1 + (rawCorrection - 1) * 0.7).clamp(0.78, 1.3);
        }

        final normalizedBrightness = brightness * correction;
        final enhancedBrightness = ((normalizedBrightness - 128) * 1.08 + 128)
            .clamp(0, 255);
        final offset = enhancedBrightness - brightness;
        output.setPixelRgb(
          x,
          y,
          (pixel.r + offset).clamp(0, 255),
          (pixel.g + offset).clamp(0, 255),
          (pixel.b + offset).clamp(0, 255),
        );
      }
    }
    return output;
  }

  double _interpolateGrid(
    List<double> grid,
    int columns,
    int rows,
    int x,
    int y,
    int width,
    int height,
  ) {
    final gx = ((x + 0.5) * columns / width - 0.5).clamp(0, columns - 1);
    final gy = ((y + 0.5) * rows / height - 0.5).clamp(0, rows - 1);
    final x0 = gx.floor();
    final y0 = gy.floor();
    final x1 = math.min(x0 + 1, columns - 1);
    final y1 = math.min(y0 + 1, rows - 1);
    final fx = gx - x0;
    final fy = gy - y0;
    final top =
        grid[y0 * columns + x0] * (1 - fx) + grid[y0 * columns + x1] * fx;
    final bottom =
        grid[y1 * columns + x0] * (1 - fx) + grid[y1 * columns + x1] * fx;
    return top * (1 - fy) + bottom * fy;
  }

  img.Image _adaptiveThreshold(img.Image source) {
    final width = source.width;
    final height = source.height;
    final stride = width + 1;
    final integral = Float64List(stride * (height + 1));

    for (var y = 1; y <= height; y++) {
      var rowSum = 0.0;
      for (var x = 1; x <= width; x++) {
        final pixel = source.getPixel(x - 1, y - 1);
        rowSum += _luminance(pixel.r, pixel.g, pixel.b);
        integral[y * stride + x] = integral[(y - 1) * stride + x] + rowSum;
      }
    }

    final radius = (math.min(width, height) ~/ 32).clamp(3, 15);
    const bias = 7.0;
    final output = img.Image(width: width, height: height, numChannels: 3);
    for (var y = 0; y < height; y++) {
      final top = math.max(0, y - radius);
      final bottom = math.min(height, y + radius + 1);
      for (var x = 0; x < width; x++) {
        final left = math.max(0, x - radius);
        final right = math.min(width, x + radius + 1);
        final area = (bottom - top) * (right - left);
        final localSum =
            integral[bottom * stride + right] -
            integral[top * stride + right] -
            integral[bottom * stride + left] +
            integral[top * stride + left];
        final pixel = source.getPixel(x, y);
        final brightness = _luminance(pixel.r, pixel.g, pixel.b);
        final threshold = localSum / area - bias;
        final value = brightness < threshold ? 0 : 255;
        output.setPixelRgb(x, y, value, value, value);
      }
    }
    return output;
  }

  double _luminance(num red, num green, num blue) =>
      0.299 * red + 0.587 * green + 0.114 * blue;

  String _joinPath(String parent, String name) =>
      '$parent${Platform.pathSeparator}$name';

  String _normalizedPath(File file) =>
      file.absolute.path.replaceAll('\\', '/').toLowerCase();
}

class GraphicsProcessingResult {
  const GraphicsProcessingResult({
    required this.originalFile,
    required this.enhancedFile,
    required this.adaptiveThresholdFile,
    required this.qualityBefore,
    required this.qualityAfter,
  });

  final File originalFile;
  final File enhancedFile;
  final File adaptiveThresholdFile;
  final ImageQualityMetrics qualityBefore;
  final ImageQualityMetrics qualityAfter;
}

class ImageQualityMetrics {
  const ImageQualityMetrics({
    required this.averageBrightness,
    required this.contrast,
    required this.illuminationVariation,
    required this.darkRegionRatio,
    required this.shadowRegionRatio,
    required this.unevenLightingDetected,
  });

  /// Mean grayscale luminance on a 0-255 scale.
  final double averageBrightness;

  /// Standard deviation of per-pixel luminance on a 0-255 scale.
  final double contrast;

  /// Standard deviation of estimated paper brightness across a 12-by-12 grid.
  final double illuminationVariation;

  /// Fraction of pixels with luminance below 80.
  final double darkRegionRatio;

  /// Fraction of grid cells at least 24 luminance levels below the grid median.
  final double shadowRegionRatio;

  /// True when grid variation is at least 14 or shadow region ratio is at least 0.08.
  final bool unevenLightingDetected;
}

class GraphicsProcessingException implements Exception {
  const GraphicsProcessingException(this.message);

  final String message;

  @override
  String toString() => message;
}
