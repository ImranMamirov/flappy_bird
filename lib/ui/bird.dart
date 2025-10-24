import 'dart:ui' as ui;
import 'package:flappy_bird/ui/bird.dart';
import 'package:flappy_bird/ui/pipe.dart';

class Bird {
  int horizontal;
  int vertical;
  int width;
  int height;
  ui.Image img;

  Bird(this.horizontal, this.vertical, this.width, this.height, this.img);

  bool checkCollision(Pipe pipe) {
    return horizontal < pipe.horizontal + pipe.width &&
        horizontal + width > pipe.horizontal &&
        vertical < pipe.vertical + pipe.height &&
        vertical + height > pipe.vertical;
  }

  void resetPosition(int startY) {
    vertical = startY;
  }
}