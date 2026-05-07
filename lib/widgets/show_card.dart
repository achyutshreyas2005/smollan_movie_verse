import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/models/show_model.dart';
import '../screens/details/details_screen.dart';
import '../providers/shows_provider.dart';
import '../providers/favorites_provider.dart';
import 'custom_shimmer.dart';
import 'glassmorphism_container.dart';

class ShowCard extends StatelessWidget {
  final ShowModel show;

  const ShowCard({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ShowsProvider>().addToRecent(show);
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation, secondaryAnimation) => DetailsScreen(show: show),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2.0 / 3.0,
              child: Hero(
                tag: 'show_${show.id}',
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Stack(
                      fit: StackFit.expand,
                    children: [
                      if (show.imageUrl != null)
                        CachedNetworkImage(
                          imageUrl: show.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CustomShimmer(
                            width: double.infinity,
                            height: double.infinity,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.error, color: Colors.white),
                          ),
                        )
                      else
                        Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.movie, color: Colors.white, size: 40),
                        ),
                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Favorite icon at top left
                      Positioned(
                        top: 8.h,
                        left: 8.w,
                        child: Consumer<FavoritesProvider>(
                          builder: (context, favProvider, child) {
                            final isFav = favProvider.isFavorite(show.id);
                            return GestureDetector(
                              onTap: () {
                                favProvider.toggleFavorite(show);
                              },
                              child: GlassmorphismContainer(
                                borderRadius: BorderRadius.circular(20.r),
                                padding: EdgeInsets.all(4.w),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Rating badge
                      if (show.rating != null)
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: GlassmorphismContainer(
                            borderRadius: BorderRadius.circular(8.r),
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 12.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  show.rating.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ),
            SizedBox(height: 10.h),
            Text(
              show.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    letterSpacing: -0.2,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
