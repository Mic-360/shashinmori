import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    required this.itemCount,
    required this.crossAxisCount,
    required this.controller,
    required this.itemBuilder,
    super.key,
  });

  final int itemCount;
  final int crossAxisCount;
  final ScrollController controller;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      controller: controller,
      padding: const EdgeInsets.all(4),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
