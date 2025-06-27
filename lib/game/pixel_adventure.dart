import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure_game/ui/buttons/jump_button.dart';
import 'package:pixel_adventure_game/game/components/actors/player.dart';
import 'package:pixel_adventure_game/game/components/world/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Set the background color of the game
  late CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;
  bool showControls = true; // Flag to control joystick visibility
  bool playSound = true; // Flag to control sound playback
  double soundVolume = 1.0; // Volume of the sound playback
  List<String> levelNames = ['Level-06', 'Level-06']; // List of level names
  int currentLevelIndex = 0; // Index of the current level

  @override
  FutureOr<void> onLoad() async {
    await images
        .loadAllImages(); // Load all images used in the game (into cache)

    _loadLevel(); // Load the level

    if (showControls) {
      addJoystick(); // Add a joystick for player control
      add(JumpButton()); // Add the jump button component to the game
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoistick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      priority: 10,
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/Knob.png'), // Load the joystick knob sprite
        ),
      ),
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache(
            'HUD/Joystick.png',
          ), // Load the joystick background sprite
        ),
      ),
      margin: const EdgeInsets.only(
        left: 5,
        bottom: 32,
      ), // Set the margin for the joystick
    ); // Create a joystick component with a directional joystick

    add(joystick); // Add the joystick to the game
  }

  void updateJoistick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1; // Move player left
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1; // Move player right
        break;
      default:
        player.horizontalMovement = 0; // Stop player movement
        break;
    }
  }

  void loadNextLevel() {
    removeWhere(
      (component) => component is Level,
    ); // Remove the current level from the game

    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++; // Increment the level index
      _loadLevel(); // Load the next level
    } else {
      currentLevelIndex = 0; // Reset to the first level if at the end
      _loadLevel(); // Load the first level again
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex], // Get the current level name
      ); // Create an instance of Level

      cam = CameraComponent.withFixedResolution(
        world: world, // Use the world from the game
        width: 640,
        height: 360,
      ); // Create a camera with a fixed resolution
      cam.viewfinder.anchor =
          Anchor.topLeft; // Set the camera's anchor to the top-left corner

      // cam.viewfinder.zoom = 0.25; // Set the camera's zoom level

      addAll([cam, world]); // Add the camera and world to the game
    });
  }
}
