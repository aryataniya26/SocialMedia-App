import '../../config/app_config.dart';

class ApiEndpoints {
  // Base URL with proper formatting
  static String get baseUrl {
    final url = AppConfig.baseUrl;
    // Ensure no trailing slash
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // ==================== AUTH ENDPOINTS ====================
  static const String register = "api/v1/users/register";
  static const String verifyRegister = "api/v1/users/verify-register";
  static const String login = "api/v1/users/login";
  static const String verifyLogin = "api/v1/users/verify-login";
  static const String logout = "api/v1/users/logout";
  static const String currentUser = "api/v1/users/current-user";
  static const String forgotPassword = "api/v1/users/forgot-password";
  static const String resetPassword = "api/v1/users/reset-password";
  static String deleteAccount(String userId) => "api/v1/users/delete/$userId";

  // ==================== FOLLOW ENDPOINTS ====================
  static String followRequest(String userId) => "api/v1/follow/request/$userId";
  static String followAccept(String requestId) => "api/v1/follow/accept/$requestId";
  static String followRemoveRequest(String requestId) => "api/v1/follow/remove-request/$requestId";
  static const String totalFollowers = "api/v1/follow/total-followers";
  static const String totalFollowing = "api/v1/follow/total-following";

  // ==================== POST ENDPOINTS ====================
  static const String uploadPost = "api/v1/post/upload";
  static String deletePost(String postId) => "api/v1/post/delete/$postId";
  static String getPost(String postId) => "api/v1/post/$postId";

  // ==================== USER PROFILE ENDPOINTS ====================
  static String userProfile(String userId) => "api/v1/user/profile/$userId";
  static const String updateProfile = "api/v1/user/profile/update";
  static String followers(String userId) => "api/v1/user/followers/$userId";
  static String following(String userId) => "api/v1/user/following/$userId";

  // ==================== POST INTERACTIONS ====================
  static String postDetails(String postId) => "api/v1/post/details/$postId";
  static String likePost(String postId) => "api/v1/post/like/$postId";
  static String unlikePost(String postId) => "api/v1/post/unlike/$postId";
  static String commentPost(String postId) => "api/v1/post/comment/$postId";
  static String deleteComment(String commentId) => "api/v1/post/comment/$commentId";

  // ==================== STORIES ====================
  static const String uploadStory = "api/v1/story/upload";
  static String deleteStory(String storyId) => "api/v1/story/delete/$storyId";

  // ==================== REELS ====================
  static const String uploadReel = "api/v1/reel/upload";
  static String deleteReel(String reelId) => "api/v1/reel/delete/$reelId";

  // ==================== FEEDS ====================
  static const String homeFeed = "api/v1/feed/home";
  static const String reelsFeed = "api/v1/feed/reels";
  static const String storiesFeed = "api/v1/feed/stories";
  static String userPosts(String userId) => "api/v1/feed/posts/$userId";

  // ==================== LIVE STREAM ====================
  static const String liveStart = "api/v1/live/start";
  static const String liveEnd = "api/v1/live/end";

  // ==================== SEARCH ====================
  static const String searchGlobal = "api/v1/search/global";
  static const String searchUsers = "api/v1/search/users";

  // ==================== CHAT ====================
  static const String chatThreads = "api/v1/chat/threads";
  static String chatMessages(String threadId) => "api/v1/chat/messages/$threadId";
  static String sendMessage(String threadId) => "api/v1/chat/message/send/$threadId";

  // ==================== NOTIFICATIONS ====================
  static const String notificationsList = "api/v1/notifications/list";

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return '$baseUrl/$endpoint';

  }
}