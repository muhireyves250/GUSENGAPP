import 'package:flutter/material.dart';
import 'home.dart';
import 'broadcast.dart';
import 'download.dart';
import 'settings.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final double scale;
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationBarWidget({
    super.key,
    required this.scale,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 95 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFF221A1A),
        borderRadius: BorderRadius.circular(33 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: _buildNavButton(
              scale: scale,
              iconUrl: 'https://www.figma.com/api/mcp/asset/66ebe06c-cc28-464e-bd50-638eb5f8e569',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
              isHome: true,
            ),
          ),
          Flexible(
            child: _buildNavButton(
              scale: scale,
              iconUrl: 'https://www.figma.com/api/mcp/asset/2e3d479c-f0cc-4a48-971e-1c8f08c6265c',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
              isBroadcast: true,
            ),
          ),
          Flexible(
            child: _buildNavButton(
              scale: scale,
              iconUrl: 'https://www.figma.com/api/mcp/asset/7648617c-43f4-4715-94fc-8f2b00fc40b3',
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
              isDownload: true,
            ),
          ),
          Flexible(
            child: _buildNavButton(
              scale: scale,
              iconUrl: 'https://www.figma.com/api/mcp/asset/6d1d8365-ca40-4e5c-b102-f6a8a789eb3b',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
              isSettings: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required double scale,
    required String iconUrl,
    required bool isActive,
    required VoidCallback onTap,
    bool isHome = false,
    bool isBroadcast = false,
    bool isDownload = false,
    bool isSettings = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110 * scale,
        height: 110 * scale,
        decoration: (isHome || isBroadcast || isDownload || isSettings)
            ? null // No circle decoration for all buttons with local icons
            : BoxDecoration(
                color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(
                        color: Colors.white,
                        width: 1.5 * scale,
                      )
                    : null,
              ),
        child: Center(
          child: isHome
              ? Image.asset(
                  isActive ? 'assets/icons/home_icon_hover.png' : 'assets/icons/home_icon.png',
                  width: 70 * scale,
                  height: 70 * scale,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.home,
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                      size: 70 * scale,
                    );
                  },
                )
              : isBroadcast
                  ? Image.asset(
                      isActive ? 'assets/icons/broardcast_icon_hover.png' : 'assets/icons/broardcast_icon.png',
                      width: 70 * scale,
                      height: 70 * scale,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.videocam,
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                          size: 70 * scale,
                        );
                      },
                    )
                  : isDownload
                      ? Image.asset(
                          isActive ? 'assets/icons/download_icon_hover.png' : 'assets/icons/download_icon.png',
                          width: 70 * scale,
                          height: 70 * scale,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.download,
                              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                              size: 70 * scale,
                            );
                          },
                        )
                      : isSettings
                          ? Image.asset(
                              isActive ? 'assets/icons/setting_icon_hover.png' : 'assets/icons/setting_icon.png',
                              width: 70 * scale,
                              height: 70 * scale,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.settings,
                                  color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                  size: 70 * scale,
                                );
                              },
                            )
                          : ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                BlendMode.srcIn,
                              ),
                              child: Image.network(
                                iconUrl,
                                width: 30 * scale,
                                height: 30 * scale,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.help,
                                    color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                    size: 30 * scale,
                                  );
                                },
                              ),
                            ),
        ),
      ),
    );
  }
}

// Navigation helper function
void navigateToPage(BuildContext context, int index) {
  switch (index) {
    case 0:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      break;
    case 1:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BroadcastPage()),
      );
      break;
    case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DownloadPage()),
      );
      break;
    case 3:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
      break;
  }
}

