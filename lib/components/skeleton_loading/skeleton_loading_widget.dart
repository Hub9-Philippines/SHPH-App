import 'package:flutter/material.dart';

import '/theme/app_theme.dart';

class SkeletonLoadingWidget extends StatelessWidget {
  const SkeletonLoadingWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.of(context).alternate,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: _ShimmerAnimation(
        baseColor: AppTheme.of(context).alternate,
        highlightColor: AppTheme.of(context).primaryBackground,
      ),
    );
}

class _ShimmerAnimation extends StatefulWidget {
  const _ShimmerAnimation({
    required this.baseColor,
    required this.highlightColor,
  });

  final Color baseColor;
  final Color highlightColor;

  @override
  State<_ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<_ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
    );
}

// Skeleton card for booking items
class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoadingWidget(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoadingWidget(
                        width: 80,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 5),
                      SkeletonLoadingWidget(
                        width: double.infinity,
                        height: 18,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 5),
                      SkeletonLoadingWidget(
                        width: 120,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SkeletonLoadingWidget(
              width: double.infinity,
              height: 14,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            SkeletonLoadingWidget(
              width: double.infinity,
              height: 14,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            SkeletonLoadingWidget(
              width: double.infinity,
              height: 50,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
}

// Skeleton card for message items
class MessageCardSkeleton extends StatelessWidget {
  const MessageCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SkeletonLoadingWidget(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoadingWidget(
                  width: 150,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                SkeletonLoadingWidget(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                SkeletonLoadingWidget(
                  width: 100,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

// Skeleton card for category items
class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const SkeletonLoadingWidget(
            width: double.infinity,
            height: 80,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoadingWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                SkeletonLoadingWidget(
                  width: 60,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

// Skeleton card for service items (home page)
class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoadingWidget(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoadingWidget(
                  width: double.infinity,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                SkeletonLoadingWidget(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonLoadingWidget(
                      width: 40,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const Spacer(),
                    SkeletonLoadingWidget(
                      width: 60,
                      height: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
}

// Skeleton for profile header
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SkeletonLoadingWidget(
            width: 70,
            height: 70,
            borderRadius: BorderRadius.all(Radius.circular(35)),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonLoadingWidget(
                width: 150,
                height: 17,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              SkeletonLoadingWidget(
                width: 80,
                height: 15,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
}

// Skeleton for profile menu item
class ProfileMenuItemSkeleton extends StatelessWidget {
  const ProfileMenuItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 0,
            color: Color(0x33000000),
            offset: Offset(0, 1),
          )
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SkeletonLoadingWidget(
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                const SizedBox(width: 15),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoadingWidget(
                      width: 120,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoadingWidget(
                      width: 100,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
            const SkeletonLoadingWidget(
              width: 16,
              height: 16,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ],
        ),
      ),
    );
}

// Skeleton for search result items
class SearchCardSkeleton extends StatelessWidget {
  const SearchCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoadingWidget(
              width: 80,
              height: 80,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoadingWidget(
                    width: double.infinity,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoadingWidget(
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  SkeletonLoadingWidget(
                    width: 60,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  SkeletonLoadingWidget(
                    width: 80,
                    height: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}

// Skeleton for payment method cards
class PaymentMethodCardSkeleton extends StatelessWidget {
  const PaymentMethodCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SkeletonLoadingWidget(
            width: 50,
            height: 50,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoadingWidget(
                  width: 120,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                SkeletonLoadingWidget(
                  width: 80,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SkeletonLoadingWidget(
            width: 24,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
}

// Skeleton card for trending provider cards (home page "Trending near you"
// rail). Mirrors TrendingProviderCard in lib/components/prototype_components.dart.
class TrendingProviderCardSkeleton extends StatelessWidget {
  const TrendingProviderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: 196,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoadingWidget(
                width: 38,
                height: 38,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoadingWidget(
                      width: double.infinity,
                      height: 11,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 4),
                    SkeletonLoadingWidget(
                      width: 70,
                      height: 9,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const SkeletonLoadingWidget(
                width: 44,
                height: 14,
                borderRadius: BorderRadius.all(Radius.circular(7)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SkeletonLoadingWidget(
                width: 13,
                height: 13,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(width: 3),
              const SkeletonLoadingWidget(
                width: 18,
                height: 10,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(width: 2),
              const SkeletonLoadingWidget(
                width: 24,
                height: 9,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const Spacer(),
              const SkeletonLoadingWidget(
                width: 60,
                height: 10,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SkeletonLoadingWidget(
                width: 12,
                height: 12,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(width: 3),
              const SkeletonLoadingWidget(
                width: 80,
                height: 9,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const SkeletonLoadingWidget(
            width: double.infinity,
            height: 32,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
    );
}

// Skeleton tile for home category tiles ("EXPLORE SERVICES" rail). Mirrors
// CategoryTileItem in lib/components/prototype_components.dart.
class HomeCategoryTileSkeleton extends StatelessWidget {
  const HomeCategoryTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: 132,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          )
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SkeletonLoadingWidget(
            width: 32,
            height: 32,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonLoadingWidget(
                width: 90,
                height: 12,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 2),
              SkeletonLoadingWidget(
                width: 56,
                height: 9,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
}
