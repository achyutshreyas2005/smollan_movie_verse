import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../data/models/show_model.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/glassmorphism_container.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatefulWidget {
  final ShowModel show;

  const DetailsScreen({super.key, required this.show});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isSummaryExpanded = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),
                  _buildActions(context),
                  SizedBox(height: 32.h),
                  _buildSummary(context),
                  SizedBox(height: 32.h),
                  _buildInfoGrid(context),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 500.h,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.show.originalImageUrl != null || widget.show.imageUrl != null)
              Hero(
                tag: 'show_${widget.show.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.show.originalImageUrl ?? widget.show.imageUrl!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[900]),
                ),
              )
            else
              Hero(
                tag: 'show_${widget.show.id}',
                child: Container(color: Colors.grey[900]),
              ),
            
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GlassmorphismContainer(
          borderRadius: BorderRadius.circular(20.r),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              final isFav = provider.isFavorite(widget.show.id);
              return GlassmorphismContainer(
                borderRadius: BorderRadius.circular(20.r),
                child: IconButton(
                  icon: Icon(
                    isFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    color: isFav ? Colors.red : Colors.white,
                  ),
                  onPressed: () => provider.toggleFavorite(widget.show),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.show.genres.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.show.genres.map((genre) => _buildGenreChip(context, genre)).toList(),
          ),
        SizedBox(height: 16.h),
        Text(
          widget.show.name,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 34.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1.1,
              ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            if (widget.show.premiered != null) ...[
              Text(
                widget.show.premiered!.substring(0, 4),
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              _buildDotSeparator(),
            ],
            if (widget.show.rating != null) ...[
              Icon(Icons.star, color: Colors.amber, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                widget.show.rating.toString(),
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              _buildDotSeparator(),
            ],
            if (widget.show.runtime != null) ...[
              Text(
                '${widget.show.runtime}m',
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              _buildDotSeparator(),
            ],
            if (widget.show.language != null)
              Text(
                widget.show.language!,
                style: TextStyle(color: Colors.grey[400], fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 10.sp,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDotSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text('•', style: TextStyle(color: Colors.grey[600], fontSize: 14.sp)),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        AnimatedPlayButton(show: widget.show),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildIconButton(
              icon: CupertinoIcons.globe, 
              label: 'Browser', 
              onTap: () {
                 final url = widget.show.officialSite ?? widget.show.url;
                 UrlLauncherUtil.launchUrlString(context, url);
              }
            ),
            _buildIconButton(
              icon: CupertinoIcons.share, 
              label: 'Share', 
              onTap: () {
                 final url = widget.show.officialSite ?? widget.show.url;
                 if (url != null) {
                    Share.share('Check out ${widget.show.name} on Smollan Movie Verse: $url');
                 } else {
                    Share.share('Check out ${widget.show.name} on Smollan Movie Verse!');
                 }
              }
            ),
            _buildIconButton(
              icon: CupertinoIcons.link, 
              label: 'Copy Link', 
              onTap: () {
                 final url = widget.show.officialSite ?? widget.show.url;
                 if (url != null) {
                    Clipboard.setData(ClipboardData(text: url));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
                 } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No link available')));
                 }
              }
            ),
            if (widget.show.imdbId != null)
              _buildIconButton(
                icon: Icons.movie_creation_outlined, 
                label: 'IMDb', 
                onTap: () => UrlLauncherUtil.launchUrlString(context, 'https://www.imdb.com/title/${widget.show.imdbId}/')
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final plainTextSummary = widget.show.summary?.replaceAll(RegExp(r'<[^>]*>'), '') ?? 'No summary available.';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
          child: AnimatedCrossFade(
            firstChild: Text(
              plainTextSummary,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[400], fontSize: 15.sp, height: 1.5),
            ),
            secondChild: Text(
              plainTextSummary,
              style: TextStyle(color: Colors.grey[400], fontSize: 15.sp, height: 1.5),
            ),
            crossFadeState: _isSummaryExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ),
        if (plainTextSummary.length > 150)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: InkWell(
              onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
              child: Text(
                _isSummaryExpanded ? 'Read Less' : 'Read More',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          if (widget.show.premiered != null) ...[
            _buildInfoRow('Release Date', widget.show.premiered!),
            const Divider(color: Colors.white10, height: 24),
          ],
          if (widget.show.ended != null) ...[
            _buildInfoRow('Ended', widget.show.ended!),
            const Divider(color: Colors.white10, height: 24),
          ],
          _buildInfoRow('Status', widget.show.status ?? 'Unknown'),
          const Divider(color: Colors.white10, height: 24),
          _buildInfoRow('Type', widget.show.type ?? 'Unknown'),
          if (widget.show.averageRuntime != null) ...[
            const Divider(color: Colors.white10, height: 24),
            _buildInfoRow('Avg. Runtime', '${widget.show.averageRuntime} min'),
          ],
          if (widget.show.network != null) ...[
            const Divider(color: Colors.white10, height: 24),
            _buildInfoRow('Network', '${widget.show.network!.name} ${widget.show.network!.countryCode != null ? '(${widget.show.network!.countryCode})' : ''}'),
          ],
          if (widget.show.webChannel != null) ...[
            const Divider(color: Colors.white10, height: 24),
            _buildInfoRow('Streaming On', widget.show.webChannel!.name ?? 'Unknown Platform'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14.sp)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: Colors.white)),
      ],
    );
  }

}

class AnimatedPlayButton extends StatefulWidget {
  final ShowModel show;
  const AnimatedPlayButton({super.key, required this.show});

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton> {
  bool _isPressed = false;
  bool _isLoading = false;

  Future<void> _handlePlay() async {
    setState(() => _isLoading = true);
    
    // Simulate slight delay for the premium feel
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!mounted) return;
    
    final urlToLaunch = widget.show.officialSite ?? 'https://www.google.com/search?q=${Uri.encodeComponent('${widget.show.name} tv show watch online')}';
    await UrlLauncherUtil.launchUrlString(context, urlToLaunch);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _handlePlay();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: _isLoading 
            ? const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)))
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.play_arrow_solid, color: Colors.white, size: 28),
                SizedBox(width: 8.w),
                Text(
                  'Watch Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
