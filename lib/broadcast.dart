import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'navigation_bar.dart';
import 'player.dart';

class BroadcastPage extends StatelessWidget {
  const BroadcastPage({super.key, bool? hideNavigationBar}) 
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
                          // "Top broadcasts" section
                          Padding(
                            padding: EdgeInsets.only(
                              left: 36 * scale,
                              right: 36 * scale,
                              bottom: 20 * scale,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First top broadcast card
                                _buildTopBroadcastCard(
                                  scale: finalScale,
                                  width: contentWidth,
                                  imageUrl: 'https://www.figma.com/api/mcp/asset/3e8a38c1-eaf4-4219-b2de-628cfc7d9d41',
                                  title: 'Ruhuka umutima',
                                  date: '28 October 2025',
                                  time: '1:55',
                                ),
                                
                                SizedBox(height: 16 * scale),
                                
                                // Second top broadcast card
                                _buildTopBroadcastCard(
                                  scale: finalScale,
                                  width: contentWidth,
                                  imageUrl: 'https://www.figma.com/api/mcp/asset/1c53fe15-c4d4-4c43-93e1-f0fde8a53e56',
                                  title: 'Ruhuka umutima',
                                  date: '28 October 2025',
                                  time: '1:55',
                                ),
                              ],
                            ),
                          ),
                          
                          // General broadcast list
                          Padding(
                            padding: EdgeInsets.only(
                              left: 36 * scale,
                              right: 36 * scale,
                              bottom: 20 * scale,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAudioItem(
                                  context: context,
                                  scale: finalScale,
                                  itemWidth: contentWidth,
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
                                  itemWidth: contentWidth,
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
                                  itemWidth: contentWidth,
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
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                  title: 'Yesu aragukunda ',
                                  date: '26 March 2023',
                                  time: '06:00',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  playUrl: 'https://www.figma.com/api/mcp/asset/5e3bb5f2-2502-4618-ab77-1f96f0f7c952',
                                  moreUrl: 'https://www.figma.com/api/mcp/asset/8a527eb2-4ead-47e8-bd31-6b8f5895c965',
                                ),
                                SizedBox(height: 12 * scale),
                                _buildAudioItem(
                                  context: context,
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                                  title: 'Ubwoba bwose buraguka',
                                  date: '15 January 2024',
                                  time: '14:30',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  playUrl: 'https://www.figma.com/api/mcp/asset/2e9b4857-7ba7-4ba4-84ff-de5c0c37307e',
                                  moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                                ),
                                SizedBox(height: 12 * scale),
                                _buildAudioItem(
                                  context: context,
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
                                  title: 'Umutima wanjye wuzuye',
                                  date: '22 February 2024',
                                  time: '08:15',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  playUrl: 'https://www.figma.com/api/mcp/asset/cad4a698-ea2d-4a2d-a7c4-272db5eb1f5c',
                                  moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                                ),
                                SizedBox(height: 12 * scale),
                                _buildAudioItem(
                                  context: context,
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/a59cdbd8-3f70-49be-91cb-5ba96ee8745f',
                                  title: 'Nta wundi nkunda',
                                  date: '5 April 2024',
                                  time: '16:45',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  playUrl: 'https://www.figma.com/api/mcp/asset/2e9b4857-7ba7-4ba4-84ff-de5c0c37307e',
                                  moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                                  middleGradientColor: const Color(0xFF999999),
                                ),
                                SizedBox(height: 12 * scale),
                                _buildAudioItem(
                                  context: context,
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/83b21d14-3cbc-47f3-a740-e8a2d2c6e81b',
                                  title: 'Imana yanjye ni nyirubwoba',
                                  date: '12 May 2024',
                                  time: '09:20',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/5f0dc6be-eee3-4423-9dee-515641413da5',
                                  playUrl: 'https://www.figma.com/api/mcp/asset/5e3bb5f2-2502-4618-ab77-1f96f0f7c952',
                                  moreUrl: 'https://www.figma.com/api/mcp/asset/8a527eb2-4ead-47e8-bd31-6b8f5895c965',
                                ),
                                SizedBox(height: 12 * scale),
                                _buildAudioItem(
                                  context: context,
                                  scale: finalScale,
                                  itemWidth: contentWidth,
                                  thumbnailUrl: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
                                  title: 'Nta wundi wampundura',
                                  date: '30 June 2024',
                                  time: '13:10',
                                  dotUrl: 'https://www.figma.com/api/mcp/asset/195c91c8-1f87-4eda-85d5-422927a39565',
                                  playUrl: 'https://www.figma.com/api/mcp/asset/2e9b4857-7ba7-4ba4-84ff-de5c0c37307e',
                                  moreUrl: 'https://www.figma.com/api/mcp/asset/4f384859-7347-49a9-8ff8-464cbd16b1fc',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Navigation Bar (same as home page)
                  if (!hideNavigationBar)
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

  Widget _buildTopBroadcastCard({
    required double scale,
    required double width,
    required String imageUrl,
    required String title,
    required String date,
    required String time,
  }) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20 * scale),
            child: Image.network(
              imageUrl,
              width: width,
              height: 177 * scale,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
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
                );
              },
            ),
          ),
          
          // Overlay info card background
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                Image.network(
                  'https://www.figma.com/api/mcp/asset/3112a66f-ab6a-4562-99df-528389b7d031',
                  width: width,
                  height: 57 * scale,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 57 * scale,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20 * scale),
                          bottomRight: Radius.circular(20 * scale),
                        ),
                      ),
                    );
                  },
                ),
                // Rectangle 6 overlay color D9D9D9 30%
                Container(
                  width: width,
                  height: 57 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withOpacity(0.3),
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
                            title,
                            style: GoogleFonts.manrope(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Row(
                            children: [
                              Image.network(
                                'https://www.figma.com/api/mcp/asset/49f628a0-fcd9-4941-99ee-cc68ca452629',
                                width: 15 * scale,
                                height: 15 * scale,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.calendar_today,
                                    size: 12 * scale,
                                    color: const Color(0xFFD1D1D1),
                                  );
                                },
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                date,
                                style: GoogleFonts.manrope(
                                  fontSize: 13 * scale,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xFFD1D1D1),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Image.network(
                                'https://www.figma.com/api/mcp/asset/9d12510d-02bb-45a5-9d54-838b92374d2f',
                                width: 13 * scale,
                                height: 12 * scale,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.access_time,
                                    size: 12 * scale,
                                    color: const Color(0xFFD1D1D1),
                                  );
                                },
                              ),
                              SizedBox(width: 4 * scale),
                              Text(
                                time,
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
                    Image.network(
                      'https://www.figma.com/api/mcp/asset/06e4f4bb-f9e8-4c7a-9b91-61de968fed9e',
                      width: 30 * scale,
                      height: 30 * scale,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                        );
                      },
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
            Image.network(
              moreUrl,
              width: 35 * scale,
              height: 35 * scale,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 24 * scale,
                );
              },
            ),
            SizedBox(width: 10 * scale),
          ],
        ),
      ),
    );
  }

}

