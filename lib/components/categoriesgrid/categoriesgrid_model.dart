import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'categoriesgrid_widget.dart' show CategoriesgridWidget;

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.imageAsset,
    required this.categoryParam,
    this.borderRadius = 10,
  });

  final String name;
  final String imageAsset;
  final String categoryParam;
  final double borderRadius;
}

class CategoriesgridModel extends FlutterFlowModel<CategoriesgridWidget> {
  ///  State fields for stateful widgets in this component.

  // List of category items for the grid
  static const List<CategoryItem> categories = [
    CategoryItem(
      name: 'Home Improvement',
      imageAsset: 'assets/images/15.png',
      categoryParam: 'Home Improvement',
      borderRadius: 10,
    ),
    CategoryItem(
      name: 'Electrical Services',
      imageAsset: 'assets/images/1.png',
      categoryParam: 'Electrical Services',
      borderRadius: 10,
    ),
    CategoryItem(
      name: 'Safety & Security',
      imageAsset: 'assets/images/14.png',
      categoryParam: 'Safety and Security',
      borderRadius: 10,
    ),
    CategoryItem(
      name: 'Cleaning Services',
      imageAsset: 'assets/images/49svh_2.png',
      categoryParam: 'Cleaning Services',
      borderRadius: 20,
    ),
    CategoryItem(
      name: 'Home Pest Protection',
      imageAsset: 'assets/images/dfjsb_6.png',
      categoryParam: 'All',
      borderRadius: 10,
    ),
    CategoryItem(
      name: 'HVAC Services',
      imageAsset: 'assets/images/x7hc1_7.png',
      categoryParam: 'HVAC Services',
      borderRadius: 10,
    ),
    CategoryItem(
      name: 'Handyman Services',
      imageAsset: 'assets/images/fijek_4.png',
      categoryParam: 'Handyman Services',
      borderRadius: 20,
    ),
    CategoryItem(
      name: 'Plumbing Services',
      imageAsset: 'assets/images/k7eg7_8.png',
      categoryParam: 'Plumbing Services',
      borderRadius: 20,
    ),
  ];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
