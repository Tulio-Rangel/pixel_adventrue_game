import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:pixel_adventure_game/game/utils/cutom_hitbox.dart';
import 'package:pixel_adventure_game/game/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  Fruit({this.fruit = 'Apple', super.position, super.size});

  final double stepTime = 0.05; // Time between frames in seconds
  final hitbox = CustomHitbox(offsetX: 10, offsetY: 10, width: 12, height: 12);
  bool collected = false; // Flag to check if the fruit is collected

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    priority = -1; // Set the priority for rendering

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive, // Set collision type to passive
      ),
    ); // Add a hitbox for collision detection

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

  void collidedWithPlayer() async {
    if (!collected) {
      collected = true; // Set the collected flag to true
      if (game.playSound) {
        FlameAudio.play('collect_fruit.wav', volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/Collected.png'),
        SpriteAnimationData.sequenced(
          amount: 6, // Number of frames in the animation
          stepTime: stepTime, // Time between frames
          textureSize: Vector2.all(32), // Size of each frame in pixels
          loop: false,
        ),
      );

      await animationTicker?.completed; // Stop the current animation ticker
      removeFromParent(); // Remove the fruit from the game
    }
  }
}
