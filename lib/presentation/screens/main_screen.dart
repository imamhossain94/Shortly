import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shortener_view.dart';
import 'expander_view.dart';
import 'history_view.dart';
import 'menu_screen.dart';
import '../../core/constants.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    ShortenerView(),
    ExpanderView(),
    HistoryView(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if landscape (width > height usually, or specific breakpoint)
            final isLandscape = constraints.maxWidth > 600;

            if (isLandscape) {
              return Row(
                children: [
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _currentIndex = index;
                        _pageController.jumpToPage(index);
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.link),
                        selectedIcon: Icon(Icons.link_outlined),
                        label: Text('Shorten'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.unfold_more),
                        selectedIcon: Icon(Icons.unfold_more_outlined),
                        label: Text('Expand'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.history),
                        selectedIcon: Icon(Icons.history_outlined),
                        label: Text('History'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.menu),
                        selectedIcon: Icon(Icons.menu_open),
                        label: Text('Menu'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _screens,
                    ),
                  ),
                ],
              );
            }

            return PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width > 600
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageController.jumpToPage(index);
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.link),
                  selectedIcon: Icon(Icons.link_outlined),
                  label: 'Shorten',
                ),
                NavigationDestination(
                  icon: Icon(Icons.unfold_more),
                  selectedIcon: Icon(Icons.unfold_more_outlined),
                  label: 'Expand',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  selectedIcon: Icon(Icons.history_outlined),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu),
                  selectedIcon: Icon(Icons.menu_open),
                  label: 'Menu',
                ),
              ],
            ),
    );
  }
}
