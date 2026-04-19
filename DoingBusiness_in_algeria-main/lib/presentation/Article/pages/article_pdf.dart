import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ArticlePdf extends StatelessWidget {
  const ArticlePdf({super.key, required this.articleModel});

  final ArticleModel articleModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(articleModel.titre),
      ),
      body: SfPdfViewer.network(articleModel.pdfLink),
    );
  }
}
