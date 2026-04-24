import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem(
      {super.key, required this.selected, required this.text, this.onTap});

  final bool selected;
  final String text;
  final ValueChanged? onTap;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FilterChip(label: Text(text), onSelected: onTap);
  }
}
/**
 * 
 * GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        width: size.width * 0.25,
        height: size.height * 0.04,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: selected ? AppColors.primaryDark : Colors.grey[100],
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
 */