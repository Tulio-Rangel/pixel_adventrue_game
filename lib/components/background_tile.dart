import 'dart:async';

import 'package:flame/components.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({this.color = 'Gray', position}) : super(position: position);

  final double scrollSpeed = 0.5; // Speed of the scrolling background

  @override
  FutureOr<void> onLoad() {
    priority = -1; // Set the priority for rendering
    size = Vector2.all(64); // Set the size of the tile
    sprite = Sprite(
      game.images.fromCache('Background/$color.png'),
    ); // Load the sprite from the cache
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollSpeed;
    double tileSize = 64; // Size of the tile in pixels
    int scrollHigh = (game.size.y / tileSize)
        .floor(); // Number of tiles that fit in the screen height
    if (position.y > scrollHigh * tileSize) position.y = -tileSize;
    super.update(dt);
  }
}
