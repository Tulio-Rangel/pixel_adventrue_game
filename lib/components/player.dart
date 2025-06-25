import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure_game/components/collision_block.dart';
import 'package:pixel_adventure_game/components/cutom_hitbox.dart';
import 'package:pixel_adventure_game/components/fruit.dart';
import 'package:pixel_adventure_game/components/saw.dart';
import 'package:pixel_adventure_game/components/utils.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

enum PlayerState {
  idle, // Player is idle
  running, // Player is running
  jumping, // Player is jumping
  falling, // Player is falling
  hit, // Player is hit
  appearing, // Player is appearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({position, this.character = 'Ninja Frog'})
    : super(position: position) {
    // Initialize the player with a specific position and character
  }

  final double stepTime = 0.05; // Time between frames in seconds
  late final SpriteAnimation idleAnimation; // Animation for idle state
  late final SpriteAnimation runningAnimation; // Animation for running state
  late final SpriteAnimation jumpingAnimation; // Animation for jumping state
  late final SpriteAnimation fallingAnimation; // Animation for falling state
  late final SpriteAnimation hitAnimation; // Animation for falling state
  late final SpriteAnimation
  appearingAnimation; // Animation for appearing state

  final double _gravity = 9.8;
  final double _jumpForce = 460; // Force applied when jumping
  final double _terminalVelocity = 300; // Maximum falling speed

  double horizontalMovement = 0; // Horizontal movement input
  double moveSpeed = 100; // Movement speed of the player in pixels per second
  Vector2 startingPosition = Vector2.zero(); // Starting position of the player
  Vector2 velocity = Vector2.zero(); // Current velocity of the player
  bool isOnGround = false; // Flag to check if the player is on the ground
  bool hasJumped = false; // Flag to check if the player has jumped
  bool gotHit = false; // Flag to check if the player got hit
  List<CollisionBlock> collisionBlocks = []; // List of collision
  CustomHitbox hitbox = CustomHitbox(
    offsetX: 10,
    offsetY: 4,
    width: 14,
    height: 28,
  ); // Player hitbox for collision detection

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = false; // Enable debug mode for the player component

    startingPosition = Vector2(
      position.x,
      position.y,
    ); // Store the starting position

    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
      ),
    ); // Add a hitbox for collision detection
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!gotHit) {
      _updatePlayerState();
      _updatePlayerMovement(dt);
      _checkHorizontalCollisions();
      _applyGravity(dt); // Apply gravity to the player
      _checkVerticalCollisions(); // Check for vertical collisions
    }

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

    hasJumped = keysPressed.contains(
      LogicalKeyboardKey.space,
    ); // Check if the jump key is pressed

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.collidedWithPlayer(); // Handle collision with fruit
    }
    if (other is Saw) _respawn(); // Respawn player if colliding with a saw

    super.onCollision(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11); // Load the idle animation

    runningAnimation = _spriteAnimation(
      'Run',
      12,
    ); // Load the running animation

    jumpingAnimation = _spriteAnimation(
      'Jump',
      1,
    ); // Load the jumping animation (single frame)

    fallingAnimation = _spriteAnimation(
      'Fall',
      1,
    ); // Load the falling animation (single frame)

    hitAnimation = _spriteAnimation(
      'Hit',
      7,
    ); // Load the hit animation (single frame)

    appearingAnimation = _specialSpriteAnimation('Appearing', 7);

    // Define a map of animations for different player states
    animations = {
      PlayerState.idle:
          idleAnimation, // Map the idle state to the idle animation
      PlayerState.running:
          runningAnimation, // Map the running state to the running animation
      PlayerState.jumping:
          jumpingAnimation, // Map the jumping state to the jumping animation
      PlayerState.falling:
          fallingAnimation, // Map the falling state to the falling animation
      PlayerState.hit: hitAnimation, // Map the hit state to the hit animation
      PlayerState.appearing: appearingAnimation, // Map the appearing state
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

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount, // Number of frames in the animation
        stepTime: stepTime, // Time per frame
        textureSize: Vector2.all(96), // Size of each frame in pixels
        loop: true, // Loop the animation
      ),
    );
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) playerJump(dt); // Handle player jumping

    //* Con este bloque evitamos el salto en el aire, remover los comentarios si no queremos salto en el aire.
    // if (velocity.y > _gravity) {
    //   isOnGround = false; // Reset ground state if falling
    // }

    velocity.x = horizontalMovement * moveSpeed; // Set horizontal velocity
    position.x +=
        velocity.x *
        dt; // Update the player's position based on velocity and delta time
  }

  void playerJump(double dt) {
    velocity.y = -_jumpForce; // Apply jump force to the player
    position.y += velocity.y * dt; // Update the player's position
    isOnGround = false; // Set player on ground flag to false
    hasJumped = false; // Reset the jump flag
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

    // check if the player is falling
    if (velocity.y > 0) playerState = PlayerState.falling;

    // check if the player is jumping
    if (velocity.y < 0) playerState = PlayerState.jumping;

    current = playerState; // Set the current animation state
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0; // Stop movement if colliding on the right
            position.x =
                block.x -
                hitbox.offsetX -
                hitbox.width; // Move player to the left of the block
            break; // Exit loop after collision
          }
          if (velocity.x < 0) {
            velocity.x = 0; // Stop movement if colliding on the left
            position.x =
                block.x +
                block.width +
                hitbox.width +
                hitbox.offsetX; // Move player to the right of the block
            break; // Exit loop after collision
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(
      -_jumpForce,
      _terminalVelocity,
    ); // Limit the vertical velocity
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0; // Stop downward movement
            position.y =
                block.y -
                hitbox.height -
                hitbox.offsetY; // Move player above the platform
            isOnGround = true; // Set player on ground flag
            break; // Exit loop after collision
          }
          // if (velocity.y < 0) {
          //   velocity.y = 0; // Stop upward movement
          //   position.y = block.y + block.height; // Move player below the platform
          //   break; // Exit loop after collision
          // }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y =
                block.y -
                hitbox.height -
                hitbox.offsetY; // Move player above the block
            isOnGround = true; // Set player on ground flag
            break; // Exit loop after collision
          }
          if (velocity.y < 0) {
            velocity.y = 0; // Stop upward movement
            position.y =
                block.y +
                block.height -
                hitbox.offsetY; // Move player below the block
            break; // Exit loop after collision
          }
        }
      }
    }
  }

  void _respawn() {
    const hitDuration = Duration(
      milliseconds: 50 * 7,
    ); // Duration of hit animation // 50 miliseconds per frame * 7 frames
    const appearingDuration = Duration(
      milliseconds: 50 * 7,
    ); // Duration of appearing animation // 50 miliseconds per frame * 7 frames
    const canMoveDuration = Duration(microseconds: 400);
    gotHit = true; // Set the hit flag to true
    current = PlayerState.hit; // Set the player state to hit
    Future.delayed(hitDuration, () {
      scale.x = 1; // Reset the scale to normal after hit
      position = startingPosition - Vector2.all(32);
      current = PlayerState.appearing; // Set the player state to appearing
      Future.delayed(appearingDuration, () {
        velocity = Vector2.zero(); // Reset the velocity after appearing
        position = startingPosition; // Reset the position to the starting point
        _updatePlayerState(); // Update the player state after appearing
        Future.delayed(
          canMoveDuration,
          () => gotHit = false,
        ); // Reset the hit flag after appearing
      });
    });
  }
}
