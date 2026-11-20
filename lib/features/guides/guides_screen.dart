import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/tts_service.dart';
import 'guides_provider.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'All',
    'For You',
    'Period & PCOS',
    'Planning',
    'Pregnancy',
    'Postpartum',
    'Partner',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Period & PCOS':
        return const Color(0xFFE11D48); // Rose
      case 'Planning':
        return const Color(0xFF0F766E); // Teal
      case 'Pregnancy':
        return const Color(0xFF0284C7); // Sky
      case 'Postpartum':
        return const Color(0xFFD97706); // Amber
      case 'Partner':
        return const Color(0xFF7C3AED); // Purple
      default:
        return AppTheme.primaryTeal;
    }
  }

  Color _getCategoryContainerColor(String category) {
    switch (category) {
      case 'Period & PCOS':
        return const Color(0xFFFFE4E6);
      case 'Planning':
        return const Color(0xFFCCFBF1);
      case 'Pregnancy':
        return const Color(0xFFE0F2FE);
      case 'Postpartum':
        return const Color(0xFFFEF3C7);
      case 'Partner':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFCCFBF1);
    }
  }

  void _openArticleDetail(BuildContext context, GuideArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ArticleDetailModal(
        article: article,
        categoryColor: _getCategoryColor(article.category),
        categoryContainerColor: _getCategoryContainerColor(article.category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guidesProvider);
    final notifier = ref.read(guidesProvider.notifier);
    final articles = ref.watch(filteredArticlesProvider);
    final currentLang = ref.watch(languageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles & Guides Library'),
        scrolledUnderElevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    notifier.setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by symptom, food, lab, or advice...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.textMuted,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderLight),
                    ),
                  ),
                ),
              ),

              // Horizontal Category Chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = state.selectedCategory == cat;
                    final catColor = _getCategoryColor(cat);

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (cat == 'For You') ...[
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: isSelected ? Colors.white : catColor,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(cat),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        notifier.setCategory(cat);
                      },
                      selectedColor: cat == 'For You'
                          ? AppTheme.primaryTeal
                          : _getCategoryContainerColor(cat),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? (cat == 'For You' ? Colors.white : catColor)
                            : AppTheme.textDark,
                      ),
                      side: BorderSide(
                        color: isSelected ? catColor : AppTheme.borderLight,
                        width: 1,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Filter Count & Source Attribution Banner
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${articles.length} ${articles.length == 1 ? 'article' : 'articles'} found',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 12,
                            color: Color(0xFF15803D),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'ICMR • MoHFW • WHO • ACOG',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Articles List
              Expanded(
                child: articles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceMuted,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 32,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No matching guides found',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Try clearing your search query or selecting "All".',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.setSearchQuery('');
                                  notifier.setCategory('All');
                                },
                                child: const Text('Reset Filters'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          final catColor = _getCategoryColor(article.category);
                          final catContainer = _getCategoryContainerColor(
                            article.category,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: AppTheme.borderLight,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _openArticleDetail(context, article),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Badges: Category & Read Time
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: catContainer,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            article.category,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: catColor,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              article.readTimeLabel,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Article Title
                                    Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    // Summary Preview
                                    Text(
                                      article.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: AppTheme.textMuted,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Source Pill & Read Button Arrow
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceMuted,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            'Source: ${article.sourceLabel}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ),
                                        const Row(
                                          children: [
                                            Text(
                                              'Read Article',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryTeal,
                                              ),
                                            ),
                                            SizedBox(width: 2),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 11,
                                              color: AppTheme.primaryTeal,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// ARTICLE DETAIL MODAL BOTTOM SHEET
// ==========================================
class _ArticleDetailModal extends ConsumerWidget {
  final GuideArticle article;
  final Color categoryColor;
  final Color categoryContainerColor;

  const _ArticleDetailModal({
    required this.article,
    required this.categoryColor,
    required this.categoryContainerColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final tts = ref.read(ttsServiceProvider);
    final theme = Theme.of(context);

    // Formatted speech string for TTS
    final speechText =
        '${article.title}. Category: ${article.category}. '
        'Summary: ${article.summary}. Key Takeaways: '
        '${article.keyTakeaways.join(". ")}.';

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top Drag Handle & Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: categoryContainerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: AppTheme.borderLight),

              // Scrollable Article Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    // Article Title
                    Text(
                      article.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Metadata Row: Source & Read Time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Source: ${article.sourceLabel}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.readTimeLabel,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // TTS Read Aloud Action Button
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF0FDFA),
                        foregroundColor: AppTheme.primaryTealDark,
                        elevation: 0,
                        side: const BorderSide(
                          color: Color(0xFF99F6E4),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      icon: const Icon(
                        Icons.volume_up_outlined,
                        size: 20,
                        color: AppTheme.primaryTeal,
                      ),
                      label: Text(
                        'Read Aloud (${currentLang.label})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        tts.speak(speechText, currentLang);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Key Takeaways Highlight Box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF99F6E4),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: AppTheme.primaryTeal,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Key Evidence Takeaways',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTealDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...article.keyTakeaways.map((takeaway) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTeal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      takeaway,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Article Body
                    const Text(
                      'Detailed Clinical Guidance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.body,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mandatory Non-Diagnostic Clinical Safety Disclaimer Footer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Informational & Non-Diagnostic Notice',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PreNest Guides are purely educational and derived from official public health guidance '
                                  '(${article.sourceLabel}). PreNest does not diagnose conditions, prescribe medications, '
                                  'or provide medical dosing. Always consult your obstetrician, pediatrician, or qualified doctor '
                                  'for individualized medical care.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
