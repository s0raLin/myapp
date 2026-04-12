import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 轮播图 (必须用 SliverToBoxAdapter 包裹)
          SliverToBoxAdapter(
            child: CarouselSlider(
              options: CarouselOptions(
                height: 360.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: [1, 2, 3, 4, 5].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.secondaryContainer,
                      ),
                      child: Center(
                        child: Text(
                          'text $i',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    "歌曲推荐",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text("播放全部"),
                  ),
                ],
              ),
            ),
          ),
          SliverList.separated(
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  onTap: () {
                    context.push("/music/$index");
                  },
                  tileColor: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  leading: Icon(Icons.queue_music),
                  title: Text("歌曲"),
                  trailing: Icon(Icons.chevron_right),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          ),
        ],
      ),
    );
  }
}
