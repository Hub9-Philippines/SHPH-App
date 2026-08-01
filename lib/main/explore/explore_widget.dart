import 'package:flutter/material.dart';

import '/components/categories_widget/categories_widget.dart';
import '/components/content_container.dart';
import '/components/refreshable_page.dart';
import '/components/screen_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'explore_model.dart';

export 'explore_model.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  static String routeName = 'Explore';
  static String routePath = '/explore';

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> with RefreshablePage<ExploreWidget> {
  late ExploreModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, ExploreModel.new);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Future<void> onRefresh() async {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF5F7FA),
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Explore',
                  subtitle: 'Jump into the service type you need most.',
                  action: Icon(
                    Icons.grid_view_rounded,
                    color: AppTheme.of(context).primary,
                  ),
                ),
                Expanded(
                  child: ContentContainer(
                    variant: ContentVariant.full,
                    child: wrapWithRefresh(
                      child: CategoriesWidgetWidget(
                        key: ValueKey('categories_$_refreshKey'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
