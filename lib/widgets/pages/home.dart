import 'dart:math';

import 'package:cusor_patcher/widgets/pages/cursor_patch_page.dart';
import 'package:cusor_patcher/widgets/responsive_builder.dart';
import 'package:cusor_patcher/widgets/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:cusor_patcher/i18n/strings.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CursorIcon extends StatelessWidget {
  const CursorIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [const SizedBox(height: 20), Image.asset('assets/cursor.png', height: 80, width: 80), const SizedBox(height: 20), const Text('Cursor Patcher', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 20)],
    );
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

enum HomeTab {
  home(Icons.home_filled),
  settings(Icons.settings);

  final IconData icon;

  const HomeTab(this.icon);

  String get label {
    switch (this) {
      case HomeTab.home:
        return t.tabs.home;
      case HomeTab.settings:
        return t.tabs.settings;
    }
  }
}

class _HomeState extends ConsumerState<Home> {
  late PageController _pageController;

  HomeTab _currentTab = HomeTab.home;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (sizingInformation) {
        return Scaffold(
          backgroundColor: Colors.amber,
          body: SafeArea(
            child: Row(
              children: [
                if (!sizingInformation.isMobile)
                  NavigationRail(
                      selectedIndex: _currentTab.index,
                      onDestinationSelected: _goToPage,
                      extended: sizingInformation.isDesktop,
                      leading: sizingInformation.isDesktop ? const CursorIcon() : null,
                      destinations: HomeTab.values.map((tab) {
                        return NavigationRailDestination(
                          icon: Icon(tab.icon),
                          label: Text(tab.label),
                        );
                      }).toList()),
                Expanded(
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          CursorPatcherPage(sizingInformation: sizingInformation),
                          SettingsPage(sizingInformation: sizingInformation),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: sizingInformation.isMobile
              ? NavigationBar(
                  selectedIndex: sizingInformation.isMobile ? min(_currentTab.index, 2) : _currentTab.index,
                  onDestinationSelected: _goToPage,
                  destinations: HomeTab.values.map((tab) {
                    return NavigationDestination(icon: Icon(tab.icon), label: tab.label);
                  }).toList(),
                )
              : null,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: HomeTab.home.index);
    _currentTab = HomeTab.home;
  }

  void _goToPage(int index) {
    setState(() {
      _currentTab = HomeTab.values[index];
      _pageController.jumpToPage(_currentTab.index);
    });
  }
}
