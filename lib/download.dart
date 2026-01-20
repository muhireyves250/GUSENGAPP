import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navigation_bar.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key, bool? hideNavigationBar}) 
      : hideNavigationBar = hideNavigationBar ?? false;
  
  final bool hideNavigationBar;

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
                    child: SingleChildScrollView(
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
                              children: [
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                  title: 'Yesu aragukunda',
                                  date: '26 March 2023',
                                  time: '06:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/a59cdbd8-3f70-49be-91cb-5ba96ee8745f',
                                  title: 'Imana ni nyembabazi',
                                  date: '28 October 2025',
                                  time: '10:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
                                  title: 'Ubuzima bushingiye kumana',
                                  date: '2 November 2025',
                                  time: '11:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                                  title: 'Imbaraga zimana zishobora byose',
                                  date: '8 December 2024',
                                  time: '19:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: true,
                                  middleGradientColor: const Color(0xFF999999),
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                  title: 'Ruhuka umutima',
                                  date: '28 October 2025',
                                  time: '1:55',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/a59cdbd8-3f70-49be-91cb-5ba96ee8745f',
                                  title: 'Ubwoba bwose buraguka',
                                  date: '15 January 2024',
                                  time: '14:30',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
                                  title: 'Umutima wanjye wuzuye',
                                  date: '22 February 2024',
                                  time: '08:15',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                                  title: 'Nta wundi nkunda',
                                  date: '5 April 2024',
                                  time: '16:45',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                  title: 'Imana yanjye ni nyirubwoba',
                                  date: '12 May 2024',
                                  time: '09:20',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/a59cdbd8-3f70-49be-91cb-5ba96ee8745f',
                                  title: 'Nta wundi wampundura',
                                  date: '30 June 2024',
                                  time: '13:10',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
                                  title: 'Yesu ni we Mwami',
                                  date: '10 July 2024',
                                  time: '15:30',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                                  title: 'Nta wundi wampundura',
                                  date: '18 August 2024',
                                  time: '12:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                  title: 'Imana ni nyirubwoba',
                                  date: '25 September 2024',
                                  time: '17:45',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/a59cdbd8-3f70-49be-91cb-5ba96ee8745f',
                                  title: 'Umutima wanjye wuzuye',
                                  date: '3 October 2024',
                                  time: '11:20',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
                                  title: 'Ubwoba bwose buraguka',
                                  date: '14 November 2024',
                                  time: '09:15',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  isDownloadingInitial: false,
                                ),
                                SizedBox(height: 12 * scale),
                                DownloadItemWidget(
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                                  title: 'Imana ni nyembabazi',
                                  date: '22 December 2024',
                                  time: '14:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  isDownloadingInitial: false,
                                ),
                              ],
                            ),
                          ),
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
              child: Image.network(
                widget.thumbnailUrl,
                width: 60 * widget.scale,
                height: 53 * widget.scale,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60 * widget.scale,
                    height: 53 * widget.scale,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(9 * widget.scale),
                    ),
                  );
                },
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
                      Image.network(
                        widget.dotUrl,
                        width: 2 * widget.scale,
                        height: 2 * widget.scale,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 2 * widget.scale,
                            height: 2 * widget.scale,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          );
                        },
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
            Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24 * widget.scale,
            ),
            SizedBox(width: 10 * widget.scale),
          ],
        ),
      ),
    );
  }
}
