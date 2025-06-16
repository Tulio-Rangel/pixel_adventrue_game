import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/src/services/hardware_keyboard.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

enum PlayerState {
  idle, // Player is idle
  running, // Player is running
}

enum PlayerDirection {
  left, // Player is facing left
  right, // Player is facing right
  up, // Player is facing up
  down, // Player is facing down
  none, // Player is not facing any direction
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  Player({position, required this.character}) : super(position: position) {
    // Initialize the player with a specific position and character
  }

  String character;
  late final SpriteAnimation idleAnimation; // Animation for idle state
  late final SpriteAnimation runningAnimation; // Animation for running state
  final double stepTime = 0.05; // Time between frames in seconds

  PlayerDirection playerDirection =
      PlayerDirection.none; // Current direction of the player
  double moveSpeed = 100; // Movement speed of the player in pixels per second
  Vector2 velocity = Vector2.zero(); // Current velocity of the player
  bool isFacingRight = true; // Whether the player is facing right

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPress =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);

    final isRightKeyPress =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    if (isLeftKeyPress && isRightKeyPress) {
      playerDirection =
          PlayerDirection.none; // No movement if both keys are pressed
    } else if (isLeftKeyPress) {
      playerDirection = PlayerDirection.left; // Move left
    } else if (isRightKeyPress) {
      playerDirection = PlayerDirection.right; // Move right
    } else {
      playerDirection = PlayerDirection.none; // No movement
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11); // Load the idle animation

    runningAnimation = _spriteAnimation(
      'Run',
      12,
    ); // Load the running animation

    // Define a map of animations for different player states
    animations = {
      PlayerState.idle:
          idleAnimation, // Map the idle state to the idle animation
      PlayerState.running:
          runningAnimation, // Map the running state to the running animation
    };

    current = PlayerState.idle; // Set the current animation
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount, // Number of frames in the animation
        stepTime: stepTime, // Time per frame
        textureSize: Vector2.all(32), // Size of each frame in pixels
        loop: true, // Loop the animation
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;
    switch (PlayerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          // Flip the sprite if changing direction from right to left
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running; // Set the state to running when moving
        dirX -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          // Flip the sprite if changing direction from left to right
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running; // Set the state to running when moving
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle; // Set the state to idle when not moving
        break;
      default:
    }

    velocity = Vector2(dirX, 0); // Update the velocity based on direction
    position +=
        velocity *
        dt; // Update the player's position based on velocity and delta time
  }
}
