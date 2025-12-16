import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/reel_model.dart';

class ReelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ReelModel> _reels = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;

  List<ReelModel> get reels => _reels;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  // Fetch Reels
  Future<void> fetchReels({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _page = 1;
      _reels = [];
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/feed/reels',
        queryParams: {
          'page': _page.toString(),
          'limit': '10',
        },
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final List reelsJson = data['reels'] ?? [];

        final newReels = reelsJson
            .map((json) => ReelModel.fromJson(json))
            .toList();

        if (refresh) {
          _reels = newReels;
        } else {
          _reels.addAll(newReels);
        }

        _hasMore = newReels.length >= 10;
        _page++;
      }
    } catch (e) {
      debugPrint('Error fetching reels: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Like Reel
  Future<void> likeReel(String reelId) async {
    try {
      final index = _reels.indexWhere((r) => r.reelId == reelId);
      if (index != -1) {
        final reel = _reels[index];
        _reels[index] = reel.copyWith(
          isLiked: !reel.isLiked,
          likesCount: reel.isLiked ? reel.likesCount - 1 : reel.likesCount + 1,
        );
        notifyListeners();

        await _apiService.post(
          '/reel/like/$reelId',
          requiresAuth: true,
        );
      }
    } catch (e) {
      debugPrint('Error liking reel: $e');
    }
  }
}