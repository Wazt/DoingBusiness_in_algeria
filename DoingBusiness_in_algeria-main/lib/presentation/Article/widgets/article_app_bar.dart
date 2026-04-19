import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/presentation/Article/widgets/app_bar_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArticleAppBar extends StatelessWidget {
  const ArticleAppBar({super.key, required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SliverAppBar(
      collapsedHeight: size.height * 0.12,
      pinned: true,
      floating: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          onTap: (() => Get.back()),
          child: const AppBarIcon(
            icon: Icons.chevron_left,
            iconSize: 30,
          ),
        ),
      ),
      actions: const [AppBarIcon(icon: Icons.bookmark_outline_outlined)],
      leadingWidth: 40,
      backgroundColor: AppColors.primaryDark,
      iconTheme: const IconThemeData(color: Colors.white),
      expandedHeight: size.height * 0.4,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.blurBackground,
          StretchMode.zoomBackground
        ],
        background: Stack(
          children: [
            Positioned.fill(
              child: Image(
                image: CachedNetworkImageProvider(article.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            const Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: const Text(
                      'Trending',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 300,
                    child: Text(
                        maxLines: 3,
                        article.titre,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            height: 1.1,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(
                    children: [
                      Text('Grant thornton •',
                          maxLines: 2,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              height: 1.1,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: size.height * 0.09,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        ),
      ),
    );
  }
}
