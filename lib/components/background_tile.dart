import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/rendering.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class BackgroundTile extends ParallaxComponent<PixelAdventure> {
  final String color;

  BackgroundTile({this.color = 'Gray', super.position});

  final double scrollSpeed = 40; // Speed of the scrolling background

  @override
  FutureOr<void> onLoad() async {
    priority =
        -10; // Set the rendering priority to ensure it renders behind other components
    size = Vector2.all(64); // Set the size of the tile
    // game viene de ParallaxComponent que extiende de HasGameReference, no de HasGameRef que esta deprecado
    parallax = await game.loadParallax(
      [ParallaxImageData('Background/$color.png')],
      baseVelocity: Vector2(
        0,
        -scrollSpeed,
      ), // Set the base velocity for scrolling
      repeat: ImageRepeat.repeat, // Repeat the background image
      fill: LayerFill.none, // Do not fill the entire screen with the background
    ); // Use the passed game referenceendering
    return super.onLoad();
  }
}
