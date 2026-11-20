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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.favorite_rounded,
                size: 18,
                color: theme.colorScheme.primary,
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getTabTitle(currentIndex, currentLang),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    activePartner.name.isNotEmpty
                        ? (couple.coupleName.isNotEmpty
                            ? couple.coupleName
                            : activePartner.name)
                        : 'Your Calm Care Circle',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
          color: Colors.white,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: theme.colorScheme.primaryContainer,
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
    );
  }
}
