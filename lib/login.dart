import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_dashboard.dart';
import 'main_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Base URL for API - 10.0.2.2 is the Android emulator's alias for localhost
  final String _baseUrl = 'http://10.0.2.2:5000/api';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('adminToken', token);
        await prefs.setString('username', username);

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Please check if the server is running.';
      });
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Figma design dimensions: 440px width
    final scale = screenWidth / 440.0;
    
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to extend behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24 * scale),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainContainer(initialIndex: 3), // 3 is Settings
              ),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0A),
              const Color(0xFF1A1A1A),
              const Color(0xFF0F0F0F),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60 * scale),
                  
                  // Logo/Icon Area
                  Center(
                    child: Container(
                      width: 80 * scale,
                      height: 80 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE0E0E0),
                            Color(0xFF9E9E9E),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 45 * scale,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32 * scale),
                  
                  // Title
                  Text(
                    'Admin Portal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abhayaLibre(
                      fontSize: 36 * scale,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2 * scale,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 8 * scale),
                  
                  Text(
                    'Gusenga App Management',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 0.5 * scale,
                    ),
                  ),
                  
                  SizedBox(height: 60 * scale),
                  
                  // Login Form Card
                  Container(
                    padding: EdgeInsets.all(28 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24 * scale),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username Field
                        Text(
                          'Username',
                          style: GoogleFonts.manrope(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'Enter your username',
                          icon: Icons.person_outline_rounded,
                          scale: scale,
                        ),
                        
                        SizedBox(height: 24 * scale),
                        
                        // Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.manrope(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          scale: scale,
                        ),
                        
                        if (_errorMessage != null) ...[
                          SizedBox(height: 20 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 * scale,
                              vertical: 12 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 18 * scale,
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.manrope(
                                      color: Colors.redAccent,
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 32 * scale),
                        
                        // Login Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _handleLogin,
                            borderRadius: BorderRadius.circular(16 * scale),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isLoading
                                      ? [
                                          const Color(0xFF757575),
                                          const Color(0xFF616161),
                                        ]
                                      : [
                                          const Color(0xFFE0E0E0),
                                          const Color(0xFFBDBDBD),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16 * scale),
                                boxShadow: _isLoading
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Container(
                                height: 56 * scale,
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? SizedBox(
                                        width: 24 * scale,
                                        height: 24 * scale,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: GoogleFonts.manrope(
                                          fontSize: 16 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          letterSpacing: 1 * scale,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 40 * scale),
                  
                  // Footer
                  Text(
                    'Secure Admin Access',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  SizedBox(height: 40 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double scale,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 15 * scale,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.manrope(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16 * scale, right: 12 * scale),
            child: Icon(
              icon,
              color: Colors.white.withOpacity(0.6),
              size: 22 * scale,
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withOpacity(0.5),
                    size: 20 * scale,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 18 * scale,
            horizontal: 16 * scale,
          ),
        ),
      ),
    );
  }
}
