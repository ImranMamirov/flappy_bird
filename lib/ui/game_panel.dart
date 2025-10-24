import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flappy_bird/logic/game_logic.dart';

class GamePanel extends StatefulWidget {
  const GamePanel({Key? key}) : super(key: key);

  @override
  State<GamePanel> createState() => _GamePanelState();
}

class _GamePanelState extends State<GamePanel> {
  late GameLogic gameLogic;
  Timer? gameLoop;
  Timer? placePipeTimer;
  Timer? countdownTimer;

  ui.Image? background;
  ui.Image? birdImg;
  ui.Image? topPipeImg;
  ui.Image? bottomPipeImg;

  bool assetsLoaded = false;
  bool isGameStarted = false;
  int countdown = 0;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final futures = [
      _loadUiImage("assets/background.png"),
      _loadUiImage("assets/flappybird.png"),
      _loadUiImage("assets/toppipe.png"),
      _loadUiImage("assets/bottompipe.png"),
    ];

    final images = await Future.wait(futures);

    background = images[0];
    birdImg = images[1];
    topPipeImg = images[2];
    bottomPipeImg = images[3];

    gameLogic = GameLogic(
      360,
      640,
      34,
      38,
      birdImg!,
      64,
      512,
      640 ~/ 4,
      topPipeImg!,
      bottomPipeImg!,
    );

    setState(() => assetsLoaded = true);
  }

  void _startCountdown() {
    setState(() {
      countdown = 3;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 1) {
          countdown--;
        } else {
          countdownTimer?.cancel();
          countdown--;
          _startGame();
        }
      });
    });
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
      gameLogic.resetGame();
    });

    placePipeTimer?.cancel();
    gameLoop?.cancel();

    placePipeTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      setState(() {
        if (!gameLogic.gameOver) {
          gameLogic.addPipe();
        }
      });
    });

    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        if (!gameLogic.gameOver) {
          gameLogic.moveBird();
          gameLogic.movePipes();
        } else {
          gameLoop?.cancel();
          placePipeTimer?.cancel();
          _showDialog();
        }
      });
    });
  }

  Future<ui.Image> _loadUiImage(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void _onTap() {
    if (!isGameStarted) return;
    setState(() {
      if (!gameLogic.gameOver) {
        gameLogic.speedVertical = -7;
      }
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Игра окончена"),
          content: Text("Ваш счет ${gameLogic.score.toInt()}"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isGameStarted = false;
                });
                Navigator.of(context).pop();
              },
              child: const Text("В меню"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startCountdown();
                },
                child: const Text("Играть заново")
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!assetsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isGameStarted && countdown == 0) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (background != null)
            CustomPaint(
              size: const Size(360, 640),
              painter: _GamePainter(gameLogic, background!),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Flappy Bird",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                    onPressed: _startCountdown,
                    child: const Text("Играть")
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (countdown > 0) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            size: const Size(360, 640),
            painter: _GamePainter(gameLogic, background!),
          ),
          Center(
            child: Text(
              countdown.toString(),
              style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          )
        ],
      );
    }

    return GestureDetector(
      onTap: _onTap,
      child: CustomPaint(
        size: const Size(360, 640),
        painter: _GamePainter(gameLogic, background!),
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    placePipeTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }
}

class _GamePainter extends CustomPainter {
  final GameLogic gameLogic;
  final ui.Image background;

  _GamePainter(this.gameLogic, this.background);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    canvas.drawImageRect(
      background,
      Rect.fromLTWH(
        0,
        0,
        background.width.toDouble(),
        background.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    canvas.drawImageRect(
      gameLogic.bird.img,
      Rect.fromLTWH(
        0,
        0,
        gameLogic.bird.img.width.toDouble(),
        gameLogic.bird.img.height.toDouble(),
      ),
      Rect.fromLTWH(
        gameLogic.bird.horizontal.toDouble(),
        gameLogic.bird.vertical.toDouble(),
        gameLogic.bird.width.toDouble(),
        gameLogic.bird.height.toDouble(),
      ),
      paint,
    );

    for (var pipe in gameLogic.pipes) {
      canvas.drawImageRect(
        pipe.img,
        Rect.fromLTWH(
          0,
          0,
          pipe.img.width.toDouble(),
          pipe.img.height.toDouble(),
        ),
        Rect.fromLTWH(
          pipe.horizontal.toDouble(),
          pipe.vertical.toDouble(),
          pipe.width.toDouble(),
          pipe.height.toDouble(),
        ),
        paint,
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: gameLogic.score.toInt().toString(),
        style: const TextStyle(color: Colors.white, fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
