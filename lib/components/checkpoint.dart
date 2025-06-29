import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_game/components/player.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure>, CollisionCallbacks {
  Checkpoint({super.position, super.size});

  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    add(
      RectangleHitbox(
        position: Vector2(18, 18),
        size: Vector2(12, 48),
        collisionType: CollisionType.passive,
      ),
    ); //18,56 y 12,8

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 1,
        textureSize: Vector2.all(64),
      ),
    );
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Player) _reachedCheckpoint();
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
        loop: false,
      ),
    );

    await animationTicker?.completed; // Wait for the animation to complete

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png',
      ),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: 0.05,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
