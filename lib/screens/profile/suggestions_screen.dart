import 'package:clickme_app/screens/home/widgets/follow_buttoon_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/follow_provider.dart';
import '../../data/models/suggested_user_model.dart';
import '../../core/widgets/loading_widget.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSuggestions();
    });
  }

  Future<void> _loadSuggestions() async {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    await followProvider.getFollowSuggestions(refresh: true);
  }

  String _getReasonText(String reason) {
    switch (reason) {
      case 'mutual_friends':
        return 'Followed by people you know';
      case 'same_interest':
        return 'Similar interests';
      case 'popular':
        return 'Popular on ClickME';
      default:
        return 'Suggested for you';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuggestions,
          ),
        ],
      ),
      body: Consumer<FollowProvider>(
        builder: (context, followProvider, _) {
          if (followProvider.isLoading && followProvider.suggestions.isEmpty) {
            return const Center(child: LoadingWidget());
          }

          final suggestions = followProvider.suggestions;

          return RefreshIndicator(
            onRefresh: () async {
              await followProvider.getFollowSuggestions(refresh: true);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final user = suggestions[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Row
                        Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              child: user.profileImage != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  user.profileImage!,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                              )
                                  : Text(
                                user.firstName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // User Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (user.isVerified) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (user.bio != null && user.bio!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        user.bio!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (user.mutualFriends > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${user.mutualFriends} mutual friends',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _getReasonText(user.reason),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Follow Button
                            FollowButton(
                              targetUserId: user.id,
                              height: 36,
                              width: 100,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}