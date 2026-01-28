import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'models/broadcast_model.dart';
import 'navigation_bar.dart';
import 'player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, bool? hideNavigationBar}) 
      : hideNavigationBar = hideNavigationBar ?? false;
  
  final bool hideNavigationBar;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _logoUrl;
  String? _heroImageUrl;
  Broadcast? _videoRelease;
  List<Broadcast> _audioReleases = [];
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
      _fetchLogo(),
      _fetchHeroImage(),
      _fetchVideoRelease(),
      _fetchAudioReleases(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchLogo() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/home/logo'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _logoUrl = data['url'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching logo: $e');
    }
  }

  Future<void> _fetchHeroImage() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/home/hero-background'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _heroImageUrl = data['url'];
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching hero image: $e');
    }
  }

  Future<void> _fetchVideoRelease() async {
    try {
      // Fetching all videos and picking the latest one or a featured one
      final response = await http.get(Uri.parse('$_baseUrl/broadcasts?type=video'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
           // Sort by ID descending to get latest, or just take first if backend sorts
           // Assuming backend returns list, taking the last added (highest ID) as 'new'
           // Or ideally backend has a /latest endpoint. For now taking the last one in the list.
           if (mounted) {
             setState(() {
               _videoRelease = Broadcast.fromJson(data.last);
             });
           }
        }
      }
    } catch (e) {
      debugPrint('Error fetching video release: $e');
    }
  }

  Future<void> _fetchAudioReleases() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/home/audio-releases'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _audioReleases = data.map((e) => Broadcast.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching audio releases: $e');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBroadcasts(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        if (mounted) {
          _searchController.clear();
          _showSearchResults(results);
        }
      } else {
        debugPrint('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _showSearchResults(List<dynamic> results) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Search Results (${results.length})',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: results.isEmpty
                        ? Center(
                            child: Text(
                              'No broadcasts found',
                              style: GoogleFonts.manrope(color: Colors.white70),
                            ),
                          )
                        : ListView.separated(
                            controller: controller,
                            itemCount: results.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[800],
                                    child: item['coverPhoto'] != null && item['coverPhoto'].toString().isNotEmpty
                                        ? Image.network(
                                            item['coverPhoto'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.music_note, color: Colors.white54),
                                          )
                                        : Icon(
                                            item['type'] == 'video' ? Icons.play_arrow : Icons.music_note,
                                            color: Colors.white54,
                                          ),
                                  ),
                                ),
                                title: Text(
                                  item['title'] ?? 'Untitled',
                                  style: GoogleFonts.manrope(color: Colors.white),
                                ),
                                subtitle: Text(
                                  item['description'] ?? '',
                                  style: GoogleFonts.manrope(color: Colors.white54, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayerPage(
                                        title: item['title'] ?? 'Untitled',
                                        date: item['date'] ?? '',
                                        time: item['time'] ?? '',
                                        thumbnailUrl: item['coverPhoto'] ?? '',
                                        audioUrl: item['audioUrl'], // Pass nullable
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    
    // Common width for video section and audio section (Rectangle 7)
    final videoSectionWidth = 367 * scale;
    
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
              // Status Bar
              Positioned(
                left: 0,
                top: 0,
                width: screenWidth,
                child: StatusBar(scale: finalScale),
              ),
              
              // Rectangle 1 - Hero Image Section (X: 0, Y: 0)
              Positioned(
                left: 0,
                top: 0,
                width: constraints.maxWidth,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: 431 * scale,
                  child: Stack(
                    children: [
                      // Background Image or Gradient
                      if (_heroImageUrl != null && _heroImageUrl!.isNotEmpty)
                         Image.network(
                           _heroImageUrl!,
                           width: double.infinity,
                           height: 431 * scale,
                           fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) => Container(
                             width: double.infinity,
                             height: 431 * scale,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF2D3748),
                                  const Color(0xFF1A202C),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(42 * scale),
                                bottomRight: Radius.circular(42 * scale),
                              ),
                            ),
                           ),
                         )
                      else
                        Container(
                        width: double.infinity,
                        height: 431 * scale,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF2D3748),
                              const Color(0xFF1A202C),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(42 * scale),
                            bottomRight: Radius.circular(42 * scale),
                          ),
                        ),
                      ),
                      
                      // Pattern overlay
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(
                            painter: PatternPainter(),
                          ),
                        ),
                      ),
                      
                      // Gradient overlay on image
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(42 * scale),
                              bottomRight: Radius.circular(42 * scale),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Logo Widget
              Positioned(
                left: 36 * scale,
                top: 70 * scale,
                child: Container(
                  width: 70 * scale,
                  height: 70 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    image: _logoUrl != null && _logoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(_logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                  ),
                  child: (_logoUrl == null || _logoUrl!.isEmpty)
                      ? Center(
                          child: Text(
                            'G',
                            style: GoogleFonts.abhayaLibre(
                              fontSize: 40 * scale,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              
              // Search Bar Widget (X: 36, Y: 180)
              Positioned(
                left: 36 * scale,
                top: 190 * scale,
                child: Container(
                  width: 367 * scale,
                  height: 59 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 29 * scale),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (value) => _searchBroadcasts(value),
                          style: GoogleFonts.abhayaLibre(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Broadcasts.....',
                            hintStyle: GoogleFonts.abhayaLibre(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w800,
                              color: const Color.fromRGBO(255, 255, 255, 0.73),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      GestureDetector(
                        onTap: () => _searchBroadcasts(_searchController.text),
                        child: _isSearching
                            ? SizedBox(
                                width: 20 * scale,
                                height: 20 * scale,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              )
                            : Icon(
                                Icons.search,
                                color: Colors.white70,
                                size: 20 * scale,
                              ),
                      ),
                      SizedBox(width: 12 * scale),
                    ],
                  ),
                ),
              ),
              
              // "New broadcasts" text (X: 58, Y: 250)
              Positioned(
                left: 58 * scale,
                top: 255 * scale,
                child: SizedBox(
                  width: (screenWidth - 58 * scale),
                  child: Text(
                    'New broadcasts',
                    style: GoogleFonts.abhayaLibre(
                      fontSize: 25 * scale,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Video Release Section (X: 38, Y: 280)
              Positioned(
                left: 38 * scale,
                top: 285 * scale,
                width: videoSectionWidth,
                height: 177 * scale,
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator(color: Colors.white54))
                  : _videoRelease != null 
                    ? _buildVideoCard(video: _videoRelease!, scale: finalScale, width: videoSectionWidth)
                    : Center(child: Text('No new broadcasts', style: TextStyle(color: Colors.white54))),
              ),
              
              // Audio Releases Section (X: 36, Y: 470) - Rectangle 7
              Positioned(
                left: 36 * scale,
                top: 473 * scale,
                width: videoSectionWidth,
                height: screenHeight - (473 * scale) - (80 * scale), // Constrain height to avoid overflow
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator(color: Colors.white54))
                  : _audioReleases.isEmpty 
                     ? Center(child: Text('No audio releases', style: TextStyle(color: Colors.white54)))
                     : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _audioReleases.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12 * scale),
                        itemBuilder: (context, index) {
                          final item = _audioReleases[index];
                      return _buildAudioItem(
                            context: context,
                            scale: finalScale,
                            itemWidth: videoSectionWidth,
                            thumbnailUrl: item.coverPhoto,
                            title: item.title,
                            date: item.date,
                            time: item.time,
                            dotUrl: '', // Using icons now
                            playUrl: '', // Using icons now
                            moreUrl: item.audioUrl ?? '',
                          );
                        },
                      ),
              ),
            
            
             // Rectangle 9 - Bottom Navigation Bar
             if (!widget.hideNavigationBar)
             Positioned(
               left: 61 * scale,
               bottom: 20 * scale,
              width: constraints.maxWidth - 122 * scale,
              child: BottomNavigationBarWidget(
                scale: finalScale,
                currentIndex: 0,
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
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20 * scale),
          child: video.coverPhoto.isNotEmpty
              ? Image.network(
                  video.coverPhoto,
                  width: width,
                  height: 177 * scale,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: width,
                    height: 177 * scale,
                    color: Colors.grey[800],
                    child: Icon(Icons.video_library, size: 50 * scale, color: Colors.white54),
                  ),
                )
              : Container(
                  width: width,
                  height: 177 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF48BB78), const Color(0xFF38A169)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.video_library_rounded,
                      size: 50 * scale,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
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
                                thumbnailUrl: video.coverPhoto,
                                audioUrl: video.audioUrl,
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
            const Color(0xFFC0C0C0).withValues(alpha: 0.25), // 0% - 25%
            const Color(0xFF999999).withValues(alpha: 0.63), // 50% - 63%
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
            child: Container(
              width: 60 * scale,
              height: 53 * scale,
              color: Colors.grey[800],
              child: thumbnailUrl.isNotEmpty 
                  ? Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.music_note,
                        color: Colors.white54,
                        size: 24 * scale,
                      ),
                    )
                  : Icon(
                      Icons.music_note,
                      color: Colors.white54,
                      size: 24 * scale,
                    ),
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
                        color: const Color(0xFFD1D1D1).withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Container(
                      width: 3 * scale,
                      height: 3 * scale,
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      time,
                      style: GoogleFonts.manrope(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.normal,
                        color: Colors.white.withValues(alpha: 0.7),
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
                    audioUrl: moreUrl,
                  ),
                ),
              );
            },
            child: Container(
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
                final Uri url = Uri.parse(moreUrl); // Assuming moreUrl is the download link for now, or use a specific one if available
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

class StatusBar extends StatefulWidget {
  final double scale;
  
  const StatusBar({super.key, required this.scale});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = _formatTime(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    String hour = time.hour.toString().padLeft(1, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59 * widget.scale,
      padding: EdgeInsets.symmetric(horizontal: 10 * widget.scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Time
          Container(
            width: 54 * widget.scale,
            alignment: Alignment.center,
            child: Text(
              _currentTime,
              style: TextStyle(
                fontSize: 16 * widget.scale,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.32 * widget.scale,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
          
          // Center - Dynamic Island
          Container(
            width: 125 * widget.scale,
            height: 37 * widget.scale,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100 * widget.scale),
            ),
            child: Stack(
              children: [
                // TrueDepth camera (left)
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: 80 * widget.scale,
                    height: 37 * widget.scale,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100 * widget.scale),
                    ),
                  ),
                ),
                // FaceTime camera (right)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 37 * widget.scale,
                    height: 37 * widget.scale,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Right side - Signal, WiFi, Battery
          Container(
            padding: EdgeInsets.only(right: 11 * widget.scale),
            child: Row(
              children: [
                Icon(Icons.signal_cellular_4_bar, size: 16 * widget.scale, color: Colors.white),
                SizedBox(width: 8 * widget.scale),
                Icon(Icons.wifi, size: 16 * widget.scale, color: Colors.white),
                SizedBox(width: 8 * widget.scale),
                Icon(Icons.battery_full, size: 16 * widget.scale, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0.0; i < size.width; i += 20) {
      path.moveTo(i, 0);
      path.lineTo(i - 20, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
