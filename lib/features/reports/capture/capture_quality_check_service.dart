import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class CaptureQualityCheckService {
  const CaptureQualityCheckService();

  static const int minimumDimension = 100;
  static const double minimumSharpness = 12.0;
  static const double minimumStrongEdgeRatio = 0.05;
  static const double minimumLaplacianVariance = 500.0;
  static const double minimumBrightness = 45;
  static const double maximumBrightness = 245;
  static const double minimumContrast = 18;

  Future<CaptureQualityResult> check(File imageFile) async {
    final exists = await imageFile.exists();
    if (!exists) {
      return CaptureQualityResult(
        imageFile: imageFile,
        checks: const CaptureQualityChecks(fileExists: false),
        metrics: null,
        failureReasons: const ['The scanned image file does not exist.'],
      );
    }

    final Uint8List bytes;
    try {
      bytes = await imageFile.readAsBytes();
    } on FileSystemException catch (error) {
      return CaptureQualityResult(
        imageFile: imageFile,
        checks: const CaptureQualityChecks(
          fileExists: true,
          imageDecodable: false,
        ),
        metrics: null,
        failureReasons: [
          'The scanned image could not be read: ${error.message}',
        ],
      );
    }

    final img.Image? image;
    try {
      image = img.decodeImage(bytes);
    } on Exception catch (error) {
      return CaptureQualityResult(
        imageFile: imageFile,
        checks: const CaptureQualityChecks(
          fileExists: true,
          imageDecodable: false,
        ),
        metrics: null,
        failureReasons: ['The scanned image could not be decoded: $error'],
      );
    }

    if (image == null) {
      return CaptureQualityResult(
        imageFile: imageFile,
        checks: const CaptureQualityChecks(
          fileExists: true,
          imageDecodable: false,
        ),
        metrics: null,
        failureReasons: const [
          'The scanned file is not a supported or valid image.',
        ],
      );
    }

    if (image.width == 0 || image.height == 0) {
      return CaptureQualityResult(
        imageFile: imageFile,
        checks: const CaptureQualityChecks(
          fileExists: true,
          imageDecodable: true,
          dimensionsValid: false,
        ),
        metrics: null,
        failureReasons: const ['The scanned image has invalid dimensions.'],
      );
    }

    final metrics = _measure(image);
    final dimensionsValid =
        image.width >= minimumDimension &&
        image.height >= minimumDimension &&
        image.width * image.height >= minimumDimension * minimumDimension;
    final checks = CaptureQualityChecks(
      fileExists: true,
      imageDecodable: true,
      dimensionsValid: dimensionsValid,
      sharpnessAcceptable:
          metrics.sharpness >= minimumSharpness &&
          metrics.strongEdgeRatio >= minimumStrongEdgeRatio &&
          metrics.laplacianVariance >= minimumLaplacianVariance,
      brightnessAcceptable:
          metrics.averageBrightness >= minimumBrightness &&
          metrics.averageBrightness <= maximumBrightness,
      contrastAcceptable: metrics.contrast >= minimumContrast,
    );
    final failures = <String>[];
    if (!dimensionsValid) {
      failures.add(
        'The image is too small; it must be at least '
        '$minimumDimension x $minimumDimension pixels.',
      );
    }
    if (!checks.sharpnessAcceptable!) {
      failures.add(
        'The image appears blurred '
        '(gradient ${metrics.sharpness.toStringAsFixed(2)}; '
        'minimum $minimumSharpness, strong-edge ratio '
        '${(metrics.strongEdgeRatio * 100).toStringAsFixed(2)}%; '
        'minimum ${(minimumStrongEdgeRatio * 100).toStringAsFixed(1)}%, '
        'Laplacian variance ${metrics.laplacianVariance.toStringAsFixed(2)}; '
        'minimum $minimumLaplacianVariance). '
        'Please rescan.',
      );
    }
    if (!checks.brightnessAcceptable!) {
      failures.add(
        metrics.averageBrightness < minimumBrightness
            ? 'The image is too dark '
                  '(brightness ${metrics.averageBrightness.toStringAsFixed(1)}). '
                  'Please rescan with better lighting.'
            : 'The image is too bright '
                  '(brightness ${metrics.averageBrightness.toStringAsFixed(1)}). '
                  'Please reduce glare and rescan.',
      );
    }
    if (!checks.contrastAcceptable!) {
      failures.add(
        'The image has low contrast '
        '(contrast ${metrics.contrast.toStringAsFixed(1)}; '
        'minimum $minimumContrast). Please rescan.',
      );
    }

    return CaptureQualityResult(
      imageFile: imageFile,
      checks: checks,
      metrics: metrics,
      failureReasons: failures,
    );
  }

  CaptureQualityMetrics _measure(img.Image image) {
    var brightnessSum = 0.0;
    var brightnessSquaredSum = 0.0;
    final pixelCount = image.width * image.height;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final brightness = _luminance(pixel.r, pixel.g, pixel.b);
        brightnessSum += brightness;
        brightnessSquaredSum += brightness * brightness;
      }
    }

    final averageBrightness = brightnessSum / pixelCount;
    final variance = math.max(
      0.0,
      brightnessSquaredSum / pixelCount - averageBrightness * averageBrightness,
    );

    var laplacianSum = 0.0;
    var laplacianSquaredSum = 0.0;
    var laplacianCount = 0;
    var gradientMagnitudeSum = 0.0;
    var strongEdgeCount = 0;
    var gradientCount = 0;
    for (var y = 1; y < image.height - 1; y++) {
      for (var x = 1; x < image.width - 1; x++) {
        final center = _pixelLuminance(image, x, y);
        final laplacian =
            4 * center -
            _pixelLuminance(image, x - 1, y) -
            _pixelLuminance(image, x + 1, y) -
            _pixelLuminance(image, x, y - 1) -
            _pixelLuminance(image, x, y + 1);
        laplacianSum += laplacian;
        laplacianSquaredSum += laplacian * laplacian;
        laplacianCount++;

        final topLeft = _pixelLuminance(image, x - 1, y - 1);
        final top = _pixelLuminance(image, x, y - 1);
        final topRight = _pixelLuminance(image, x + 1, y - 1);
        final left = _pixelLuminance(image, x - 1, y);
        final right = _pixelLuminance(image, x + 1, y);
        final bottomLeft = _pixelLuminance(image, x - 1, y + 1);
        final bottom = _pixelLuminance(image, x, y + 1);
        final bottomRight = _pixelLuminance(image, x + 1, y + 1);
        final gx =
            -topLeft -
            2 * left -
            bottomLeft +
            topRight +
            2 * right +
            bottomRight;
        final gy =
            -topLeft -
            2 * top -
            topRight +
            bottomLeft +
            2 * bottom +
            bottomRight;
        final gradientMagnitude = math.sqrt(gx * gx + gy * gy);
        gradientMagnitudeSum += gradientMagnitude;
        gradientCount++;
        if (gradientMagnitude >= 25) strongEdgeCount++;
      }
    }
    final laplacianVariance = laplacianCount == 0
        ? 0.0
        : math.max(
            0.0,
            laplacianSquaredSum / laplacianCount -
                math.pow(laplacianSum / laplacianCount, 2),
          );
    final sharpness = gradientCount == 0
        ? 0.0
        : gradientMagnitudeSum / gradientCount;
    final strongEdgeRatio = gradientCount == 0
        ? 0.0
        : strongEdgeCount / gradientCount;

    return CaptureQualityMetrics(
      width: image.width,
      height: image.height,
      averageBrightness: averageBrightness,
      contrast: math.sqrt(variance),
      sharpness: sharpness,
      laplacianVariance: laplacianVariance,
      strongEdgeRatio: strongEdgeRatio,
    );
  }

  double _pixelLuminance(img.Image image, int x, int y) {
    final pixel = image.getPixel(x, y);
    return _luminance(pixel.r, pixel.g, pixel.b);
  }

  double _luminance(num red, num green, num blue) =>
      0.299 * red + 0.587 * green + 0.114 * blue;
}

class CaptureQualityChecks {
  const CaptureQualityChecks({
    required this.fileExists,
    this.imageDecodable,
    this.dimensionsValid,
    this.sharpnessAcceptable,
    this.brightnessAcceptable,
    this.contrastAcceptable,
  });

  final bool fileExists;
  final bool? imageDecodable;
  final bool? dimensionsValid;
  final bool? sharpnessAcceptable;
  final bool? brightnessAcceptable;
  final bool? contrastAcceptable;

  bool get allPassed =>
      fileExists &&
      imageDecodable == true &&
      dimensionsValid == true &&
      sharpnessAcceptable == true &&
      brightnessAcceptable == true &&
      contrastAcceptable == true;
}

class CaptureQualityMetrics {
  const CaptureQualityMetrics({
    required this.width,
    required this.height,
    required this.averageBrightness,
    required this.contrast,
    required this.sharpness,
    required this.laplacianVariance,
    required this.strongEdgeRatio,
  });

  final int width;
  final int height;

  /// Mean grayscale luminance on a 0-255 scale.
  final double averageBrightness;

  /// Standard deviation of per-pixel grayscale luminance on a 0-255 scale.
  final double contrast;

  /// Mean 3x3 Sobel gradient magnitude across readable-edge pixels.
  final double sharpness;

  /// Original 4-neighbor Laplacian variance retained for diagnosis.
  final double laplacianVariance;

  /// Fraction of interior pixels with Sobel magnitude at least 25.
  final double strongEdgeRatio;
}

class CaptureQualityResult {
  CaptureQualityResult({
    required this.imageFile,
    required this.checks,
    required this.metrics,
    required List<String> failureReasons,
  }) : failureReasons = List<String>.unmodifiable(failureReasons);

  final File imageFile;
  final CaptureQualityChecks checks;
  final CaptureQualityMetrics? metrics;
  final List<String> failureReasons;

  bool get isAcceptable => checks.allPassed;
}
