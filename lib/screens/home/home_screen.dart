import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/enums/ui_state.dart';
import '../../providers/shows_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/cinematic_banner.dart';
import '../../widgets/show_card.dart';
import '../../widgets/custom_shimmer.dart';
import 'dart:ui';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import 'package:lottie/lottie.dart';

enum ShowFilter { all, trending, popular, upcoming }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  ShowFilter _selectedFilter = ShowFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShowsProvider>().fetchHomeData();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<ShowsProvider>().fetchMorePopularShows();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<ShowsProvider>(
        builder: (context, provider, child) {
          if (provider.state == UIState.loading && provider.trendingShows.isEmpty) {
            return _buildLoadingState();
          }

          if (provider.state == UIState.error && provider.trendingShows.isEmpty) {
            return const Center(child: Text('Error loading shows.'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchHomeData,
            color: Theme.of(context).primaryColor,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CinematicBanner(shows: provider.trendingShows),
                      SizedBox(height: 24.h),
                      _buildFilterRow(),
                      SizedBox(height: 24.h),
                      if (provider.recentShows.isNotEmpty && _selectedFilter == ShowFilter.all) ...[
                        _buildSectionTitle('Continue Watching'),
                        _buildHorizontalList(provider.recentShows, isRecent: true),
                        SizedBox(height: 32.h),
                      ],
                      if (_selectedFilter == ShowFilter.all || _selectedFilter == ShowFilter.trending) ...[
                        _buildSectionTitle('Trending Now'),
                        _buildHorizontalList(provider.trendingShows),
                        SizedBox(height: 32.h),
                      ],
                      if (_selectedFilter == ShowFilter.all || _selectedFilter == ShowFilter.popular) ...[
                        _buildSectionTitle('Popular Hits'),
                        _buildHorizontalList(provider.popularShows),
                        if (provider.isFetchingMore)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: SizedBox(
                                width: 60.w,
                                height: 60.w,
                                child: Lottie.asset('assets/lottie/loading.json'),
                              ),
                            ),
                          ),
                      ],
                      if (_selectedFilter == ShowFilter.all || _selectedFilter == ShowFilter.upcoming) ...[
                        _buildSectionTitle('Upcoming Shows'),
                        _buildHorizontalList(provider.upcomingShows),
                      ],
                      SizedBox(height: 60.h),
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text('Smollan Movie Verse', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.sp, letterSpacing: -0.5)),
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(themeProvider.isDarkMode ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.search),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.heart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildFilterChip(ShowFilter.all, 'All Shows'),
          SizedBox(width: 8.w),
          _buildFilterChip(ShowFilter.trending, 'Trending Now'),
          SizedBox(width: 8.w),
          _buildFilterChip(ShowFilter.popular, 'Popular Hits'),
          SizedBox(width: 8.w),
          _buildFilterChip(ShowFilter.upcoming, 'Upcoming Shows'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ShowFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = filter);
        }
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 13.sp,
        letterSpacing: 0.5,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: 22.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List shows, {bool isRecent = false}) {
    return SizedBox(
      height: 240.h,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: shows.length,
        itemBuilder: (context, index) {
          final show = shows[index];
          if (isRecent) {
            return Stack(
              children: [
                ShowCard(show: show),
                Positioned(
                  top: 4,
                  right: 20.w, // Adjust for the 16.w margin on ShowCard
                  child: InkWell(
                    onTap: () {
                      context.read<ShowsProvider>().removeFromRecent(show.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }
          return ShowCard(show: show);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomShimmer(width: double.infinity, height: 400.h),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CustomShimmer(width: 150.w, height: 24.h),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: CustomShimmer(width: 140.w, height: 220.h, borderRadius: BorderRadius.circular(16.r)),
              );
            },
          ),
        ),
      ],
    );
  }
}
