import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_event.dart';
import 'package:text_the_answer/blocs/auth/auth_state.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile_model.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/services/profile_service.dart';
import 'package:text_the_answer/services/auth_token_service.dart';
import 'package:text_the_answer/utils/auth_helper.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/widgets/custom_button.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:text_the_answer/config/api_config.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({super.key});

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedAvatar;
  File? _customImageFile;
  final _picker = ImagePicker();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  // Two default avatar options
  final List<Map<String, String>> _avatarOptions = [
    {'path': 'assets/images/man.png', 'label': 'Male'},
    {'path': 'assets/images/woman.png', 'label': 'Female'},
  ];

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set default avatar selection
    _selectedAvatar = _avatarOptions[0]['path'];

    print(
      'ProfileCreationScreen: initState - Will verify authentication status',
    );

    // Check auth status silently after widget is built, without emitting loading state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        print(
          'ProfileCreationScreen: Post-build - Checking authentication silently',
        );
        
        // Verify authentication silently first
        final isAuth = await AuthHelper.verifyAuthentication(silentCheck: true);
        
        // If not authenticated, try a token refresh
        if (!isAuth && mounted) {
          print('ProfileCreationScreen: Not authenticated initially, forcing token refresh');
          await AuthHelper.refreshToken();
        }
        
        // Print final authentication status
        if (mounted) {
          final finalAuthStatus = AuthHelper.isAuthenticated();
          print('ProfileCreationScreen: Final authentication status: $finalAuthStatus');
        }
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200, // Increased max dimensions for better quality
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        // Validate the image file (size, format, etc.)
        final bool isValid = await _validateImageFile(imageFile);

        if (isValid) {
          if (!mounted) return;
          setState(() {
            _customImageFile = imageFile;
            _selectedAvatar = null; // Clear selected default avatar
          });
        } else {
          // Show error message if image is invalid
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please select a valid image file (JPG or PNG) under 5MB.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors more gracefully
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not access camera or gallery. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      print('Image picker error: $e');
    }
  }

  // Validate the image file
  Future<bool> _validateImageFile(File file) async {
    try {
      // Check file size (max 5MB)
      final int fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        print(
          'ProfileCreationScreen: Image too large: ${fileSize / 1024 / 1024}MB',
        );
        return false;
      }

      // Check file extension (JPG, PNG)
      final String path = file.path.toLowerCase();
      if (!path.endsWith('.jpg') &&
          !path.endsWith('.jpeg') &&
          !path.endsWith('.png')) {
        print('ProfileCreationScreen: Invalid image format: $path');
        return false;
      }

      print(
        'ProfileCreationScreen: Image validated successfully: ${fileSize / 1024}KB',
      );
      return true;
    } catch (e) {
      print('ProfileCreationScreen: Error validating image: $e');
      return false;
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Picture',
                  style: FontUtility.montserratBold(fontSize: 18),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImagePickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildImagePickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: FontUtility.montserratMedium(fontSize: 14)),
        ],
      ),
    );
  }

  // Updated method to force token refresh using AuthHelper
  void _forceTokenRefresh() {
    print('ProfileCreationScreen: Forcing token refresh');
    AuthHelper.refreshToken();
    
    // Also add a direct check to verify authentication status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('ProfileCreationScreen: Verifying authentication after token refresh');
        
        // Check if auth succeeded
        final isAuth = _isAuthenticated();
        print('ProfileCreationScreen: Authentication status after refresh: $isAuth');
      }
    });
  }

  // Check if user is authenticated directly from the global auth state
  bool _isAuthenticated() {
    // Direct read from authBloc without triggering state changes
    return AuthHelper.isAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only listen to transitions from authenticated to unauthenticated
        // or when an auth error occurs
        return (previous is AuthAuthenticated && current is! AuthAuthenticated) ||
               (current is AuthError);
      },
      listener: (context, state) {
        // Only handle auth errors or transitions to unauthenticated state
        if (state is AuthError) {
          print(
            'ProfileCreationScreen: BlocListener detected AuthError - ${state.message}',
          );

          // Use a flag to prevent multiple navigations
          if (!mounted) return;

          // Schedule navigation after the frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check again if still mounted before showing UI or navigating
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Authentication error: ${state.message}. Please login again.',
                ),
                backgroundColor: Colors.red,
              ),
            );

            // Navigate to login screen
            Navigator.of(context).pushReplacementNamed(Routes.login);
          });
        } else if (state is AuthInitial) {
          print(
            'ProfileCreationScreen: BlocListener detected unauthenticated state',
          );

          // Handle unauthenticated state
          if (!mounted) return;

          // Schedule navigation after the frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Check again if still mounted before showing UI or navigating
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Authentication required. Please login again.'),
                backgroundColor: Colors.red,
              ),
            );

            // Navigate to login screen
            Navigator.of(context).pushReplacementNamed(Routes.login);
          });
        }
      },
      child: _buildScreenContent(),
    );
  }

  // Extract screen content to a separate method
  Widget _buildScreenContent() {
    // Check authentication state directly
    final isAuthenticated = _isAuthenticated();
    
    // If not authenticated, show a message that we're checking auth status
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20.h),
              Text(
                'Verifying authentication...',
                style: FontUtility.montserratMedium(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // If authenticated, show the main screen
    return _buildMainScreen();
  }

  Widget _buildMainScreen() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: FontUtility.montserratBold(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            colors: [AppColors.primary, AppColors.primary],
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/auth_bg_pattern.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Avatar',
                style: FontUtility.montserratSemiBold(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              Text(
                'Select an avatar or upload your own photo',
                style: FontUtility.interRegular(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 24.h),

              // Avatar selection
              Center(
                child:
                    _customImageFile != null
                        ? _buildProfileImagePreview()
                        : _buildAvatarSelection(),
              ),
              SizedBox(height: 16.h),

              // Upload photo button
              Center(child: _buildUploadPhotoButton()),
              SizedBox(height: 24.h),

              Text(
                'Display Name',
                style: FontUtility.montserratSemiBold(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              CustomTextField(
                controller: _displayNameController,
                hintText: 'Enter your display name',
                darkMode: true,
              ),
              SizedBox(height: 24.h),

              Text(
                'Location',
                style: FontUtility.montserratSemiBold(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              CustomTextField(
                controller: _locationController,
                hintText: 'Your city or country (optional)',
                darkMode: true,
              ),
              SizedBox(height: 24.h),

              Text(
                'Bio',
                style: FontUtility.montserratSemiBold(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),

              CustomTextField(
                controller: _bioController,
                hintText: 'Tell us a bit about yourself',
                maxLines: 3,
                darkMode: true,
              ),
              SizedBox(height: 40.h),

              CustomButton(
                text: 'COMPLETE PROFILE',
                buttonType: CustomButtonType.primary,
                buttonSize: CustomButtonSize.large,
                fullWidth: true,
                onPressed: _saveProfile,
                textColor: AppColors.primary,
                bgColor: Colors.white,
                isLoading: _isLoading,
              ),
              SizedBox(height: 16.h),

              CustomButton(
                text: 'SKIP FOR NOW',
                buttonType: CustomButtonType.outline,
                buttonSize: CustomButtonSize.large,
                fullWidth: true,
                onPressed: _isLoading ? () {} : _navigateToHome,
                borderColor: Colors.white,
                textColor: Colors.white,
              ),
              
              // Add developer mode test button for API testing
              SizedBox(height: 40.h),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _isLoading ? null : _testProfileCreation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.code,
                          color: Colors.white.withOpacity(0.7),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Test API Integration',
                          style: FontUtility.montserratMedium(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Add API Connection test button
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _isLoading ? null : _testApiConnection,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi,
                          color: Colors.green.withOpacity(0.7),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Test API Connection',
                          style: FontUtility.montserratMedium(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePreview() {
    return Container(
      width: 240.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom image container with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.file(_customImageFile!, fit: BoxFit.cover),
            ),
          ),

          // Close/remove button
          Positioned(
            bottom: 5.h,
            right: 70.w,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _customImageFile = null;
                  // Reset to default avatar
                  _selectedAvatar = _avatarOptions[0]['path'];
                });
              },
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Icon(Icons.close, color: Colors.white, size: 20.sp),
              ),
            ),
          ),

          // Selected indicator
          Positioned(
            top: 5.h,
            right: 70.w,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.check, color: Colors.white, size: 18.sp),
              ),
            ),
          ),

          // Custom photo label
          Positioned(
            bottom: -15.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Custom Photo',
                style: FontUtility.montserratSemiBold(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          _avatarOptions.map((avatar) {
            final bool isSelected = avatar['path'] == _selectedAvatar;
            final String label = avatar['label']!;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = avatar['path'];
                  _customImageFile = null; // Clear custom image
                });
              },
              child: Container(
                width: 110.w,
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  children: [
                    // Avatar with selection indicator
                    Stack(
                      children: [
                        // Avatar image with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.3),
                              width: isSelected ? 3.w : 1.w,
                            ),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.35),
                                        blurRadius: 12.r,
                                        spreadRadius: 3.r,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              avatar['path']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Selection indicator
                        if (isSelected)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2.h),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Avatar label with enhanced styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.r),
                        border:
                            isSelected
                                ? Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.w,
                                )
                                : null,
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: FontUtility.montserratSemiBold(
                          fontSize: 15,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildUploadPhotoButton() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_rounded, color: Colors.white, size: 24.sp),
            SizedBox(width: 10.w),
            Text(
              'Upload Photo',
              style: FontUtility.montserratSemiBold(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Upload profile image separately
  Future<String?> _uploadProfileImage(File imageFile) async {
    try {
      print('ProfileCreationScreen: Starting separate image upload');

      // Show uploading indicator
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploading profile image...'),
          duration: Duration(
            seconds: 30,
          ), // Long duration as upload might take time
          backgroundColor: Colors.blue,
        ),
      );

      // Call the dedicated upload method
      final uploadResponse = await _profileService.uploadProfileImage(
        imageFile,
      );

      // Dismiss the snackbar
      if (!mounted)
        return uploadResponse.success ? uploadResponse.profile?.imageUrl : null;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (uploadResponse.success && uploadResponse.profile != null) {
        print(
          'ProfileCreationScreen: Image upload succeeded: ${uploadResponse.profile!.imageUrl}',
        );
        return uploadResponse.profile!.imageUrl;
      } else {
        print(
          'ProfileCreationScreen: Image upload failed: ${uploadResponse.message}',
        );

        // Show error message
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: ${uploadResponse.message}'),
            backgroundColor: Colors.orange,
          ),
        );
        return null;
      }
    } catch (e) {
      print('ProfileCreationScreen: Exception during image upload: $e');

      // Dismiss the snackbar and show error
      if (!mounted) return null;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _saveProfile() async {
    try {
      // Debug token directly
      final authTokenService = AuthTokenService();
      final token = await authTokenService.getToken();
      print('ProfileCreationScreen: Checking token directly before profile creation');
      if (token == null || token.isEmpty) {
        print('ProfileCreationScreen: No token available!');
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No authentication token found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
        return;
      }
      
      print('ProfileCreationScreen: Token found: ${token.substring(0, min(10, token.length))}...');
      
      // Check authentication directly - without triggering state changes
      final isAuth = _isAuthenticated();

      print(
        'ProfileCreationScreen: _saveProfile - Auth check result: $isAuth',
      );

      // If not authenticated, force a token refresh first
      if (!isAuth) {
        print(
          'ProfileCreationScreen: _saveProfile - Not authenticated, trying token refresh first',
        );
        
        // Force token refresh
        _forceTokenRefresh();
        
        // Give it a moment to refresh
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check auth status again 
        final isAuthAfterRefresh = _isAuthenticated();
        print('ProfileCreationScreen: Auth after refresh: $isAuthAfterRefresh');
        
        if (!isAuthAfterRefresh) {
          if (!mounted) return;
          
          // If still not authenticated, redirect to login
          print('ProfileCreationScreen: Still not authenticated after refresh, redirecting to login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Use direct navigation instead of helper to avoid potential circular issues
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              print('ProfileCreationScreen: Navigating to login screen');
              Navigator.of(context).pushReplacementNamed(Routes.login);
            }
          });
          
          return;
        }
      }
      
      // Continue with the profile creation if authenticated
      print('ProfileCreationScreen: User is authenticated, proceeding with profile creation');

      // Validate input
      if (_displayNameController.text.trim().isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a display name')));
        return;
      }

      if (_selectedAvatar == null && _customImageFile == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an avatar or upload a photo')),
        );
        return;
      }

      // Get the display name
      final displayName = _displayNameController.text.trim();
      
      setState(() {
        _isLoading = true;
      });

      // If a custom image is selected, upload it first
      String? imageUrl;
      if (_customImageFile != null) {
        imageUrl = await _uploadProfileImage(_customImageFile!);

        // If image upload failed but it's critical, stop the profile creation
        if (imageUrl == null) {
          print(
            'ProfileCreationScreen: Image upload failed, aborting profile creation',
          );
          setState(() {
            _isLoading = false;
          });

          // Show error message
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile image upload failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      // If we're using a default avatar, set the image URL to the path
      else if (_selectedAvatar != null) {
        // Using a default avatar - no need to upload, just pass the local path
        print('ProfileCreationScreen: Using default avatar: $_selectedAvatar');
      }

      // Create notification settings
      final notificationSettings = NotificationSettings(
        dailyQuizReminder: true,
        multiplayerInvites: true,
      );

      // Create profile preferences
      final preferences = ProfilePreferences(
        favoriteCategories: ['General Knowledge', 'Science', 'History'],
        notificationSettings: notificationSettings,
        displayTheme: 'light',
      );

      print(
        'ProfileCreationScreen: Creating profile with display name: $displayName, image URL: $imageUrl',
      );

      // Call the profile service to create the profile without the image file
      final response = await _profileService.createProfile(
        displayName: displayName,
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        // Don't pass the image file here as we already uploaded it
        profileImageFile: null,
        preferences: preferences,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success) {
        // Show success message
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to home screen after a short delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            _navigateToHome();
          }
        });
      } else {
        print(
          'ProfileCreationScreen: Profile creation failed with message: ${response.message}',
        );

        if (response.message.toLowerCase().contains('auth') ||
            response.message.toLowerCase().contains('login') ||
            response.message.toLowerCase().contains('token')) {
          // Handle authentication error
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication error: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );

          // Force a reauthentication and show debug info
          print('ProfileCreationScreen: Forcing token refresh due to auth error');
          _forceTokenRefresh();

          // Redirect to login after a short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.of(context).pushReplacementNamed(Routes.login);
          });
        } else {
          // Show other error messages
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('ProfileCreationScreen: Exception during profile creation: $e');

      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
  }

  // Add a test function to test the profile creation API
  Future<void> _testProfileCreation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await _profileService.testProfileCreation();
      
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Test successful! Profile created.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Test failed: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in API test: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add a test for API connection
  Future<void> _testApiConnection() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authTokenService = AuthTokenService();
      final token = await authTokenService.getToken();
      
      if (token == null || token.isEmpty) {
        print('Test API: No token available');
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No auth token found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      print('Test API: Using token: ${token.substring(0, min(10, token.length))}...');
      
      // Make a simple GET request to the API
      try {
        final baseUrl = ApiConfig.baseUrl;
        // Construct the proper URL with the correct API path
        final testUrl = '${baseUrl}/auth/me';
            
        print('Test API: Making GET request to: $testUrl');
        
        final response = await http.get(
          Uri.parse(testUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        print('Test API: Response status: ${response.statusCode}');
        print('Test API: Response body: ${response.body}');
        
        if (!mounted) return;
        
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API connection successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('API connection failed: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Test API: Error connecting to API: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Test API: Exception: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
