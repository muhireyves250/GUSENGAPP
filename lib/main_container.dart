import 'package:flutter/material.dart';
import 'home.dart';
import 'broadcast.dart';
import 'download.dart';
import 'settings.dart';
import 'navigation_bar.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavigationTap(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final padding = mediaQuery.padding;
    
    // Figma design dimensions: 440px width, 956px height
    final designWidth = 440.0;
    final designHeight = 956.0;
    
    // Calculate scale based on width to maintain design proportions
    final scale = screenWidth / designWidth;
    final heightScale = (screenHeight - padding.top - padding.bottom) / designHeight;
    // Use the smaller scale to ensure everything fits
    final finalScale = scale < heightScale ? scale : heightScale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF1A1A1A),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Solid black background
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                  
                  // Current page content (IndexedStack keeps all pages in memory, no reload)
                  Positioned.fill(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: const [
                        HomePage(hideNavigationBar: true),
                        BroadcastPage(hideNavigationBar: true),
                        DownloadPage(hideNavigationBar: true),
                        SettingsPage(hideNavigationBar: true),
                      ],
                    ),
                  ),
                  
                  // Bottom Navigation Bar (always visible, no reload)
                  Positioned(
                    left: 10 * scale,
                    bottom: 0 * scale,
                    width: constraints.maxWidth - 20 * scale,
                    child: BottomNavigationBarWidget(
                      scale: finalScale,
                      currentIndex: _currentIndex,
                      onTap: _onNavigationTap,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

