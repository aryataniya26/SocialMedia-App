import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/story_model.dart';

class StoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<StoryModel> _stories = [];
  bool _isLoading = false;

  List<StoryModel> get stories => _stories;
  bool get isLoading => _isLoading;

  // Fetch Stories
  Future<void> fetchStories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/feed/stories',
        requiresAuth: true,
      );

      if (response['success'] == true) {
        final data = response['data'];
        final List storiesJson = data['stories'] ?? [];

        _stories = storiesJson
            .map((json) => StoryModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching stories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Upload Story
  Future<bool> uploadStory(String mediaPath, String mediaType) async {
    try {
      // TODO: Implement file upload
      final response = await _apiService.post(
        '/story/upload',
        body: {
          'media_type': mediaType,
        },
        requiresAuth: true,
      );

      if (response['success'] == true) {
        await fetchStories();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error uploading story: $e');
      return false;
    }
  }
}