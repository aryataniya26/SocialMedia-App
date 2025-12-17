import 'package:clickme_app/data/providers/follow_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final bool isPrivateProfile;
  final bool? initialFollowing;
  final String? requestId;
  final Function(bool)? onStateChanged;
  final double? height;
  final double? width;
  final bool showIcon;

  const FollowButton({
    Key? key,
    required this.targetUserId,
    this.isPrivateProfile = false,
    this.initialFollowing,
    this.requestId,
    this.onStateChanged,
    this.height = 36,
    this.width,
    this.showIcon = true,
  }) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isLoading = false;
  bool _isFollowing = false;
  bool _hasRequested = false;
  bool _isFollowedBy = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFollowing != null) {
      _isFollowing = widget.initialFollowing!;
    }
    if (widget.requestId != null) {
      _hasRequested = true;
    }
  }

  Future<void> _handleFollow() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final followProvider = Provider.of<FollowProvider>(context, listen: false);

    if (_isFollowing) {
      // Unfollow
      final result = await followProvider.unfollowUser(widget.targetUserId);
      if (result['success'] == true) {
        setState(() {
          _isFollowing = false;
          _hasRequested = false;
        });
        widget.onStateChanged?.call(false);
      }
    } else if (_hasRequested) {
      // Cancel request
      final result = await followProvider.unfollowUser(widget.targetUserId);
      if (result['success'] == true) {
        setState(() => _hasRequested = false);
        widget.onStateChanged?.call(false);
      }
    } else {
      // Send follow request
      final result = await followProvider.sendFollowRequest(widget.targetUserId);
      if (result['success'] == true) {
        setState(() {
          if (widget.isPrivateProfile) {
            _hasRequested = true;
          } else {
            _isFollowing = true;
          }
        });
        widget.onStateChanged?.call(true);
      }
    }

    setState(() => _isLoading = false);
  }

  String _getButtonText() {
    if (_isLoading) return '...';
    if (_isFollowing) return 'Following';
    if (_hasRequested) return 'Requested';
    if (_isFollowedBy && !_isFollowing) return 'Follow Back';
    return 'Follow';
  }

  Color _getButtonColor() {
    if (_isLoading) return Colors.grey;
    if (_isFollowing || _hasRequested) return Colors.grey[200]!;
    return Colors.blue;
  }

  Color _getTextColor() {
    if (_isLoading) return Colors.white;
    if (_isFollowing || _hasRequested) return Colors.black;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleFollow,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _getButtonColor(),
          borderRadius: BorderRadius.circular(20),
          border: (_isFollowing || _hasRequested)
              ? Border.all(color: Colors.grey[300]!)
              : null,
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getTextColor(),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showIcon && !_isFollowing && !_hasRequested)
                Icon(
                  Icons.add,
                  size: 16,
                  color: _getTextColor(),
                ),
              if (widget.showIcon) const SizedBox(width: 6),
              Text(
                _getButtonText(),
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:clickme_app/data/providers/follow_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class FollowButton extends StatelessWidget {
//   final String userId;
//   final String initialStatus; // 'none', 'following', 'pending'
//   final VoidCallback? onFollowStatusChanged;
//
//   const FollowButton({
//     Key? key,
//     required this.userId,
//     this.initialStatus = 'none',
//     this.onFollowStatusChanged,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FollowProvider>(
//       builder: (context, followProvider, child) {
//         final status = followProvider.getFollowStatus(userId);
//         final currentStatus = status != 'none' ? status : initialStatus;
//         final isLoading = followProvider.isLoading;
//
//         return _buildButton(context, currentStatus, isLoading, followProvider);
//       },
//     );
//   }
//
//   Widget _buildButton(
//       BuildContext context,
//       String status,
//       bool isLoading,
//       FollowProvider followProvider,
//       ) {
//     // Button style based on status
//     Color backgroundColor;
//     Color textColor;
//     String buttonText;
//     VoidCallback? onPressed;
//
//     switch (status) {
//       case 'following':
//         backgroundColor = Colors.grey.shade300;
//         textColor = Colors.black87;
//         buttonText = 'Following';
//         onPressed = () => _handleUnfollow(context, followProvider);
//         break;
//
//       case 'pending':
//         backgroundColor = Colors.grey.shade300;
//         textColor = Colors.black87;
//         buttonText = 'Requested';
//         onPressed = null; // Disable button for pending
//         break;
//
//       case 'none':
//       default:
//         backgroundColor = const Color(0xFF7C3AED); // Purple
//         textColor = Colors.white;
//         buttonText = 'Follow';
//         onPressed = () => _handleFollow(context, followProvider);
//         break;
//     }
//
//     return SizedBox(
//       height: 36,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           foregroundColor: textColor,
//           elevation: 0,
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: isLoading
//             ? const SizedBox(
//           height: 20,
//           width: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//             : Text(
//           buttonText,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _handleFollow(BuildContext context, FollowProvider followProvider) async {
//     final success = await followProvider.sendFollowRequest(userId);
//
//     if (success) {
//       onFollowStatusChanged?.call();
//
//       if (context.mounted) {
//         final status = followProvider.getFollowStatus(userId);
//         final message = status == 'following'
//             ? 'Now following user'
//             : 'Follow request sent';
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(message),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } else {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(followProvider.errorMessage ?? 'Failed to follow'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }
//
//   void _handleUnfollow(BuildContext context, FollowProvider followProvider) async {
//     // Show confirmation dialog
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Unfollow'),
//         content: const Text('Are you sure you want to unfollow this user?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Unfollow'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       final success = await followProvider.unfollowUser(userId);
//
//       if (success) {
//         onFollowStatusChanged?.call();
//
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Unfollowed successfully'),
//               backgroundColor: Colors.grey,
//               duration: Duration(seconds: 2),
//             ),
//           );
//         }
//       } else {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(followProvider.errorMessage ?? 'Failed to unfollow'),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         }
//       }
//     }
//   }
// }
//
// // ==================== COMPACT FOLLOW BUTTON ====================
// // Small version for lists
// class CompactFollowButton extends StatelessWidget {
//   final String userId;
//   final String initialStatus;
//
//   const CompactFollowButton({
//     Key? key,
//     required this.userId,
//     this.initialStatus = 'none',
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FollowProvider>(
//       builder: (context, followProvider, child) {
//         final status = followProvider.getFollowStatus(userId);
//         final currentStatus = status != 'none' ? status : initialStatus;
//
//         return SizedBox(
//           height: 30,
//           width: 90,
//           child: OutlinedButton(
//             onPressed: () => _handleAction(context, followProvider, currentStatus),
//             style: OutlinedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               side: BorderSide(
//                 color: currentStatus == 'following'
//                     ? Colors.grey.shade400
//                     : const Color(0xFF7C3AED),
//               ),
//             ),
//             child: Text(
//               currentStatus == 'following' ? 'Following' : 'Follow',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: currentStatus == 'following'
//                     ? Colors.grey.shade700
//                     : const Color(0xFF7C3AED),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _handleAction(
//       BuildContext context,
//       FollowProvider followProvider,
//       String status,
//       ) {
//     if (status == 'following') {
//       followProvider.unfollowUser(userId);
//     } else {
//       followProvider.sendFollowRequest(userId);
//     }
//   }
// }