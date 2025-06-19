import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({this.color = 'Gray', position}) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    priority = -1; // Set the priority for rendering
    size = Vector2.all(64); // Set the size of the tile
    sprite = Sprite(
      game.images.fromCache('Background/$color.png'),
    ); // Load the sprite from the cache
    return super.onLoad();
  }
}
