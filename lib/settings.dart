import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation_bar.dart';
import 'login.dart';
import 'admin_dashboard.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, bool? hideNavigationBar}) 
      : hideNavigationBar = hideNavigationBar ?? false;
  
  final bool hideNavigationBar;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoggedIn = false;
  String? _adminUsername;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.containsKey('adminToken');
      _adminUsername = prefs.getString('username');
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminToken');
    await prefs.remove('username');
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final padding = mediaQuery.padding;
    final hideNavigationBar = widget.hideNavigationBar;

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
                  
                  // Content - Scrollable Settings
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 89 * finalScale + 20 * finalScale,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header - "Settings" text
                          Padding(
                            padding: EdgeInsets.only(
                              left: 36 * scale,
                              right: 36 * scale,
                              top: 20 * scale,
                              bottom: 20 * scale,
                            ),
                            child: Text(
                              'Settings',
                              style: GoogleFonts.abhayaLibre(
                                fontSize: 25 * scale,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                          
                          // Profile Card
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36 * scale),
                            child: Container(
                              padding: EdgeInsets.all(16 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(17 * scale),
                              ),
                              child: Row(
                                children: [
                                  // Profile Picture
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30 * scale),
                                    child: Image.network(
                                      'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                      width: 60 * scale,
                                      height: 60 * scale,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 60 * scale,
                                          height: 60 * scale,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(30 * scale),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 16 * scale),
                                  // Name and Title
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Yves Muhire',
                                          style: GoogleFonts.manrope(
                                            fontSize: 18 * scale,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Evangelist of the Good New of Jesus Christ',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12 * scale,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16 * scale),
                          
                          // Text Content Card
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36 * scale),
                            child: Container(
                              padding: EdgeInsets.all(20 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(17 * scale),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Beneath the soft glow of the evening sky',
                                    style: GoogleFonts.manrope(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 12 * scale),
                                  Text(
                                    'the city began to hum with quiet anticipation. Streetlights flickered on one by one, painting golden reflections across the rain-slick pavement. Somewhere in the distance, laughter drifted',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 24 * scale),
                          
                          // Contact Us Buttons (5 items)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36 * scale),
                            child: Column(
                              children: [
                                _buildSettingItem(
                                  scale: finalScale,
                                  icon: Icons.chat_bubble_outline,
                                  title: 'Contact us',
                                  iconColor: Colors.green,
                                ),
                                SizedBox(height: 12 * scale),
                                if (_isLoggedIn)
                                  _buildSettingItem(
                                    scale: finalScale,
                                    icon: Icons.dashboard_rounded,
                                    title: 'Admin Dashboard',
                                    iconColor: Colors.purple,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AdminDashboard()),
                                      );
                                    },
                                  ),
                                if (_isLoggedIn)
                                  SizedBox(height: 12 * scale),
                                _buildSettingItem(
                                  scale: finalScale,
                                  icon: _isLoggedIn ? Icons.logout : Icons.admin_panel_settings_outlined,
                                  title: _isLoggedIn ? 'Logout ($_adminUsername)' : 'Admin Login',
                                  iconColor: _isLoggedIn ? Colors.redAccent : Colors.teal,
                                  onTap: () {
                                    if (_isLoggedIn) {
                                      _handleLogout();
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 12 * scale),
                                _buildSettingItem(scale: finalScale, title: 'Share App', icon: Icons.share),
                                SizedBox(height: 12 * scale),
                                _buildSettingItem(scale: finalScale, title: 'Rate Us', icon: Icons.star_border),
                                SizedBox(height: 12 * scale),
                                _buildSettingItem(scale: finalScale, title: 'Privacy Policy', icon: Icons.privacy_tip_outlined),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 20 * scale),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Navigation Bar
                  if (!hideNavigationBar)
                  Positioned(
                    left: 61 * scale,
                    bottom: 20 * scale,
                    width: constraints.maxWidth - 122 * scale,
                    child: BottomNavigationBarWidget(
                      scale: finalScale,
                      currentIndex: 3,
                      onTap: (index) {
                        navigateToPage(context, index);
                      },
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

  Widget _buildSettingItem({
    required double scale, 
    required String title,
    required IconData icon,
    Color iconColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60 * scale,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A).withOpacity(0.8),
          borderRadius: BorderRadius.circular(17 * scale),
        ),
        child: Row(
          children: [
            SizedBox(width: 16 * scale),
            Container(
              width: 30 * scale,
              height: 30 * scale,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20 * scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16 * scale,
            ),
            SizedBox(width: 16 * scale),
          ],
        ),
      ),
    );
  }
}
