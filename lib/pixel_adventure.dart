import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure_game/actors/player.dart';
import 'package:pixel_adventure_game/levels/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30); // Set the background color of the game
  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true; // Flag to control joystick visibility

  @override
  FutureOr<void> onLoad() async {
    await images
        .loadAllImages(); // Load all images used in the game (into cache)

    final world = Level(
      player: player,
      levelName: 'Level-04',
    ); // Create an instance of Level

    cam = CameraComponent.withFixedResolution(
      world: world, // Use the world from the game
      width: 640,
      height: 360,
    ); // Create a camera with a fixed resolution
    cam.viewfinder.anchor =
        Anchor.topLeft; // Set the camera's anchor to the top-left corner

    // cam.viewfinder.zoom = 0.5; // Set the camera's zoom level

    addAll([cam, world]); // Add the camera and world to the game

    if (showJoystick) {
      addJoystick(); // Add a joystick for player control
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoistick();
    }
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
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
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      default:
        player.playerDirection = PlayerDirection.none;
        break;
    }
  }
}
