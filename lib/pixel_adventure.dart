import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure_game/levels/level.dart';

class PixelAdventure extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Set the background color of the game
  late final CameraComponent cam;

  final world = Level(levelName: 'Level-04'); // Create an instance of Level

  @override
  FutureOr<void> onLoad() async {
    await images
        .loadAllImages(); // Load all images used in the game (into cache)

    cam = CameraComponent.withFixedResolution(
      world: world, // Use the world from the game
      width: 640,
      height: 360,
    ); // Create a camera with a fixed resolution
    cam.viewfinder.anchor =
        Anchor.topLeft; // Set the camera's anchor to the top-left corner

    addAll([cam, world]); // Add the camera and world to the game
    return super.onLoad();
  }
}
