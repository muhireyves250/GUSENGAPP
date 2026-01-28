import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerPage extends StatefulWidget {
  final String? title;
  final String? date;
  final String? time;
  final String? thumbnailUrl;
  final String? audioUrl;

  const PlayerPage({
    super.key,
    this.title,
    this.date,
    this.time,
    this.thumbnailUrl,
    this.audioUrl,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to states
    _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
            setState(() {
                _isPlaying = state == PlayerState.playing;
            });
        }
    });

    // Listen to duration
    _audioPlayer.onDurationChanged.listen((newDuration) {
        if (mounted) {
            setState(() {
                _duration = newDuration;
            });
        }
    });

    // Listen to position
    _audioPlayer.onPositionChanged.listen((newPosition) {
        if (mounted) {
            setState(() {
                _position = newPosition;
            });
        }
    });
    
    _initAudio();
  }

  Future<void> _initAudio() async {
      if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
          try {
              // Replace localhost for Android emulator if needed, but ideally passed correctly from API
               // If source is like 'http://localhost:5000/...', android emulator needs '10.0.2.2'
               // But the API returns full URL. 
               // If the API returns 'http://localhost:5000/uploads/...', we need to fix it here or in API.
               // API logic: const serverUrl = `${req.protocol}://${req.get('host')}`;
               // req.get('host') will be 'localhost:5000' or '10.0.2.2:5000' depending on who calls it?
               // Actually if phone calls it via 10.0.2.2, host header is 10.0.2.2.
               // So URL should be correct.
               // For external URLs (SoundHelix), it's fine.
              await _audioPlayer.setSourceUrl(widget.audioUrl!);
              _isInit = true;
          } catch (e) {
              debugPrint("Error loading audio: $e");
          }
      }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
  
  String _formatDurationShort(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return "$twoDigitMinutes:$twoDigitSeconds";
  }

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
              
              // Content container
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
                    child: widget.thumbnailUrl != null
                        ? Image.network(
                            widget.thumbnailUrl!,
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
                            widget.title ?? 'Unknown Title',
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
                        
                        // Slider and time
                        SizedBox(
                          width: contentWidth,
                          child: Column(
                            children: [
                              // Time display
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDurationShort(_position),
                                    style: GoogleFonts.manrope(
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _formatDurationShort(_duration),
                                    style: GoogleFonts.manrope(
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8 * scale),
                              
                              // Slider (replacing static waveform for functionality)
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFFFF6B35),
                                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                                    thumbColor: const Color(0xFFFF6B35),
                                    trackHeight: 4 * scale,
                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6 * scale),
                                ),
                                child: Slider(
                                    min: 0,
                                    max: _duration.inSeconds.toDouble(),
                                    value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                                    onChanged: (value) async {
                                        final position = Duration(seconds: value.toInt());
                                        await _audioPlayer.seek(position);
                                        await _audioPlayer.resume(); // Auto play after seek
                                    },
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
                    GestureDetector(
                      onTap: () {
                          final newPos = _position - const Duration(seconds: 10);
                          _audioPlayer.seek(newPos < Duration.zero ? Duration.zero : newPos);
                      },
                      child: Container(
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
                    
                    // Play/Pause button (large, prominent)
                    GestureDetector(
                      onTap: () async {
                          if (_isPlaying) {
                              await _audioPlayer.pause();
                          } else {
                              if (_duration == Duration.zero && !_isInit) {
                                  // Retry init or just play which might internally init
                                  if (widget.audioUrl != null) {
                                      await _audioPlayer.play(UrlSource(widget.audioUrl!));
                                      _isInit = true;
                                  }
                              } else {
                                  await _audioPlayer.resume();
                              }
                          }
                      },
                      child: Container(
                        width: 70 * scale,
                        height: 70 * scale,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD1D1D1), // Light gray circle
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
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
                    GestureDetector(
                         onTap: () {
                          final newPos = _position + const Duration(seconds: 10);
                          _audioPlayer.seek(newPos > _duration ? _duration : newPos);
                      },
                      child: Container(
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

