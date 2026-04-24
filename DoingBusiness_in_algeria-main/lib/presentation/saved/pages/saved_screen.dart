import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final articleController = Get.put(ArticleController());
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saved',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w700,
                    )),
                const Text(
                  'Explore your saved Articles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                /*
                Obx(
                  () => ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (BuildContext context, index) {
                        final articleId = controller.savedArticles[index];
                        final article =
                            articleController.featuredArticles.where(
                          (p0) => p0.id == articleId,
                        );
                        return HomeItem(article: article.first);
                      }),
                )*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
