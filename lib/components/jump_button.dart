import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton();

  final marginBotton = 32.0; // Margin from the bottom edge of the screen
  final marginRight = 8.0; // Margin from the bottom edge of the screen
  final buttonSize = 64.0; // Size of the jump button

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(
      gameRef.images.fromCache(
        'HUD/JumpButton.png',
      ), // Load the jump button sprite
    );
    position = Vector2(
      game.size.x -
          marginRight -
          buttonSize, // Position the button on the right side of the screen
      game.size.y -
          marginBotton -
          buttonSize, // Position the button at the bottom of the screen
    );
    // margin:
    // EdgeInsets.only(right: 8, bottom: 32); // Set the margin for the jump button
    priority = 1000000; // Set the priority for rendering
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped =
        true; // Trigger the jump action when the button is pressed
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped =
        false; // Reset the jump action when the button is released
    super.onTapUp(event);
  }
}
