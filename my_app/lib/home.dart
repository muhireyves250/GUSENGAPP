import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navigation_bar.dart';
import 'player.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, bool? hideNavigationBar}) 
      : hideNavigationBar = hideNavigationBar ?? false;
  
  final bool hideNavigationBar;

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
                      // Background gradient (Replacing broken Figma image)
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
                      
                      // Pattern overlay (Code generated)
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
              
              // Search Bar Background (X: 36, Y: 180)
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
                ),
              ),
              
              // Search Bar Text and Icon (X: 36, Y: 180)
              Positioned(
                left: 36 * scale,
                top: 190 * scale,
                child: Container(
                  width: 367 * scale,
                  height: 59 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 29 * scale),
                      Expanded(
                        child: Text(
                          'Search Broadcasts.....',
                          style: GoogleFonts.abhayaLibre(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromRGBO(255, 255, 255, 0.73),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 20 * scale,
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
                child: Stack(
                  children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20 * scale),
                          child: Container(
                            width: videoSectionWidth,
                            height: 177 * scale,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF48BB78),
                                  const Color(0xFF38A169),
                                ],
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
                              // Rectangle 6 overlay color D9D9D9 30%
                              Container(
                                width: videoSectionWidth,
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
                            width: videoSectionWidth,
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
                                        'Ruhuka umutima',
                                        style: GoogleFonts.manrope(
                                          fontSize: 16 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
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
                                            '28 October 2025',
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
                                            '1:55',
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
                                Container(
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
                                SizedBox(width: 10 * scale),
                              ],
                            ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
              
              // Audio Releases Section (X: 36, Y: 470) - Rectangle 7
              Positioned(
                left: 36 * scale,
                top: 473 * scale,
                width: videoSectionWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        _buildAudioItem(
                          context: context,
                          scale: finalScale,
                          itemWidth: videoSectionWidth,
                          thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                          title: 'Imana ni nyembabazi ',
                          date: '28 October 2025',
                          time: '10:00',
                          dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                          playUrl: 'https://www.figma.com/api/mcp/asset/2e9b4857-7ba7-4ba4-84ff-de5c0c37307e',
                          moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                        ),
                        SizedBox(height: 12 * scale),
                        _buildAudioItem(
                          context: context,
                          scale: finalScale,
                          itemWidth: videoSectionWidth,
                          thumbnailUrl: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
                          title: 'Ubuzima bushingiye kumana',
                          date: '2 November 2025',
                          time: '11:00',
                          dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                          playUrl: 'https://www.figma.com/api/mcp/asset/cad4a698-ea2d-4a2d-a7c4-272db5eb1f5c',
                          moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                        ),
                        SizedBox(height: 12 * scale),
                        _buildAudioItem(
                          context: context,
                          scale: finalScale,
                          itemWidth: videoSectionWidth,
                          thumbnailUrl: 'https://www.figma.com/api/mcp/asset/a59cdbd8-3f70-49be-91cb-5ba96ee8745f',
                          title: 'Imbaraga zimana zishobora byose',
                          date: '8 December 2024',
                          time: '19:00',
                          dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                          playUrl: 'https://www.figma.com/api/mcp/asset/2e9b4857-7ba7-4ba4-84ff-de5c0c37307e',
                          moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                          middleGradientColor: const Color(0xFF999999),
                        ),
                        SizedBox(height: 12 * scale),
                        _buildAudioItem(
                          context: context,
                          scale: finalScale,
                          itemWidth: videoSectionWidth,
                          thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                          title: 'Yesu aragukunda ',
                          date: '26 March 2023',
                          time: '06:00',
                          dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                          playUrl: 'https://www.figma.com/api/mcp/asset/5e3bb5f2-2502-4618-ab77-1f96f0f7c952',
                          moreUrl: 'https://www.figma.com/api/mcp/asset/8a527eb2-4ead-47e8-bd31-6b8f5895c965',
                        ),
                  ],
                ),
              ),
            
             // Rectangle 9 - Bottom Navigation Bar
             if (!hideNavigationBar)
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
              child: Icon(
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
          Icon(
            Icons.more_vert,
            color: Colors.white,
            size: 24 * scale,
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

