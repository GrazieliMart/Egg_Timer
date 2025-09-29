import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const EggTimerApp());
}

class EggTimerApp extends StatelessWidget {
  const EggTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egg Timer',
      theme: ThemeData(
        fontFamily: 'PixelFont',
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFFFFF1A8),
      ),
      debugShowCheckedModeBanner: false,
      home: const StartScreen(),
    );
  }
}

Future<void> playSound(String assetPath) async {
  try {
    final player = AudioPlayer();
    await player.play(AssetSource(assetPath)); 
    debugPrint("Tocando som: $assetPath");
  } catch (e) {
    debugPrint("Erro ao tocar som: $e");
  }
}

/// Tela inicial
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF2A84B), width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/egg-timer.png", height: 80),
                    const SizedBox(height: 30),
                    Image.asset("assets/images/medium-hard-egg.png", height: 320),
                    const SizedBox(height: 20),
                    const Text("Let's time your egg!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () async {
                        await playSound("sounds/click.mp3");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MenuScreen()),
                        );
                      },
                      child: Image.asset("assets/images/start.png", height: 60),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset("assets/images/close-btn.png", height: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela do menu de escolha de ovo
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                height: 500,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF2A84B), width: 3),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 52),
                    const Text("What are you making today?",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 18),
                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: [
                          _eggOption(context, "Soft yolk egg", 1, "soft-egg.png"),
                          _eggOption(context, "Medium yolk egg", 6, "medium-egg.png"),
                          _eggOption(context, "Med/Hard yolk egg", 8, "medium-hard-egg.png"),
                          _eggOption(context, "Hard yolk egg", 10, "hard-egg.png"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 56,
              right: 46,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset("assets/images/close-btn.png", height: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eggOption(BuildContext context, String title, int minutes, String image) {
    return GestureDetector(
      onTap: () async {
        await playSound("sounds/click.mp3");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TimerScreen(minutes: minutes, title: title)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6DF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF2A84B), width: 3),
          boxShadow: const [BoxShadow(blurRadius: 2, offset: Offset(0, 1))],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/$image", height: 80),
            const SizedBox(height: 8),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Tela do timer
class TimerScreen extends StatefulWidget {
  final int minutes;
  final String title;

  const TimerScreen({super.key, required this.minutes, required this.title});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.minutes * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        playSound("sounds/done.mp3");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EndScreen()),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, "0");
    final sec = (seconds % 60).toString().padLeft(2, "0");
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6DF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2A84B), width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Text(widget.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Image.asset("assets/images/timer.gif", height: 240),
                      Text(_formatTime(_remainingSeconds),
                          style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2)),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                        child: Image.asset("assets/images/cancel.png", height: 50),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset("assets/images/close-btn.png", height: 40),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela final
class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF2A84B), width: 3),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/end.png", height: 150),
                    const SizedBox(height: 20),
                    const Text("Your egg is done!",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await playSound("sounds/click.mp3");
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          child: Image.asset("assets/images/close.png", height: 50),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () async {
                            await playSound("sounds/click.mp3");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const TimerScreen(minutes: 1, title: "Snooze")),
                            );
                          },
                          child: Image.asset("assets/images/snooze.png", height: 50),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset("assets/images/close-btn.png", height: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
