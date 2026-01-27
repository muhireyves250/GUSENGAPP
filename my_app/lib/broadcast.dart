import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/broadcast_model.dart';
import 'navigation_bar.dart';
import 'player.dart';

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({super.key, bool? hideNavigationBar}) 
      : hideNavigationBar = hideNavigationBar ?? false;
  
  final bool hideNavigationBar;

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
  List<Broadcast> _latestVideos = [];
  List<Broadcast> _topAudio = [];
  bool _isLoading = true;
  final String _baseUrl = 'http://10.0.2.2:5000/api';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchLatestVideos(),
      _fetchTopAudio(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchLatestVideos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/broadcasts?type=video'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            // Assuming data is chronological, take last 2 for latest
            final List<Broadcast> allVideos = data.map((e) => Broadcast.fromJson(e)).toList();
            _latestVideos = allVideos.length >= 2 
                ? allVideos.reversed.take(2).toList() 
                : allVideos.reversed.toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching latest videos: $e');
    }
  }

  Future<void> _fetchTopAudio() async {
    try {
      // Fetching all audio first, then filtering for top if backend doesn't support combined query
      // Or fetching top endpoint and filtering for audio
      final response = await http.get(Uri.parse('$_baseUrl/broadcasts/top'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _topAudio = data
                .map((e) => Broadcast.fromJson(e))
                .where((b) => b.type == 'audio')
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching top audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final padding = mediaQuery.padding;
    
    // Figma design dimensions: 440px width, 956px height (same as home page)
    final designWidth = 440.0;
    final designHeight = 956.0;
    
    // Calculate scale based on width to maintain design proportions
    final scale = screenWidth / designWidth;
    final heightScale = (screenHeight - padding.top - padding.bottom) / designHeight;
    // Use the smaller scale to ensure everything fits
    final finalScale = scale < heightScale ? scale : heightScale;
    
    // Common width for sections (same as home page)
    final contentWidth = 367 * scale;
    
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
                  
                  // Fixed "Top broadcasts" text
                  Positioned(
                    left: 36 * scale,
                    top: 50 * scale,
                    right: 36 * scale,
                    child: Text(
                      'Top broadcasts',
                      style: GoogleFonts.abhayaLibre(
                        fontSize: 22 * scale,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ),
                  
                  // Scrollable content
                  Positioned(
                    left: 0,
                    top: 50 * scale + 22 * scale + 16 * scale, // Below fixed text
                    right: 0,
                    bottom: 89 * finalScale + 20 * finalScale, // Space for bottom nav
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Top broadcasts" section (Videos)
                          Padding(
                            padding: EdgeInsets.only(
                              left: 36 * scale,
                              right: 36 * scale,
                              bottom: 20 * scale,
                            ),
                            child: _isLoading 
                              ? SizedBox(
                                  height: 200 * scale,
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.white54)
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _latestVideos.map((item) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 16 * scale),
                                      child: _buildVideoCard(
                                        video: item,
                                        scale: finalScale,
                                        width: contentWidth,
                                      ),
                                    );
                                  }).toList(),
                                ),
                          ),
                          
                          // Top Audio list
                          Padding(
                            padding: EdgeInsets.only(
                              left: 36 * scale,
                              right: 36 * scale,
                              bottom: 20 * scale,
                            ),
                            child: _isLoading 
                              ? SizedBox(
                                  height: 200 * scale,
                                  child: Center(
                                    child: CircularProgressIndicator(color: Colors.white54)
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _topAudio.map((item) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 12 * scale),
                                      child: _buildAudioItem(
                                        context: context,
                                        scale: finalScale,
                                        itemWidth: contentWidth,
                                        thumbnailUrl: item.thumbnail,
                                        title: item.title,
                                        date: item.date,
                                        time: item.time,
                                        dotUrl: '', 
                                        playUrl: '',
                                        moreUrl: item.audioUrl ?? '',
                                      ),
                                    );
                                  }).toList(),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Navigation Bar (same as home page)
                  if (!widget.hideNavigationBar)
                  Positioned(
                    left: 61 * scale,
                    bottom: 20 * scale,
                    width: constraints.maxWidth - 122 * scale,
                    child: BottomNavigationBarWidget(
                      scale: finalScale,
                      currentIndex: 1,
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

  Widget _buildVideoCard({
    required Broadcast video,
    required double scale,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20 * scale),
            child: video.thumbnail.isNotEmpty
                ? Image.network(
                    video.thumbnail,
                    width: width,
                    height: 177 * scale,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: width,
                      height: 177 * scale,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF48BB78),
                            const Color(0xFF38A169),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.video_library, color: Colors.white54, size: 50 * scale),
                      ),
                    ),
                  )
                : Container(
                    width: width,
                    height: 177 * scale,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF48BB78),
                          const Color(0xFF38A169),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.video_library, color: Colors.white54, size: 50 * scale),
                    ),
                  ),
          ),
          
          // Overlay info card background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Container(
                  height: 57 * scale,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20 * scale),
                      bottomRight: Radius.circular(20 * scale),
                    ),
                  ),
                ),
                // Rectangle 6 overlay color D9D9D9 30%
                Container(
                  width: width,
                  height: 57 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20 * scale),
                      bottomRight: Radius.circular(20 * scale),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Overlay info card content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: width,
              height: 57 * scale,
              child: Container(
                height: 57 * scale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20 * scale),
                    bottomRight: Radius.circular(20 * scale),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 18 * scale),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            style: GoogleFonts.manrope(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4 * scale),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12 * scale,
                                color: const Color(0xFFD1D1D1),
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                video.date,
                                style: GoogleFonts.manrope(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFFD1D1D1),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Icon(
                                Icons.access_time,
                                size: 12 * scale,
                                color: const Color(0xFFD1D1D1),
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                video.time,
                                style: GoogleFonts.manrope(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFFD1D1D1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerPage(
                                title: video.title,
                                date: video.date,
                                time: video.time,
                                thumbnailUrl: video.thumbnail,
                              ),
                            ),
                          );
                      },
                      child: Container(
                        width: 30 * scale,
                        height: 30 * scale,
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20 * scale,
                        ),
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioItem({
    required BuildContext context,
    required double scale,
    required double itemWidth,
    required String thumbnailUrl,
    required String title,
    required String date,
    required String time,
    required String dotUrl,
    required String playUrl,
    required String moreUrl,
    Color? middleGradientColor,
  }) {
    return SizedBox(
      width: itemWidth,
      child: Container(
        height: 69 * scale,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC0C0C0).withOpacity(0.25), // 0% - 25%
              const Color(0xFF999999).withOpacity(0.63), // 50% - 63%
              const Color(0xFF737373), // 100% - 100%
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(17 * scale),
        ),
        child: Row(
          children: [
            SizedBox(width: 10 * scale),
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(9 * scale),
              child: Image.network(
                thumbnailUrl,
                width: 60 * scale,
                height: 53 * scale,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60 * scale,
                    height: 53 * scale,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(9 * scale),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 13 * scale),
            // Title and metadata
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13.864 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4 * scale),
                  Row(
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.manrope(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFD1D1D1).withOpacity(0.7),
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Image.network(
                        dotUrl,
                        width: 2 * scale,
                        height: 2 * scale,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 2 * scale,
                            height: 2 * scale,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        time,
                        style: GoogleFonts.manrope(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerPage(
                      title: title,
                      date: date,
                      time: time,
                      thumbnailUrl: thumbnailUrl,
                    ),
                  ),
                );
              },
              child: Image.network(
                playUrl,
                width: 35 * scale,
                height: 35 * scale,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 35 * scale,
                    height: 35 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20 * scale,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 5 * scale),
            // More button (vertical)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 24 * scale,
            ),
            color: const Color(0xFF1A1A1A),
            onSelected: (value) async {
              if (value == 'share') {
                await Share.share('Check out this broadcast: $title\n$moreUrl');
              } else if (value == 'download') {
                final Uri url = Uri.parse(moreUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch download link')),
                    );
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.white70, size: 20 * scale),
                    SizedBox(width: 12 * scale),
                    Text('Share', style: GoogleFonts.manrope(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'download',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.white70, size: 20 * scale),
                    SizedBox(width: 12 * scale),
                    Text('Download', style: GoogleFonts.manrope(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
            SizedBox(width: 10 * scale),
          ],
        ),
      ),
    );
  }

}

