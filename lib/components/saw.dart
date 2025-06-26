import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class Saw extends SpriteAnimationComponent
    with HasGameReference<PixelAdventure> {
  final bool isVertial; // Flag to check if the saw is vertical
  final double offNeg;
  final double offPos;
  Saw({
    this.isVertial = false,
    this.offNeg = 0,
    this.offPos = 0,
    super.position,
    super.size,
  });

  static const double sawSpeed = 0.03; // Time between frames in seconds
  static const moveSpeed = 100;
  static const tileSize = 16.0; // Size of each tile in pixels
  double moveDirection =
      1; // Direction of movement (1 for right/down, -1 for left/up)
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1; // Set the priority for rendering
    add(CircleHitbox()); // Add a hitbox for collision detection
    debugMode = false;

    if (isVertial) {
      rangeNeg = position.y - offNeg * tileSize; // Range for vertical movement
      rangePos = position.y + offPos * tileSize; // Range for vertical movement
    } else {
      rangeNeg =
          position.x - offNeg * tileSize; // Range for horizontal movement
      rangePos =
          position.x + offPos * tileSize; // Range for horizontal movement
    }

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: sawSpeed,
        textureSize: Vector2.all(38),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertial) {
      _moveVertically(dt);
    } else {
      _moveHorizontally(dt);
    }
    super.update(dt);
  }

  void _moveVertically(double dt) {
    if (position.y >= rangePos) {
      moveDirection = -1; // Change direction to up if at the top range
    } else if (position.y <= rangeNeg) {
      moveDirection = 1; // Change direction to down if at the bottom range
    }
    position.y += moveDirection * moveSpeed * dt;
  }

  void _moveHorizontally(double dt) {
    if (position.x >= rangePos) {
      moveDirection = -1; // Change direction to left if at the right range
    } else if (position.x <= rangeNeg) {
      moveDirection = 1; // Change direction to right if at the left range
    }
    position.x += moveDirection * moveSpeed * dt;
  }
}
