import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../core/enums/ui_state.dart';
import '../../providers/upcoming_provider.dart';
import '../../widgets/upcoming_episode_card.dart';
import '../../widgets/custom_shimmer.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpcomingProvider>().fetchUpcoming();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(110.h),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFilterRow(context),
            ],
          ),
        ),
      ),
      body: Consumer<UpcomingProvider>(
        builder: (context, provider, child) {
          if (provider.state == UIState.loading) {
            return _buildLoadingState();
          }

          if (provider.state == UIState.error) {
            return _buildMessageState('Error', 'Failed to load schedule.', Icons.error_outline);
          }

          final episodes = provider.filteredEpisodes;

          if (episodes.isEmpty) {
            return _buildMessageState(
              'No Episodes',
              'There are no upcoming episodes for this filter.',
              Icons.event_busy,
              lottieAsset: 'assets/lottie/empty.json',
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchUpcoming,
            color: Theme.of(context).primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: UpcomingEpisodeCard(episode: episodes[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search schedule...',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          context.read<UpcomingProvider>().search(value);
        },
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    final provider = context.watch<UpcomingProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _buildFilterChip(context, provider, UpcomingFilter.today, 'Today'),
          SizedBox(width: 8.w),
          _buildFilterChip(context, provider, UpcomingFilter.tomorrow, 'Tomorrow'),
          SizedBox(width: 8.w),
          _buildFilterChip(context, provider, UpcomingFilter.thisWeek, 'This Week'),
          SizedBox(width: 8.w),
          _buildFilterChip(context, provider, UpcomingFilter.all, 'All Upcoming'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, UpcomingProvider provider, UpcomingFilter filter, String label) {
    final isSelected = provider.currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      onSelected: (selected) {
        if (selected) provider.setFilter(filter);
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _buildMessageState(String title, String subtitle, IconData icon, {String? lottieAsset}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottieAsset != null)
            SizedBox(
              width: 150.w,
              height: 150.w,
              child: Lottie.asset(lottieAsset),
            )
          else
            Icon(icon, size: 80.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: CustomShimmer(width: double.infinity, height: 160.h, borderRadius: BorderRadius.circular(16.r)),
        );
      },
    );
  }
}
