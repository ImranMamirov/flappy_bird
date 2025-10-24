import 'package:flutter/material.dart';
import 'package:flappy_bird/ui/game_panel.dart';

void main() {
  runApp(const FlappyBirdApp());
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: 360,
            height: 640,
            child: const GamePanel(),
          ),
        ),
      ),
    );
  }
}
