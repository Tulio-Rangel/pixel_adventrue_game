import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_game/components/player.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  bool checkedCheckpoint = false; // To track if the checkpoint has been reached

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player && !checkedCheckpoint) _reachedCheckpoint();
    super.onCollision(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    checkedCheckpoint = true;
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
  }
}
