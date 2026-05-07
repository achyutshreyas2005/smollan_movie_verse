import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/models/episode_model.dart';
import '../screens/details/details_screen.dart';
import 'glassmorphism_container.dart';
import 'custom_shimmer.dart';

class UpcomingEpisodeCard extends StatelessWidget {
  final EpisodeModel episode;

  const UpcomingEpisodeCard({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    // Determine image (episode image or show image or fallback)
    final imageUrl = episode.imageUrl ?? episode.show.imageUrl;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(show: episode.show),
          ),
        );
      },
      child: GlassmorphismContainer(
        borderRadius: BorderRadius.circular(16.r),
        padding: EdgeInsets.zero,
        child: Container(
          height: 160.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Poster Image
              SizedBox(
                width: 110.w,
                height: double.infinity,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CustomShimmer(width: double.infinity, height: double.infinity),
                        errorWidget: (context, url, error) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              // Details
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show Name
                      Text(
                        episode.show.name,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      // Episode Name
                      Text(
                        episode.name,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey[300]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      // Season & Episode number
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: Theme.of(context).primaryColor),
                            ),
                            child: Text(
                              'S${episode.season ?? 0} E${episode.number ?? 0}',
                              style: TextStyle(fontSize: 12.sp, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (episode.runtime != null)
                            Text('${episode.runtime} min', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      // Air Date and Time
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            '${episode.airdate ?? ''} ${episode.airtime ?? ''}',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // Network
                      if (episode.show.network?.name != null || episode.show.webChannel?.name != null)
                        Row(
                          children: [
                            Icon(Icons.live_tv, size: 14.sp, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Text(
                              episode.show.network?.name ?? episode.show.webChannel?.name ?? '',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Icon(Icons.movie, size: 40.sp, color: Colors.grey[700]),
      ),
    );
  }
}
