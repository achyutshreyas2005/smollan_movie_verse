import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/models/show_model.dart';
import '../screens/details/details_screen.dart';
import '../providers/shows_provider.dart';
import '../providers/favorites_provider.dart';

class CinematicBanner extends StatelessWidget {
  final List<ShowModel> shows;

  const CinematicBanner({super.key, required this.shows});

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 400.h,
      child: PageView.builder(
        itemCount: shows.length > 5 ? 5 : shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          return GestureDetector(
            onTap: () {
              context.read<ShowsProvider>().addToRecent(show);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailsScreen(show: show),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (show.originalImageUrl != null || show.imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: show.originalImageUrl ?? show.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                  )
                else
                  Container(color: Colors.grey[900]),
                
                // Cinematic gradient overlay for premium feel
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.1),
                          Colors.transparent,
                          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
                          Theme.of(context).scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.3, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Content
                Positioned(
                  bottom: 40.h,
                  left: 24.w,
                  right: 24.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (show.genres.isNotEmpty)
                        Text(
                          show.genres.join(' • ').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.sp,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      SizedBox(height: 8.h),
                      Text(
                        show.name,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 32.sp,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailsScreen(show: show),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow, color: Colors.black),
                              label: const Text('Play', style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Consumer<FavoritesProvider>(
                              builder: (context, provider, child) {
                                final isFav = provider.isFavorite(show.id);
                                return OutlinedButton.icon(
                                  onPressed: () => provider.toggleFavorite(show),
                                  icon: Icon(isFav ? Icons.check : Icons.add, color: Colors.white),
                                  label: Text(isFav ? 'Added' : 'My List', style: const TextStyle(color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
