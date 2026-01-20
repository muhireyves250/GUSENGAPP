import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                                Icon(Icons.error_outline, color: Colors.red, size: 48 * scale),
                                SizedBox(height: 16 * scale),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.manrope(color: Colors.white),
                                ),
                                SizedBox(height: 16 * scale),
                                ElevatedButton(
                                  onPressed: _loadBroadcasts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadBroadcasts,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.all(16 * scale),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Statistics
                                  _buildStatistics(scale, audioCount, videoCount),
                                  
                                  SizedBox(height: 24 * scale),
                                  
                                  // Quick Actions
                                  _buildQuickActions(scale),
                                  
                                  SizedBox(height: 24 * scale),
                                  
                                  // Broadcasts List
                                  _buildBroadcastsList(scale),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
              ),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: Colors.black87,
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: GoogleFonts.abhayaLibre(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Welcome, $_username',
                  style: GoogleFonts.manrope(
                    fontSize: 12 * scale,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white70, size: 22 * scale),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(double scale, int audioCount, int videoCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: GoogleFonts.abhayaLibre(
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                scale,
                'Total',
                _broadcasts.length.toString(),
                Icons.library_music_rounded,
                const Color(0xFF4CAF50),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildStatCard(
                scale,
                'Audio',
                audioCount.toString(),
                Icons.headphones_rounded,
                const Color(0xFF2196F3),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildStatCard(
                scale,
                'Video',
                videoCount.toString(),
                Icons.videocam_rounded,
                const Color(0xFFF44336),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(double scale, String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28 * scale),
          SizedBox(height: 8 * scale),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12 * scale,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.abhayaLibre(
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                scale,
                'Upload Audio',
                Icons.music_note,
                Colors.blue,
                () => _showUploadAudioDialog(scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildActionCard(
                scale,
                'Add Video',
                Icons.video_library,
                Colors.red,
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
                Icons.image,
                Colors.orange,
                () => _showUpdateHeroDialog(scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: _buildActionCard(
                scale,
                'Update Logo',
                Icons.branding_watermark,
                Colors.purple,
                () => _showUpdateLogoDialog(scale),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(double scale, String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Ink(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24 * scale),
              ),
              SizedBox(height: 12 * scale),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastsList(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Broadcasts (${_broadcasts.length})',
          style: GoogleFonts.abhayaLibre(
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12 * scale),
        if (_broadcasts.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(32 * scale),
              child: Text(
                'No broadcasts yet',
                style: GoogleFonts.manrope(
                  color: Colors.white.withOpacity(0.5),
                ),
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
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: BoxDecoration(
              color: isAudio ? const Color(0xFF2196F3) : const Color(0xFFF44336),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(
              isAudio ? Icons.headphones : Icons.videocam,
              color: Colors.white,
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  broadcast['title'] ?? 'Untitled',
                  style: GoogleFonts.manrope(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '${broadcast['category']} • ${broadcast['date'] ?? 'No date'}',
                  style: GoogleFonts.manrope(
                    fontSize: 11 * scale,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue, size: 20 * scale),
            onPressed: () => _showEditBroadcastDialog(scale, broadcast),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 20 * scale),
            onPressed: () => _confirmDelete(broadcast['id']),
          ),
        ],
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
