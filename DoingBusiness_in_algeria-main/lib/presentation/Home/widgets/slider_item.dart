import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/material.dart';

class SliderItem extends StatelessWidget {
  const SliderItem({super.key, required this.article, required this.onTap});

  final ArticleModel article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(size.width * 0.01),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: size.height * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: CachedNetworkImageProvider(article.imageUrl),
                  fit: BoxFit.cover,
                  color: const Color.fromARGB(100, 0, 0, 0),
                  colorBlendMode: BlendMode.multiply,
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                alignment: Alignment.center,
                width: size.width * 0.25,
                height: size.height * 0.03,
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
            ),
            Positioned(
              bottom: 60,
              left: 20,
              child: Container(
                width: size.width * 0.7,
                child: Text(
                    maxLines: 2,
                    article.titre,
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        height: 1.1,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 250,
                    child: Text('Grant thornton',
                        maxLines: 2,
                        style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            height: 1.1,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*


Stack(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.black,
            backgroundBlendMode: BlendMode.multiply,
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                "assets/images/bg_2.jpg",
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            width: 100,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: const Text(
              'Trending',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            'Loi de finances 2024',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );


 */