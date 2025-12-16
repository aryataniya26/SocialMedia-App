import '../../config/app_config.dart';

class ApiEndpoints {
  static const String base = AppConfig.baseUrl;

  // Auth Endpoints
  static const String register = '/api/v1/users/register';
  static const String verifyRegister = '/api/v1/users/verify-register';
  // static const String register = '/auth/register';
  static const String sendOtp = '/auth/send-otp';
  static const String login = '/api/v1/users/login';
  static const String verifyLogin = '/api/v1/users/verify-login';
  static const String logout = '/api/v1/users/logout';
  static const String currentUser = '/api/v1/users/current-user';
  static const String verifyOtp = '/auth/verify-otp';
  // static const String login = '/auth/login';
  // static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';
  static const String forgotPassword = '/auth/forgot-password';

  // User Profile
  static String userProfile(String userId) => '/user/profile/$userId';
  static const String updateProfile = '/user/profile/update';
  static const String uploadPhoto = '/user/profile/photo';
  static const String uploadCover = '/user/profile/cover';
  static const String updateGender = '/user/profile/gender';
  static const String updateCategory = '/user/profile/category';
  static const String updateType = '/user/profile/type';
  static String followers(String userId) => '/user/profile/followers/$userId';
  static String following(String userId) => '/user/profile/following/$userId';

  // Follow System
  static String followRequest(String userId) => '/follow/request/$userId';
  static String followAccept(String requestId) => '/follow/accept/$requestId';
  static String followRemove(String userId) => '/follow/remove/$userId';
  static String followStatus(String userId) => '/follow/status/$userId';
  static String followBack(String userId) => '/follow/follow-back/$userId';
  static const String followSuggestions = '/follow/suggestions';

  // Posts
  static const String uploadPost = '/post/upload';
  static String deletePost(String postId) => '/post/delete/$postId';
  static String postDetails(String postId) => '/post/details/$postId';
  static String likePost(String postId) => '/post/like/$postId';
  static String unlikePost(String postId) => '/post/unlike/$postId';
  static String commentPost(String postId) => '/post/comment/$postId';
  static String deleteComment(String commentId) => '/post/comment/$commentId';
  static String sharePost(String postId) => '/post/share/$postId';
  static String savePost(String postId) => '/post/save/$postId';
  static String reportPost(String postId) => '/post/report/$postId';

  // Stories
  static const String uploadStory = '/story/upload';
  static String deleteStory(String storyId) => '/story/delete/$storyId';
  static String userStory(String userId) => '/story/user/$userId';

  // Reels
  static const String uploadReel = '/reel/upload';
  static String deleteReel(String reelId) => '/reel/delete/$reelId';
  static String reelDetails(String reelId) => '/reel/details/$reelId';
  static String likeReel(String reelId) => '/reel/like/$reelId';

  // Feeds
  static const String homeFeed = '/feed/home';
  static const String reelsFeed = '/feed/reels';
  static const String storiesFeed = '/feed/stories';
  static String userPosts(String userId) => '/feed/posts/$userId';

  // Live Stream
  static const String liveStart = '/live/start';
  static const String liveEnd = '/live/end';
  static String liveInvite(String userId) => '/live/invite/$userId';
  static String liveJoin(String liveId) => '/live/join/$liveId';
  static String liveExit(String liveId) => '/live/exit/$liveId';
  static String liveViewers(String liveId) => '/live/viewers/$liveId';

  // Search
  static const String searchGlobal = '/search/global';
  static const String searchUsers = '/search/users';
  static const String searchPages = '/search/pages';
  static const String searchHashtags = '/search/hashtags';
  static const String searchTrending = '/search/trending';

  // Chat
  static String chatThread(String receiverId) => '/chat/thread/$receiverId';
  static const String chatThreads = '/chat/threads';
  static String sendMessage(String threadId) => '/chat/message/send/$threadId';
  static String deleteMessage(String messageId) => '/chat/message/delete/$messageId';
  static String editMessage(String messageId) => '/chat/message/edit/$messageId';
  static String chatMessages(String threadId) => '/chat/messages/$threadId';
  static String markSeen(String threadId) => '/chat/messages/seen/$threadId';
  static const String uploadChatMedia = '/chat/media/upload';

  // Notifications
  static const String notificationsList = '/notifications/list';
  static String markAsRead(String notificationId) => '/notifications/read/$notificationId';
  static const String readAll = '/notifications/read-all'; // FIXED - ADDED THIS
  static const String updateNotificationSettings = '/notifications/settings/update';

  // Business Suite
  static const String businessRegister = '/business/register';
  static const String businessUpdate = '/business/update';
  static String businessVerify(String businessId) => '/business/verify/$businessId';
  static String businessDashboard(String businessId) => '/business/dashboard/$businessId';
  static const String businessPostCreate = '/business/post/create';
  static const String businessPostSchedule = '/business/post/schedule';

  // System
  static const String appUpdate = '/system/app-update';
  static const String serverHealth = '/system/server-health';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return base + endpoint;
  }
}
