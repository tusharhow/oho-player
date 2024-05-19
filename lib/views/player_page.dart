import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oho_player/dummy_data/song_data.dart';
import 'package:oho_player/util/duration_util.dart';
import 'dart:math' as math;

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();

  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isPlaying = true;
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 30));

  int currentIndex = 0;
  double currentPosition = 0;
  @override
  void initState() {
    super.initState();
    startPlayer();
    player.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    player.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    player.onPositionChanged.listen((event) {
      setState(() {
        currentPosition = event.inSeconds.toDouble();
        print('Current Position: $currentPosition ');
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }

  void startPlayer() async {
    try {
      await player.setSource(AssetSource(audioFiles[currentIndex]));
      player.play(AssetSource(audioFiles[currentIndex]));
    } catch (e) {
      rethrow;
    }
  }

  void playNext() {
    setState(() {
      currentIndex = (currentIndex + 1) % audioFiles.length;
    });
    startPlayer();
  }

  void playPrevious() {
    setState(() {
      currentIndex = (currentIndex - 1 + audioFiles.length) % audioFiles.length;
    });
    startPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 130,
              width: MediaQuery.of(context).size.width - 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(2, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    titles[currentIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    artists[currentIndex],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16 * 7.5, right: 16),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: currentPosition / duration.inSeconds,
                        backgroundColor: Colors.white38,
                        valueColor: const AlwaysStoppedAnimation(Colors.cyan),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        durationFormat(position),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ' | ',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        durationFormat(duration),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Positioned(
              bottom: -80,
              left: -30,
              right: -30,
              child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(2, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          playPrevious();
                        },
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isPlaying) {
                            player.pause();
                          } else {
                            player.play(AssetSource(audioFiles[currentIndex]));
                          }
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          playNext();
                        },
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )),
            ),
            Positioned(
              top: 10,
              left: -16,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  if (!isPlaying) {
                    _animationController.stop();
                  } else {
                    if (mounted) {
                      _animationController.repeat();
                    }
                  }
                  return Transform.rotate(
                    angle: _animationController.value * 2 * math.pi,
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        maxRadius: 55,
                        backgroundImage: AssetImage(
                          posters[currentIndex],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black45, width: 1),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
