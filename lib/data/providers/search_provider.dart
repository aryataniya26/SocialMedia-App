// lib/data/providers/search_provider.dart

import 'package:flutter/material.dart';
import '../services/search_service.dart';

class SearchProvider with ChangeNotifier {
  final SearchService _searchService = SearchService();

  // State variables
  List<dynamic> _searchResults = [];
  List<dynamic> _trending = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';

  // Getters
  List<dynamic> get searchResults => _searchResults;
  List<dynamic> get trending => _trending;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;

  // ==================== GLOBAL SEARCH ====================
  Future<void> globalSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _currentQuery = query;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _searchService.globalSearch(query);

      if (response['success'] == true) {
        final data = response['data'];
        _searchResults = [
          ...(data['users'] ?? []),
          ...(data['posts'] ?? []),
          ...(data['hashtags'] ?? []),
        ];
      } else {
        _errorMessage = response['message'] ?? 'Search failed';
        _searchResults = [];
      }
    } catch (e) {
      _errorMessage = 'Search error: $e';
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== SEARCH USERS ====================
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      return;
    }

    _isLoading = true;
    _currentQuery = query;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _searchService.searchUsers(query);

      if (response['success'] == true) {
        _searchResults = response['data'] ?? [];
      } else {
        _errorMessage = response['message'] ?? 'Search failed';
        _searchResults = [];
      }
    } catch (e) {
      _errorMessage = 'Search error: $e';
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== SEARCH POSTS ====================
  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      return;
    }

    _isLoading = true;
    _currentQuery = query;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _searchService.searchPosts(query);

      if (response['success'] == true) {
        _searchResults = response['data'] ?? [];
      } else {
        _errorMessage = response['message'] ?? 'Search failed';
        _searchResults = [];
      }
    } catch (e) {
      _errorMessage = 'Search error: $e';
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ==================== GET TRENDING ====================
  Future<void> fetchTrending() async {
    try {
      final response = await _searchService.getTrending();

      if (response['success'] == true) {
        _trending = response['data'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching trending: $e');
    }
  }

  // ==================== CLEAR SEARCH ====================
  void clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== CLEAR ALL ====================
  void clear() {
    _searchResults = [];
    _trending = [];
    _currentQuery = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}