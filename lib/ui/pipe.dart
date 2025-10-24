import 'dart:ui' as ui;
import 'package:flappy_bird/ui/pipe.dart';

class Pipe {
  int horizontal;
  int vertical;
  int width;
  int height;
  ui.Image img;
  bool passed = false;

  Pipe(this.horizontal, this.vertical, this.width, this.height, this.img);
}