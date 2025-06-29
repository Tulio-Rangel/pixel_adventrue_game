import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure_game/components/background_tile.dart';
import 'package:pixel_adventure_game/components/checkpoint.dart';
import 'package:pixel_adventure_game/components/collision_block.dart';
import 'package:pixel_adventure_game/components/enemy.dart';
import 'package:pixel_adventure_game/components/fruit.dart';
import 'package:pixel_adventure_game/components/player.dart';
import 'package:pixel_adventure_game/components/saw.dart';
import 'package:pixel_adventure_game/pixel_adventure.dart';

class Level extends World with HasGameReference<PixelAdventure> {
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});

  late TiledComponent level; // Tiled component to hold the loaded map
  List<CollisionBlock> collisionBlocks = []; // List to hold collision blocks

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load(
      '$levelName.tmx', // Path to the Tiled map file
      Vector2.all(16), // Tile size in pixels
    ); // Load the Tiled map

    add(level); // Add the loaded Tiled component to the world

    _scrollingBackground(); // Initialize the scrolling background
    _spawningObjects(); // Spawn objects in the level
    _addCollisions(); // Add collision blocks to the level

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('Background');

    if (backgroundLayer != null) {
      final backgroundColor = backgroundLayer.properties.getValue(
        'BackgroundColor',
      );
      final backgroundTile = BackgroundTile(
        color: backgroundColor ?? 'Gray', // Default to 'Gray' if not specified
        position: Vector2(
          0,
          0, // Set the position of the background tile
        ), // Position of the tile
      );
      add(backgroundTile); // Add the background tile to the world
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>(
      'Spawnpoints',
    ); // Get the spawn points layer from the Tiled map

    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(
              spawnPoint.x,
              spawnPoint.y,
            ); // Set the player's position
            player.scale.x = 1; // Platyer look to right
            add(player); // Add the player character to the world
            break;
          case 'Fruit':
            final fruit = Fruit(
              fruit: spawnPoint
                  .name, // Use the name of the spawn point as the fruit type
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ), // Set the position of the fruit
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(fruit); // Add the fruit to the world
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue('isVertical');
            final offNeg = spawnPoint.properties.getValue('offNeg');
            final offPos = spawnPoint.properties.getValue('offPos');

            final saw = Saw(
              isVertial: isVertical,
              offNeg: offNeg,
              offPos: offPos,
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ), // Set the position of the saw
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(saw); // Add the saw to the world
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ), // Set the position of the checkpoint
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint); // Add the checkpoint to the world
            break;
          case 'Enemy':
            final chicken = Enemy(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ), // Set the position of the enemy
              size: Vector2(spawnPoint.width, spawnPoint.height),
              offNeg: spawnPoint.properties.getValue('offNeg'),
              offPos: spawnPoint.properties.getValue('offPos'),
            );
            add(chicken); // Add the enemy to the world
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>(
      'Collisions',
    ); // Get the collisions layer from the Tiled map

    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true, // Mark as a platform
            );
            collisionBlocks.add(platform); // Add to the collision blocks list
            add(platform); // Add the platform to the world
            break;
          default:
            final block = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            ); // Create a collision block
            collisionBlocks.add(block); // Add to the collision blocks list
            add(block); // Add the block to the world
        }
      }
    }
    player.collisionBlocks =
        collisionBlocks; // Assign the collision blocks to the player
  }
}
