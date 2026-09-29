import 'package:flutter/material.dart';

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: ColoredBox(color: color)),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(color, 60),
                  const SizedBox(height: 10),
                  _bar(color, 130),
                  const SizedBox(height: 8),
                  _bar(color, 100),
                  const Spacer(),
                  _bar(color, 75),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(Color color, double width) => Container(
        height: 10,
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      );
}
