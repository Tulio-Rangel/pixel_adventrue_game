import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  final String fruit;
  Fruit({this.fruit = 'Apple', position, size})
    : super(position: position, size: size);

  final double stepTime = 0.05; // Time between frames in seconds

  @override
  FutureOr<void> onLoad() {
    priority = -1; // Set the priority for rendering
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Items/Fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: 17, // Number of frames in the animation
        stepTime: stepTime, // Time between frames
        textureSize: Vector2.all(32), // Size of each frame in pixels
      ),
    );
    return super.onLoad();
  }
}
