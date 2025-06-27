import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform; // Indicates if the block is a platform
  CollisionBlock({
    super.position,
    super.size,
    this.isPlatform = false, // Default to false if not specified
  }) {
    debugMode = false;
  }
}
