import 'package:flutter/material.dart';
import 'package:chinese_herb_framery/services/herb_service.dart';
import 'package:chinese_herb_framery/models/herb.dart';

class DetailPage extends StatefulWidget {
  final String herbId;

  const DetailPage({super.key, required this.herbId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Herb?> _herbFuture;

  @override
  void initState() {
    super.initState();
    _herbFuture = _loadHerb();
  }

  Future<Herb?> _loadHerb() async {
    final herbs = await HerbService().loadHerbs();
    return herbs.firstWhere(
      (herb) => herb.id.toString() == widget.herbId,
      orElse: () => Herb(
        id: -1,
        name: '未知中药',
        category: '',
        effect: '未找到相关信息',
        taste: '',
        image: '', // Provide a default value for the required 'image' parameter
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('中药详情')),
      body: FutureBuilder<Herb?>(
        future: _herbFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('未找到中药信息'));
          }

          final herb = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  herb.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('分类: ${herb.category}'),
                const SizedBox(height: 20),
                const Text(
                  '功效:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(herb.effect),
                const SizedBox(height: 20),
                const Text(
                  '性味:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(herb.taste),
                // 如果有图片了再启用下面一堆
                // if (herb.image.isNotEmpty) ...[
                //   const SizedBox(height: 20),
                //   Center(
                //     child: Image.network(
                //       herb.image,
                //       height: 200,
                //       loadingBuilder: (context, child, loadingProgress) {
                //         if (loadingProgress == null) return child;
                //         return const CircularProgressIndicator();
                //       },
                //     ),
                //   ),
                // ],
              ],
            ),
          );
        },
      ),
    );
  }
}
