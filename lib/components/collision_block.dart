import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatform; // Indicates if the block is a platform
  CollisionBlock({
    position,
    size,
    this.isPlatform = false, // Default to false if not specified
  }) : super(position: position, size: size) {
    debugMode = true;
  }
}
