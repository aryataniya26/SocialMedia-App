import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../data/providers/story_provider.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedMedia;
  String? _caption;
  bool _isUploading = false;

  Future<void> _pickFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedMedia = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedMedia = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _uploadStory() async {
    if (_selectedMedia == null) {
      _showError('Please select a photo first');
      return;
    }

    setState(() => _isUploading = true);

    // Simulate upload for testing
    await Future.delayed(const Duration(seconds: 2));

    // In real app, call provider.uploadStory()
    // final storyProvider = Provider.of<StoryProvider>(context, listen: false);
    // await storyProvider.uploadStory(mediaFile: _selectedMedia!, caption: _caption);

    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story uploaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add to Story',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Media Preview
          Expanded(
            child: _selectedMedia != null
                ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(_selectedMedia!),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add to your story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              children: [
                // Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    Column(
                      children: [
                        IconButton(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library,
                              color: Colors.white, size: 30),
                        ),
                        const Text(
                          'Gallery',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    // Camera Button
                    Column(
                      children: [
                        IconButton(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 30),
                        ),
                        const Text(
                          'Camera',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Caption Input
                TextField(
                  onChanged: (value) => _caption = value,
                  decoration: InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Share Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _uploadStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Share to Story',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../../core/constants/app_colors.dart';
// import '../../core/widgets/custom_button.dart';
//
// class CreateStoryScreen extends StatefulWidget {
//   const CreateStoryScreen({super.key});
//
//   @override
//   State<CreateStoryScreen> createState() => _CreateStoryScreenState();
// }
//
// class _CreateStoryScreenState extends State<CreateStoryScreen> {
//   File? _selectedMedia;
//   bool _isLoading = false;
//
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 1080,
//       maxHeight: 1920,
//     );
//
//     if (pickedFile != null) {
//       setState(() {
//         _selectedMedia = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _pickVideo() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickVideo(
//       source: ImageSource.gallery,
//       maxDuration: const Duration(seconds: 60),
//     );
//
//     if (pickedFile != null) {
//       setState(() {
//         _selectedMedia = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _handleShare() async {
//     if (_selectedMedia == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a photo or video')),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     // TODO: Upload to API
//     await Future.delayed(const Duration(seconds: 2));
//
//     if (!mounted) return;
//
//     setState(() {
//       _isLoading = false;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Story shared successfully!')),
//     );
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Create Story',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: _selectedMedia != null
//                 ? Center(
//               child: Image.file(
//                 _selectedMedia!,
//                 fit: BoxFit.contain,
//               ),
//             )
//                 : Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.auto_awesome,
//                     size: 80,
//                     color: Colors.white54,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Select a photo or video',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: _pickImage,
//                         icon: const Icon(Icons.photo_library),
//                         label: const Text('Photo'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       ElevatedButton.icon(
//                         onPressed: _pickVideo,
//                         icon: const Icon(Icons.videocam),
//                         label: const Text('Video'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (_selectedMedia != null)
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: Colors.black,
//               child: SafeArea(
//                 child: CustomButton(
//                   text: 'Share Story',
//                   onPressed: _handleShare,
//                   isLoading: _isLoading,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }