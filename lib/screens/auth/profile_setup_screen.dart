import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../data/providers/user_provider.dart';
import '../../config/routes.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _dobController = TextEditingController();

  File? _profileImage;
  String _selectedGender = 'Female';
  String _selectedType = 'Public';
  bool _isUsernameAvailable = true;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _types = ['Public', 'Private'];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _checkUsername(String username) {
    // Simulate username check
    setState(() {
      _isUsernameAvailable = username.length > 3;
    });
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isUsernameAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username not available')),
      );
      return;
    }

    // TODO: Upload profile data
    Navigator.pushReplacementNamed(context, AppRoutes.interests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'Set Up your profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          shape: BoxShape.circle,
                          image: _profileImage != null
                              ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: _profileImage == null
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textLight,
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Name Field
                CustomTextField(
                  label: 'Name',
                  hint: 'Eva Jones',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Username Field
                CustomTextField(
                  label: 'Username',
                  hint: 'evajeva_micks',
                  controller: _usernameController,
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? Icon(
                    _isUsernameAvailable ? Icons.check_circle : Icons.cancel,
                    color: _isUsernameAvailable ? AppColors.success : AppColors.error,
                  )
                      : const Icon(Icons.edit, color: AppColors.textLight),
                  onChanged: _checkUsername,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    if (value.length < 3) {
                      return 'Username too short';
                    }
                    return null;
                  },
                ),
                if (_usernameController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _isUsernameAvailable ? 'Available' : 'Not Available',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isUsernameAvailable
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Type Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: _types.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Bio Field
                CustomTextField(
                  label: 'Bio',
                  hint: 'XXX',
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 144,
                ),
                const SizedBox(height: 16),
                // Gender and DOB Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gender',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _genders.map((String gender) {
                                  return DropdownMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedGender = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: CustomTextField(
                          label: 'Date of Birth',
                          hint: 'xx/xx/xxxx',
                          controller: _dobController,
                          readOnly: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Next Button
                CustomButton(
                  text: 'Next',
                  onPressed: _handleNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}