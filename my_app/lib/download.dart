import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/broadcast_model.dart';
import 'navigation_bar.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key, bool? hideNavigationBar}) 
      : hideNavigationBar = hideNavigationBar ?? false;
  
  final bool hideNavigationBar;

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<Broadcast> _archives = [];
  bool _isLoading = true;
  final String _baseUrl = 'http://10.0.2.2:5000/api';

  @override
  void initState() {
    super.initState();
    _fetchArchives();
  }

  Future<void> _fetchArchives() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$_baseUrl/broadcasts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _archives = data.map((e) => Broadcast.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching archives: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    
    // Common width for sections (same as broadcasts page)
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
                  
                  // Fixed "Archives" text
                  Positioned(
                    left: 36 * scale,
                    top: 50 * scale,
                    right: 36 * scale,
                    child: Text(
                      'Archives',
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
                    child: _isLoading 
                      ? Center(child: CircularProgressIndicator(color: Colors.white54))
                      : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Archives List
                          Padding(
                            padding: EdgeInsets.only(
                              left: 36 * scale,
                              right: 36 * scale,
                              bottom: 20 * scale,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _archives.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12 * scale),
                                  child: DownloadItemWidget(
                                    scale: finalScale,
                                    itemWidth: contentWidth,
                                    thumbnailUrl: item.thumbnail,
                                    title: item.title,
                                    date: item.date,
                                    time: item.time,
                                    dotUrl: '', // Or valid asset URL if needed
                                    isDownloadingInitial: false,
                                    moreUrl: item.audioUrl,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Navigation Bar
                  if (!widget.hideNavigationBar)
                  Positioned(
                    left: 61 * scale,
                    bottom: 20 * scale,
                    width: constraints.maxWidth - 122 * scale,
                    child: BottomNavigationBarWidget(
                      scale: finalScale,
                      currentIndex: 2,
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
}

class DownloadItemWidget extends StatefulWidget {
  final double scale;
  final double itemWidth;
  final String thumbnailUrl;
  final String title;
  final String date;
  final String time;
  final String dotUrl;
  final bool isDownloadingInitial;
  final Color? middleGradientColor;
  final String? moreUrl;

  const DownloadItemWidget({
    super.key,
    required this.scale,
    required this.itemWidth,
    required this.thumbnailUrl,
    required this.title,
    required this.date,
    required this.time,
    required this.dotUrl,
    required this.isDownloadingInitial,
    this.middleGradientColor,
    this.moreUrl,
  });

  @override
  State<DownloadItemWidget> createState() => _DownloadItemWidgetState();
}

class _DownloadItemWidgetState extends State<DownloadItemWidget> {
  late bool isDownloading;
  bool isDownloaded = false;

  @override
  void initState() {
    super.initState();
    isDownloading = widget.isDownloadingInitial;
  }

  void _toggleDownload() {
    if (isDownloaded || isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    // Simulate download delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isDownloading = false;
          isDownloaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.itemWidth,
      child: Container(
        height: 69 * widget.scale,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFC0C0C0).withValues(alpha: 0.25), // 0% - 25%
              widget.middleGradientColor?.withValues(alpha: 0.63) ?? const Color(0xFF999999).withValues(alpha: 0.63), // 50% - 63%
              const Color(0xFF737373), // 100% - 100%
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(17 * widget.scale),
        ),
        child: Row(
          children: [
            SizedBox(width: 10 * widget.scale),
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(9 * widget.scale),
              child: Container(
                width: 60 * widget.scale,
                height: 53 * widget.scale,
                color: Colors.grey[800],
                child: Icon(
                  Icons.music_note,
                  color: Colors.white54,
                  size: 24 * widget.scale,
                ),
              ),
            ),
            SizedBox(width: 13 * widget.scale),
            // Title and metadata
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.manrope(
                      fontSize: 13.864 * widget.scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4 * widget.scale),
                  Row(
                    children: [
                      Text(
                        widget.date,
                        style: GoogleFonts.manrope(
                          fontSize: 12 * widget.scale,
                          fontWeight: FontWeight.normal,
                          color: const Color(0xFFD1D1D1).withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(width: 6 * widget.scale),
                      Container(
                        width: 3 * widget.scale,
                        height: 3 * widget.scale,
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6 * widget.scale),
                      Text(
                        widget.time,
                        style: GoogleFonts.manrope(
                          fontSize: 12 * widget.scale,
                          fontWeight: FontWeight.normal,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Download icon or downloading indicator
            GestureDetector(
              onTap: _toggleDownload,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(5 * widget.scale),
                alignment: Alignment.center,
                child: Builder(
                  builder: (context) {
                    if (isDownloading) {
                      return SizedBox(
                        width: 24 * widget.scale,
                        height: 24 * widget.scale,
                        child: CircularProgressIndicator(
                          strokeWidth: 2 * widget.scale,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    } else if (isDownloaded) {
                       return Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 24 * widget.scale,
                      );
                    } else {
                      return Icon(
                        Icons.download,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 24 * widget.scale,
                      );
                    }
                  }
                ),
              ),
            ),
            SizedBox(width: 5 * widget.scale),
            // More button (vertical)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withValues(alpha: 0.7),
                size: 24 * widget.scale,
              ),
              color: const Color(0xFF1A1A1A),
              onSelected: (value) async {
                final urlToUse = widget.moreUrl ?? 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc'; // Fallback URL
                if (value == 'share') {
                  await Share.share('Check out this broadcast: ${widget.title}\n$urlToUse');
                } else if (value == 'download') {
                  final Uri url = Uri.parse(urlToUse);
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
                      Icon(Icons.share, color: Colors.white70, size: 20 * widget.scale),
                      SizedBox(width: 12 * widget.scale),
                      Text('Share', style: GoogleFonts.manrope(color: Colors.white)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.white70, size: 20 * widget.scale),
                      SizedBox(width: 12 * widget.scale),
                      Text('Download', style: GoogleFonts.manrope(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 10 * widget.scale),
          ],
        ),
      ),
    );
  }
}
