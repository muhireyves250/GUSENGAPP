import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Added for Glassmorphism
import 'login.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final String _baseUrl = 'http://10.0.2.2:5000/api';
  String? _token;
  String? _username;
  List<dynamic> _broadcasts = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();
  final TextEditingController _thumbnailController = TextEditingController(); // For video thumbnail URL
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _heroUrlController = TextEditingController();
  
  String _selectedCategory = 'new';
  
  // File upload state
  // File upload state
  PlatformFile? _selectedAudioFile;
  PlatformFile? _selectedCoverFile;
  PlatformFile? _selectedHeroFile;
  PlatformFile? _selectedLogoFile;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _youtubeUrlController.dispose();
    _thumbnailController.dispose();
    _descriptionController.dispose();
    _heroUrlController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('adminToken');
    final username = prefs.getString('username');

    if (token == null || username == null) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
      return;
    }

    setState(() {
      _token = token;
      _username = username;
    });

    await _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/broadcasts'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _broadcasts = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load broadcasts';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Check if server is running.';
        _isLoading = false;
      });
      debugPrint('Load error: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _selectedAudioFile = result.files.first;
      });
    }
  }

  Future<void> _pickCoverFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedCoverFile = result.files.first;
      });
    }
  }

  Future<void> _pickHeroFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedHeroFile = result.files.first;
      });
    }
  }

  Future<void> _pickLogoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedLogoFile = result.files.first;
      });
    }
  }

  Future<void> _uploadAudioBroadcast() async {
    if (_titleController.text.isEmpty || _selectedAudioFile == null) {
      _showSnackBar('Title and Audio file are required', isError: true);
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/broadcasts/audio'));
      request.headers['Authorization'] = 'Bearer $_token';
      
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['category'] = _selectedCategory;

      // Add audio file
      if (_selectedAudioFile!.path != null) {
         request.files.add(await http.MultipartFile.fromPath(
          'audio',
          _selectedAudioFile!.path!,
          contentType: MediaType('audio', 'mpeg'), // Adjust based on file type if needed
        ));
      }

      // Add cover file if selected
      if (_selectedCoverFile != null && _selectedCoverFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cover',
          _selectedCoverFile!.path!,
          contentType: MediaType('image', 'jpeg'), // Adjust based on file type
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        _showSnackBar('Audio uploaded successfully!');
        _clearForm();
        await _loadBroadcasts();
        if (mounted) Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['message'] ?? 'Failed to upload', isError: true);
      }
    } catch (e) {
      _showSnackBar('Upload error: $e', isError: true);
      debugPrint('Upload error: $e');
    }
  }

  Future<void> _addVideoBroadcast() async {
    if (_titleController.text.isEmpty || _youtubeUrlController.text.isEmpty) {
      _showSnackBar('Title and YouTube URL are required', isError: true);
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/broadcasts/video'));
      request.headers['Authorization'] = 'Bearer $_token';
      
      request.fields['title'] = _titleController.text;
      request.fields['youtubeUrl'] = _youtubeUrlController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['category'] = _selectedCategory;

      // Add cover file if selected
      if (_selectedCoverFile != null && _selectedCoverFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'cover',
          _selectedCoverFile!.path!,
          contentType: MediaType('image', 'jpeg'), // Adjust based on file type
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        _showSnackBar('Video added successfully!');
        _clearForm();
        await _loadBroadcasts();
        if (mounted) Navigator.pop(context);
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['message'] ?? 'Failed to add video', isError: true);
      }
    } catch (e) {
      _showSnackBar('Connection error', isError: true);
      debugPrint('Add error: $e');
    }
  }

  Future<void> _updateBroadcast(int id) async {
    if (_titleController.text.isEmpty) {
      _showSnackBar('Title is required', isError: true);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/broadcasts/$id'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _selectedCategory,
          'youtubeUrl': _youtubeUrlController.text.isNotEmpty ? _youtubeUrlController.text : null,
          'thumbnail': _thumbnailController.text.isNotEmpty ? _thumbnailController.text : null,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnackBar('Broadcast updated successfully!');
        _clearForm();
        await _loadBroadcasts();
        if (mounted) Navigator.pop(context); // Close dialog
      } else {
        _showSnackBar('Failed to update broadcast', isError: true);
      }
    } catch (e) {
      _showSnackBar('Connection error', isError: true);
      debugPrint('Edit error: $e');
    }
  }

  Future<void> _deleteBroadcast(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/broadcasts/$id'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSnackBar('Broadcast deleted successfully!');
        await _loadBroadcasts();
      } else {
        _showSnackBar('Failed to delete broadcast', isError: true);
      }
    } catch (e) {
      _showSnackBar('Connection error', isError: true);
      debugPrint('Delete error: $e');
    }
  }

  Future<void> _updateHeroBackground() async {
    if (_selectedHeroFile == null) {
      _showSnackBar('Please select an image', isError: true);
      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/home/hero-background'));
      request.headers['Authorization'] = 'Bearer $_token';

      if (_selectedHeroFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'hero',
          _selectedHeroFile!.path!,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        _showSnackBar('Hero background updated!');
        _clearForm();
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar('Failed to update background', isError: true);
      }
    } catch (e) {
      _showSnackBar('Connection error', isError: true);
      debugPrint('Update error: $e');
    }
  }

  Future<void> _updateLogo() async {
    if (_selectedLogoFile == null) {
      _showSnackBar('Please select a logo image', isError: true);
      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$_baseUrl/home/logo'));
      request.headers['Authorization'] = 'Bearer $_token';

      if (_selectedLogoFile!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'logo',
          _selectedLogoFile!.path!,
          contentType: MediaType('image', 'png'), // Typically logos are PNG/JPEG
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        _showSnackBar('Logo updated successfully!');
        _clearForm();
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar('Failed to update logo', isError: true);
      }
    } catch (e) {
      _showSnackBar('Connection error', isError: true);
      debugPrint('Update logo error: $e');
    }
  }

  void _clearForm() {
    _titleController.clear();
    _youtubeUrlController.clear();
    _thumbnailController.clear();
    _descriptionController.clear();
    _heroUrlController.clear();
    setState(() {
      _selectedCategory = 'new';
      _selectedAudioFile = null;
      _selectedCoverFile = null;
      _selectedHeroFile = null;
      _selectedLogoFile = null;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('adminToken');
    await prefs.remove('username');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final scale = screenWidth / 440.0;

    final audioCount = _broadcasts.where((b) => b['type'] == 'audio').length;
    final videoCount = _broadcasts.where((b) => b['type'] == 'video').length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F2027),
              const Color(0xFF203A43),
              const Color(0xFF2C5364),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(scale),
                  
                  // Content
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : _errorMessage != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.redAccent, size: 48 * scale),
                                    SizedBox(height: 16 * scale),
                                    Text(
                                      _errorMessage!,
                                      style: GoogleFonts.manrope(color: Colors.white70),
                                    ),
                                    SizedBox(height: 16 * scale),
                                    ElevatedButton(
                                      onPressed: _loadBroadcasts,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white.withOpacity(0.1),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadBroadcasts,
                                color: const Color(0xFF4CAF50),
                                backgroundColor: const Color(0xFF1A1A1A),
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(20 * scale),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Statistics
                                      _buildStatistics(scale, audioCount, videoCount),
                                      
                                      SizedBox(height: 32 * scale),
                                      
                                      // Quick Actions
                                      _buildQuickActions(scale),
                                      
                                      SizedBox(height: 32 * scale),
                                      
                                      // Broadcasts List
                                      _buildBroadcastsList(scale),
                                      
                                      SizedBox(height: 80 * scale), // Bottom padding
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 20 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.black87,
                  size: 26 * scale,
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: GoogleFonts.manrope(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Welcome back, $_username',
                      style: GoogleFonts.manrope(
                        fontSize: 13 * scale,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.logout_rounded, color: Colors.white70, size: 20 * scale),
                  onPressed: _logout,
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(double scale, int audioCount, int videoCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * scale, bottom: 16 * scale),
          child: Text(
            'Overview',
            style: GoogleFonts.manrope(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                scale,
                'Total',
                _broadcasts.length.toString(),
                Icons.dashboard_customize_rounded,
                [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildStatCard(
                scale,
                'Audio',
                audioCount.toString(),
                Icons.headphones_rounded,
                [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildStatCard(
                scale,
                'Video',
                videoCount.toString(),
                Icons.videocam_rounded,
                [const Color(0xFFFA709A), const Color(0xFFFEE140)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(double scale, String label, String value, IconData icon, List<Color> gradients) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradients,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(icon, color: Colors.white, size: 20 * scale),
              ),
              SizedBox(height: 16 * scale),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.only(left: 4 * scale, bottom: 16 * scale),
          child: Text(
            'Actions',
            style: GoogleFonts.manrope(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                scale,
                'Upload Audio',
                Icons.music_note_rounded,
                const Color(0xFF6A11CB),
                const Color(0xFF2575FC),
                () => _showUploadAudioDialog(scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildActionCard(
                scale,
                'Add Video',
                Icons.play_circle_filled_rounded,
                const Color(0xFFFF512F),
                const Color(0xFFDD2476),
                () => _showAddVideoDialog(scale),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                scale,
                'Update Hero',
                Icons.image_rounded,
                const Color(0xFFFF9966),
                const Color(0xFFFF5E62),
                () => _showUpdateHeroDialog(scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildActionCard(
                scale,
                'Update Logo',
                Icons.branding_watermark_rounded,
                const Color(0xFF8E2DE2),
                const Color(0xFF4A00E0),
                () => _showUpdateLogoDialog(scale),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(double scale, String label, IconData icon, Color color1, Color color2, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20 * scale),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20 * scale),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24 * scale, horizontal: 12 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20 * scale),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color1, color2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color1.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24 * scale),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastsList(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4 * scale, bottom: 16 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Broadcasts',
                style: GoogleFonts.manrope(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_broadcasts.length} Total',
                  style: GoogleFonts.manrope(
                    fontSize: 11 * scale,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_broadcasts.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32 * scale),
              child: Column(
                children: [
                  Icon(Icons.library_music_outlined, size: 48 * scale, color: Colors.white24),
                  SizedBox(height: 16 * scale),
                  Text(
                    'No broadcasts yet',
                    style: GoogleFonts.manrope(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._broadcasts.map((broadcast) => _buildBroadcastItem(scale, broadcast)),
      ],
    );
  }

  Widget _buildBroadcastItem(double scale, dynamic broadcast) {
    final isAudio = broadcast['type'] == 'audio';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16 * scale),
          onTap: () => _showEditBroadcastDialog(scale, broadcast),
          child: Padding(
            padding: EdgeInsets.all(12 * scale),
            child: Row(
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isAudio 
                        ? [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]
                        : [const Color(0xFFFA709A), const Color(0xFFFEE140)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(
                    isAudio ? Icons.headphones_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broadcast['title'] ?? 'Untitled',
                        style: GoogleFonts.manrope(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4 * scale),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 2 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4 * scale),
                            ),
                            child: Text(
                              (broadcast['category'] ?? 'New').toString().toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 9 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            broadcast['date'] ?? 'No date',
                            style: GoogleFonts.manrope(
                              fontSize: 11 * scale,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: Colors.white70, size: 20 * scale),
                  onPressed: () => _showEditBroadcastDialog(scale, broadcast),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withOpacity(0.7), size: 20 * scale),
                  onPressed: () => _confirmDelete(broadcast['id']),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Delete Broadcast',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this broadcast?',
          style: GoogleFonts.manrope(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBroadcast(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUploadAudioDialog(double scale) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Upload Audio',
              style: GoogleFonts.manrope(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.manrope(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.manrope(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text('Audio File:', style: GoogleFonts.manrope(color: Colors.white70)),
                  SizedBox(height: 8 * scale),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickAudioFile();
                      setState(() {});
                    },
                    icon: const Icon(Icons.audio_file),
                    label: Text(_selectedAudioFile?.name ?? 'Select Audio (MP3/WAV)'),
                  ),
                  SizedBox(height: 16 * scale),
                  SizedBox(height: 16 * scale),
                  Text('Cover Photo:', style: GoogleFonts.manrope(color: Colors.white70)),
                  SizedBox(height: 8 * scale),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickCoverFile();
                      setState(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: Text(_selectedCoverFile?.name ?? 'Select Cover (Optional)'),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Date & Time will be set automatically',
                    style: GoogleFonts.manrope(color: Colors.white30, fontSize: 12 * scale),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearForm();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                   _uploadAudioBroadcast();
                   // Close dialog via _uploadAudioBroadcast logic or check mounted
                },
                child: const Text('Upload'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddVideoDialog(double scale) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Add Video',
              style: GoogleFonts.manrope(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.manrope(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.manrope(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _youtubeUrlController,
                    style: GoogleFonts.manrope(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'YouTube URL',
                      labelStyle: GoogleFonts.manrope(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Text('Cover Photo:', style: GoogleFonts.manrope(color: Colors.white70)),
                  SizedBox(height: 8 * scale),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickCoverFile();
                      setState(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: Text(_selectedCoverFile?.name ?? 'Select Cover (Optional)'),
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Date & Time will be set automatically',
                    style: GoogleFonts.manrope(color: Colors.white30, fontSize: 12 * scale),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearForm();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _addVideoBroadcast,
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateHeroDialog(double scale) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Update Hero Background',
              style: GoogleFonts.manrope(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16 * scale),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickHeroFile();
                      setState(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: Text(_selectedHeroFile?.name ?? 'Select Image'),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearForm();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _updateHeroBackground,
                child: const Text('Update'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showUpdateLogoDialog(double scale) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Update Logo',
              style: GoogleFonts.manrope(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16 * scale),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _pickLogoFile();
                      setState(() {});
                    },
                    icon: const Icon(Icons.image),
                    label: Text(_selectedLogoFile?.name ?? 'Select Logo'),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearForm();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _updateLogo,
                child: const Text('Update'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showEditBroadcastDialog(double scale, dynamic broadcast) {
    // Pre-fill controllers
    _titleController.text = broadcast['title'] ?? '';
    _descriptionController.text = broadcast['description'] ?? '';
    _youtubeUrlController.text = broadcast['youtubeUrl'] ?? '';
    _thumbnailController.text = broadcast['thumbnail'] ?? '';
    _selectedCategory = broadcast['category'] ?? 'new';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Edit Broadcast',
              style: GoogleFonts.manrope(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.manrope(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: GoogleFonts.manrope(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    style: GoogleFonts.manrope(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.manrope(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                    ),
                  ),
                  if (broadcast['type'] == 'video')
                    TextField(
                      controller: _youtubeUrlController,
                      style: GoogleFonts.manrope(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'YouTube URL',
                        labelStyle: GoogleFonts.manrope(color: Colors.white70),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                    ),
                  // Note: Audio file update not supported in this simple edit
                  if (broadcast['type'] == 'audio')
                     Padding(
                       padding: EdgeInsets.only(top: 10 * scale),
                       child: Text('To replace audio file, please delete and re-upload.', style: GoogleFonts.manrope(color: Colors.white30, fontSize: 10 * scale)),
                     )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearForm();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _updateBroadcast(broadcast['id']),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }
}
