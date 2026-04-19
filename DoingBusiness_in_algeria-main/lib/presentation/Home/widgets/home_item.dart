import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/presentation/Article/pages/article_screen.dart';
import 'package:doingbusiness/utils/categories_data/categories_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeItem extends StatelessWidget {
  const HomeItem({super.key, required this.article});
  final ArticleModel article;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final CategoriesData data = CategoriesData();
    return GestureDetector(
      onTap: () {
        Get.to(ArticleScreen(
          article: article,
        ));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        width: double.infinity,
        height: size.height * 0.13,
        child: Row(
          children: [
            Container(
              width: size.width * 0.27,
              height: size.height * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  image: CachedNetworkImageProvider(article.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                    data.categories[int.parse(article.categoryId) - 1]['name']
                        .toString(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey)),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                  width: size.width * 0.65,
                  child: Text(
                      maxLines: 2,
                      article.titre,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        height: 1.1,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      )),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Container(
                  width: size.width * 0.65,
                  child: Row(
                    children: [
                      Image(
                        image: AssetImage('assets/images/logo_gt.png'),
                        width: size.width * 0.05,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('GrantThornton .',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey)),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
