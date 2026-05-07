import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/enums/ui_state.dart';
import '../../core/utils/debouncer.dart';
import '../../providers/search_provider.dart';
import '../../widgets/show_card.dart';
import '../../widgets/glassmorphism_container.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, child) {
                  if (provider.state == UIState.initial) {
                    return provider.searchHistory.isEmpty
                        ? _buildMessageState(
                            'Search TV Shows',
                            'Type a name to discover your next favorite show.',
                            Icons.search,
                            lottieAsset: 'assets/lottie/empty.json',
                          )
                        : _buildSearchHistory(provider);
                  }

                  if (provider.state == UIState.loading) {
                    return Center(
                      child: SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: Lottie.asset('assets/lottie/loading.json'),
                      ),
                    );
                  }

                  if (provider.state == UIState.empty) {
                    return _buildMessageState(
                      'No results found',
                      'Try searching for something else.',
                      Icons.sentiment_dissatisfied,
                      lottieAsset: 'assets/lottie/empty.json',
                    );
                  }

                  if (provider.state == UIState.error) {
                    return _buildMessageState(
                      'Error',
                      'Something went wrong. Please try again.',
                      Icons.error_outline,
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final int crossAxisCount = (constraints.maxWidth / 120).floor().clamp(2, 8);
                      return GridView.builder(
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 16.h,
                        ),
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          return ShowCard(show: provider.searchResults[index]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              context.read<SearchProvider>().clearSearch();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: GlassmorphismContainer(
              borderRadius: BorderRadius.circular(12.r),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search shows, movies...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(CupertinoIcons.search, color: Colors.grey),
                ),
                onChanged: (value) {
                  _debouncer.run(() {
                    context.read<SearchProvider>().searchShows(value);
                  });
                },
              ),
            ),
          ),
        ],
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
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(SearchProvider provider) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18.sp, fontWeight: bold, color: Colors.white),
              ),
              TextButton(
                onPressed: () => provider.clearHistory(),
                child: Text('Clear', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: provider.searchHistory.map((query) {
              return ActionChip(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                label: Text(query, style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  _searchController.text = query;
                  provider.searchShows(query);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

const FontWeight bold = FontWeight.bold;
