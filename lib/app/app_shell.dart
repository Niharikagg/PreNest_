import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_l10n.dart';
import '../features/profile/profile_provider.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  String _getTabTitle(int index, AppLanguage lang) {
    switch (index) {
      case 0:
        return AppStrings.t('Timeline', lang);
      case 1:
        return AppStrings.t('Records', lang);
      case 2:
        return AppStrings.t('Verify', lang);
      case 3:
        return AppStrings.t('Trends', lang);
      default:
        return 'PreNest';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couple = ref.watch(coupleProvider);
    final currentLang = ref.watch(languageProvider);
    final activePartner = couple.activePartner;
    final currentIndex = navigationShell.currentIndex;
    final theme = Theme.of(context);
    final activeName = activePartner.name.trim();
    final otherName = couple.otherPartner.name.trim();
    final coupleDisplayName = activePartner.role.toLowerCase() == 'him'
        ? '$activeName & ${otherName.isNotEmpty ? otherName : 'Her'}'
        : (otherName.isNotEmpty ? '$activeName & $otherName' : activeName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB23C59),
        foregroundColor: const Color(0xFFF7D6DC),
        titleTextStyle: const TextStyle(
          color: Color(0xFFF7D6DC),
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFF4B0F1E).withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 18,
                color: const Color(0xFFF7D6DC),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'PreNest',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (currentIndex != 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7D6DC)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTabTitle(currentIndex, currentLang),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF7D6DC),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    coupleDisplayName.isNotEmpty
                        ? coupleDisplayName
                        : 'Your Calm Care Circle',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFF7D6DC).withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Live Language Selector Menu
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<AppLanguage>(
              icon: const Icon(Icons.translate, size: 20),
              tooltip: AppStrings.t('Language', currentLang),
              initialValue: currentLang,
              onSelected: (AppLanguage lang) {
                ref.read(languageProvider.notifier).setLanguage(lang);
              },
              itemBuilder: (context) => AppLanguage.values.map((lang) {
                final isSelected = lang == currentLang;
                return PopupMenuItem<AppLanguage>(
                  value: lang,
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check : Icons.circle_outlined,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lang.label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9FA),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF8E2B44).withValues(alpha: 0.18),
              width: 1,
            ),
          ),
        ),
        child: Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xFF6D1D32),
              onPrimary: Colors.white,
              primaryContainer: const Color(0xFFF7D6DC),
              onPrimaryContainer: const Color(0xFF6D1D32),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            elevation: 0,
            backgroundColor: const Color(0xFFFFF9FA),
            indicatorColor: const Color(0xFFF7D6DC),
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == currentIndex,
              );
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.timeline_outlined),
                selectedIcon: const Icon(Icons.timeline),
                label: AppStrings.t('Timeline', currentLang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.description_outlined),
                selectedIcon: const Icon(Icons.description),
                label: AppStrings.t('Records', currentLang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.fact_check_outlined),
                selectedIcon: const Icon(Icons.fact_check),
                label: AppStrings.t('Verify', currentLang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.trending_up_outlined),
                selectedIcon: const Icon(Icons.trending_up),
                label: AppStrings.t('Trends', currentLang),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
