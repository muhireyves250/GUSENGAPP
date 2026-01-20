import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlayerPage extends StatelessWidget {
  final String? title;
  final String? date;
  final String? time;
  final String? thumbnailUrl;

  const PlayerPage({
    super.key,
    this.title,
    this.date,
    this.time,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    
    // Figma design dimensions: 440px width
    final designWidth = 440.0;
    
    // Calculate scale based on width to maintain design proportions
    final scale = screenWidth / designWidth;
    
    // Common width for content (same as other pages)
    final contentWidth = 367 * scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: screenWidth,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2A2A), // Light gray at top left
              Colors.black, // Black at bottom right
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section: Back button and "Playing" text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40 * scale,
                        height: 40 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 28 * scale,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Playing',
                          style: GoogleFonts.manrope(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFD1D1D1),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40 * scale), // Balance the back button
                  ],
                ),
              ),
              
              SizedBox(height: 20 * scale),
              
              // Content container (constrained width like other pages)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36 * scale),
                    child: Column(
                      children: [
                        // Album art
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24 * scale),
                          child: Container(
                            width: contentWidth,
                            height: 350 * scale,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(24 * scale),
                    ),
                    child: thumbnailUrl != null
                        ? Image.network(
                            thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[800],
                                child: Icon(
                                  Icons.music_note,
                                  size: 100 * scale,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[800],
                            child: Icon(
                              Icons.music_note,
                              size: 100 * scale,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          ),
                        ),
                        
                        SizedBox(height: 20 * scale),
                        
                        // Action bar: Share, Playlist, Download
                        Container(
                          width: contentWidth,
                          height: 50 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Share icon
                              Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 24 * scale,
                              ),
                              // Playlist icon
                              Icon(
                                Icons.queue_music,
                                color: Colors.white,
                                size: 24 * scale,
                              ),
                              // Download icon
                              Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 24 * scale,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 24 * scale),
                        
                        // Song title
                        SizedBox(
                          width: contentWidth,
                          child: Text(
                            title ?? 'Imbaraga zimana zishobora byose',
                            style: GoogleFonts.manrope(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: 32 * scale),
                        
                        // Waveform and time
                        SizedBox(
                          width: contentWidth,
                          child: Column(
                            children: [
                              // Time display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '02:21',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '03:22',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * scale),
                              // Waveform visualization
                              SizedBox(
                                width: contentWidth,
                                height: 40 * scale,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: List.generate(50, (index) {
                                    final height = (20 + (index % 10) * 3) * scale;
                                    final isPlayed = index < 25; // First half is played
                                    return Container(
                                      width: 3 * scale,
                                      height: height,
                                      decoration: BoxDecoration(
                                        color: isPlayed 
                                            ? const Color(0xFFFF6B35) // Orange for played
                                            : Colors.white.withOpacity(0.3), // White for unplayed
                                        borderRadius: BorderRadius.circular(1.5 * scale),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      SizedBox(height: 40 * scale),
                      
                      // Playback controls
                      SizedBox(
                        width: contentWidth,
                        child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Rewind 10s
                    Container(
                      width: 50 * scale,
                      height: 50 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.replay_10,
                            color: Colors.white,
                            size: 24 * scale,
                          ),
                          Text(
                            '10',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10 * scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Previous track
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.skip_previous,
                        color: Colors.white,
                        size: 32 * scale,
                      ),
                    ),
                    
                    // Play button (large, prominent)
                    Container(
                      width: 70 * scale,
                      height: 70 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD1D1D1), // Light gray circle
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: 36 * scale,
                        ),
                      ),
                    ),
                    
                    // Next track
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.skip_next,
                        color: Colors.white,
                        size: 32 * scale,
                      ),
                    ),
                    
                    // Fast-forward 10s
                    Container(
                      width: 50 * scale,
                      height: 50 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 24 * scale,
                          ),
                          Text(
                            '10',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10 * scale,
                            ),
                          ),
                        ],
                      ),
                        ),
                      ],
                    ),
                  ),
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
}
