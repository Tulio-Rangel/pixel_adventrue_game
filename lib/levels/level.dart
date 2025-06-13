import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure_game/actors/player.dart';

class Level extends World {
  final String levelName;
  Level({required this.levelName});

  late TiledComponent level; // Tiled component to hold the loaded map

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      '$levelName.tmx', // Path to the Tiled map file
      Vector2.all(16), // Tile size in pixels
    ); // Load the Tiled map

    add(level); // Add the loaded Tiled component to the world

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>(
      'Spawnpoints',
    ); // Get the spawn points layer from the Tiled map

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case 'Player':
          final player = Player(
            character: 'Ninja Frog',
            position: Vector2(
              spawnPoint.x,
              spawnPoint.y,
            ), // Set the player's position based on the spawn point
          );
          add(player); // Add the player character to the world
          break;
        default:
      }
    }

    return super.onLoad();
  }
}
