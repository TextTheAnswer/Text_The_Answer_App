import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common/theme_aware_widget.dart';
import '../widgets/app_drawer.dart';

//TODO: Do this in a better way
abstract class AppScaffoldKeys {
  static final GlobalKey<ScaffoldState> mainScaffoldKey =
      GlobalKey<ScaffoldState>();
}

class MainAppScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainAppScreen({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  @override
  Widget build(BuildContext context) {
    return ThemeAwareWidget(
      builder: (context, themeState) {
        final isDarkMode = themeState.themeData.brightness == Brightness.dark;
        
        return Scaffold(
          key: AppScaffoldKeys.mainScaffoldKey,
          body: widget.navigationShell,
          drawer: AppDrawer(
            toggleTheme: () => context.toggleTheme(),
            isDarkMode: isDarkMode,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: widget.navigationShell.currentIndex,
      onTap: (index) {
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Library',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gamepad),
          label: 'Games',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.quiz),
          label: 'Quiz',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
