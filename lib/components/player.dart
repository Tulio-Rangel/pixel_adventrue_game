import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure_game/components/collision_block.dart';
import 'package:pixel_adventure_game/components/utils.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

enum PlayerState {
  idle, // Player is idle
  running, // Player is running
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  Player({position, this.character = 'Ninja Frog'})
    : super(position: position) {
    // Initialize the player with a specific position and character
  }

  String character;
  late final SpriteAnimation idleAnimation; // Animation for idle state
  late final SpriteAnimation runningAnimation; // Animation for running state
  final double stepTime = 0.05; // Time between frames in seconds

  double horizontalMovement = 0; // Horizontal movement input
  double moveSpeed = 100; // Movement speed of the player in pixels per second
  Vector2 velocity = Vector2.zero(); // Current velocity of the player
  List<CollisionBlock> collisionBlocks = []; // List of collision blocks

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = true; // Enable debug mode for the player component
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0; // Reset horizontal movement

    final isLeftKeyPress =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);

    final isRightKeyPress =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    horizontalMovement += isLeftKeyPress
        ? -1
        : isRightKeyPress
        ? 1
        : 0; // Update horizontal movement based on key presses

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
    velocity.x = horizontalMovement * moveSpeed; // Set horizontal velocity
    position.x +=
        velocity.x *
        dt; // Update the player's position based on velocity and delta time
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle; // Default player state

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter(); // Flip the player horizontally if moving left
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter(); // Flip the player horizontally if moving right
    }

    // check if the player is moving, set running state
    if (velocity.x.abs() > 0) {
      playerState = PlayerState.running; // Set to running state if moving
    }

    current = playerState; // Set the current animation state
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0; // Stop movement if colliding on the right
            position.x =
                block.x - width; // Move player to the left of the block
          }
          if (velocity.x < 0) {
            velocity.x = 0; // Stop movement if colliding on the left
            position.x =
                block.x +
                block.width +
                width; // Move player to the right of the block
          }
        }
      }
    }
  }
}
