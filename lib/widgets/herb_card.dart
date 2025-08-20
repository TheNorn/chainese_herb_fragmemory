import 'package:flutter/material.dart';
import 'package:chinese_herb_framery/models/herb.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//有图片了启用curl https://www.google.com

class HerbCard extends StatelessWidget {
  final Herb herb;
  final VoidCallback? onTap;

  const HerbCard({super.key, required this.herb, this.onTap});

  @override
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                herb.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('分类: ${herb.category}'),
              const SizedBox(height: 8),
              Text(herb.effect, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
