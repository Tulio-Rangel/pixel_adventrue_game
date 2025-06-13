import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

enum PlayerState {
  idle, // Player is idle
  running, // Player is running
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  Player({position, required this.character}) : super(position: position) {
    // Initialize the player with a specific position and character
  }

  String character;
  late final SpriteAnimation idleAnimation; // Animation for idle state
  late final SpriteAnimation runningAnimation; // Animation for running state
  final double stepTime = 0.05; // Time between frames in seconds

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
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
}
