import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArticleBody extends StatelessWidget {
  const ArticleBody({super.key, required this.article});
  final ArticleModel article;
  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(SavedController());
    final articleController = Get.put(ArticleController());
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/logo_gt.png'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Grant thornton',
                      maxLines: 2,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        height: 1.1,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ), /*
              GestureDetector(
                onTap: () {
                  debugPrint('saving');
                },
                child: Icon(
                  Icons.bookmark_add,
                  size: 30,
                ),
              ),*/
            ],
          ),
          SizedBox(
            height: 16,
          ),
          articleController.isLoading.value
              ? Text('loading....')
              : Text(
                  article.blog,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontSize: articleController.fontSizeValue.value),
                ),
        ],
      ),
    );
  }
}
