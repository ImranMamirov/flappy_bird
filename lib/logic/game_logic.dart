import 'dart:math';
import 'dart:ui' as ui;
import 'package:flappy_bird/ui/bird.dart';
import 'package:flappy_bird/ui/pipe.dart';

class GameLogic {
  final int boardWidth;
  final int boardHeight;
  final int pipeWidth;
  final int pipeHeight;
  final int openingSpace;
  final ui.Image topPipeImg;
  final ui.Image bottomPipeImg;

  int speedHorizontal = -4;
  double gravity = 0.5;
  double speedVertical = 0;
  bool gameOver = false;
  double score = 0.0;

  final Bird bird;
  final List<Pipe> pipes = [];

  GameLogic(
      this.boardWidth,
      this.boardHeight,
      int birdWidth,
      int birdHeight,
      ui.Image birdImg,
      this.pipeWidth,
      this.pipeHeight,
      this.openingSpace,
      this.topPipeImg,
      this.bottomPipeImg,
      ) : bird = Bird(boardWidth ~/ 8, boardHeight ~/ 2, birdWidth, birdHeight, birdImg);

  void moveBird() {
    speedVertical += gravity;
    bird.vertical += speedVertical.toInt();
  }

  void movePipes() {
    for (var pipe in pipes) {
      pipe.horizontal += speedHorizontal;
      if (!pipe.passed && bird.horizontal > pipe.horizontal + pipe.width) {
        score += 0.5;
        pipe.passed = true;
      }
      if (bird.checkCollision(pipe)) {
        gameOver = true;
      }
    }
    if (bird.vertical > boardHeight) {
      gameOver = true;
    }
  }

  void resetGame() {
    bird.resetPosition(boardHeight ~/ 2);
    speedVertical = 0;
    pipes.clear();
    gameOver = false;
    score = 0.0;
  }















































  void addPipe() {
    final random = Random();
    final randomPipeY = (-boardHeight ~/ 4 - random.nextInt(pipeHeight ~/ 2));
    pipes.add(Pipe(boardWidth, randomPipeY, pipeWidth, pipeHeight, topPipeImg));
    pipes.add(Pipe(
      boardWidth,
      randomPipeY + pipeHeight + openingSpace,
      pipeWidth,
      pipeHeight,
      bottomPipeImg,
    ));
  }
}
