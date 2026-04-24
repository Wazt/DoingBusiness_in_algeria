import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/presentation/Article/pages/article_screen.dart';

import 'package:doingbusiness/presentation/explorer/widgets/filter_bar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.put(ArticleController());
    final categories = [
      {'name': 'finance', 'id': '1'},
      {'name': 'sport', 'id': '2'},
    ];

    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Discover',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                  )),
              const Text('Daily financial news',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  )),
              SizedBox(
                height: size.height * 0.01,
              ),
              FilterBar(),
              SizedBox(
                height: size.height * 0.04,
              ),
              Obx(
                () => GridView.builder(
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 1.25),
                      crossAxisCount: 2, // number of items in each row
                      mainAxisSpacing: 8.0, // spacing between rows
                      crossAxisSpacing: 8, // spacing between columns
                    ),
                    padding: EdgeInsets.all(2.0), // padding around the grid
                    itemCount: controller.filteredArticles.length,
                    itemBuilder: (context, index) {
                      final article = controller.filteredArticles[index];
                      return Container(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      article.imageUrl),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.45),
                            ),
                            Positioned(
                              bottom: 50,
                              left: 10,
                              child: Container(
                                width: size.width * 0.4,
                                child: Text(
                                  maxLines: 2,
                                  article.titre,
                                  style: TextStyle(
                                    color: Colors.white,
                                    overflow: TextOverflow.ellipsis,
                                    height: 1.1,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 5,
                                left: 10,
                                child: Container(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                              ArticleScreen(article: article));
                                        },
                                        child: Icon(
                                          Icons.play_circle_fill_outlined,
                                          size: 35,
                                          color: Colors.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      );
                    }),
              ),
              /*
              Obx(
                () => ListView.builder(
                  itemCount: controller.filteredArticles.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final article = controller.filteredArticles[index];
                    return HomeItem(
                      article: article,
                    );
                  },
                ),
              )*/
            ],
          ),
        ),
      ),
    ));
  }
}
