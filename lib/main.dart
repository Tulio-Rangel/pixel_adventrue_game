import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before running the app
  Flame.device.fullScreen(); // Sets the app to full screen mode
  Flame.device.setLandscape(); // Sets the app to landscape mode

  PixelAdventure game = PixelAdventure();
  runApp(GameWidget(game: game));
}
