import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/blocs/profile/profile_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'package:text_the_answer/widgets/custom_button.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';
import 'package:text_the_answer/widgets/loading_widget.dart';

class ProfileCreationScreen extends StatefulWidget {
  const ProfileCreationScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCreationScreen> createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  late final ProfileBloc _profileBloc;
  
  // Form controllers
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Selected preferences
  final List<String> _availableCategories = [
    'science', 'math', 'history', 'geography', 'literature', 
    'arts', 'sports', 'technology', 'music', 'movies'
  ];
  final List<String> _selectedCategories = [];
  
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  String _selectedTheme = 'default'; // default, light, dark
  
  // Profile picture option
  String _selectedProfilePicture = 'man.png';
  final List<String> _profilePictureOptions = [
    'man.png', 'woman.png',
  ];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _profileBloc.close();
    super.dispose();
  }

  void _submitProfile() {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    // Create the profile data to submit
    final Map<String, dynamic> notificationSettings = {
      'email': _emailNotifications,
      'push': _pushNotifications,
    };
    
    _profileBloc.add(CreateProfileEvent(
      bio: _bioController.text.trim(),
      location: _locationController.text.trim(),
      profilePicture: _selectedProfilePicture,
      favoriteCategories: _selectedCategories,
      notificationSettings: notificationSettings,
      displayTheme: _selectedTheme,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<ThemeCubit, bool>(
      (cubit) => cubit.state.mode == AppThemeMode.dark,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Your Profile',
          style: FontUtility.montserratBold(
            fontSize: 20.sp,
            color: isDarkMode ? Colors.white : AppColors.darkGray,
          ),
        ),
      ),
      body: BlocProvider.value(
        value: _profileBloc,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded) {
              setState(() {
                _isSubmitting = false;
              });
              
              // Profile created successfully, navigate to home
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Navigate to home screen
              context.go(AppRoutePath.home);
            } else if (state is ProfileError || state is ProfileUpdateError) {
              setState(() {
                _isSubmitting = false;
              });
              
              final message = state is ProfileError 
                  ? state.message
                  : (state as ProfileUpdateError).message;
                  
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $message'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const LoadingWidget();
            }
            
            return _buildProfileForm(context, isDarkMode);
          },
        ),
      ),
    );
  }
  
  Widget _buildProfileForm(BuildContext context, bool isDarkMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text
          Text(
            'Let\'s set up your profile',
            style: FontUtility.montserratBold(
              fontSize: 24.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Customize your experience by providing some information about yourself',
            style: FontUtility.montserratRegular(
              fontSize: 16.sp,
              color: isDarkMode ? Colors.white70 : AppColors.lightGray,
            ),
          ),
          SizedBox(height: 32.h),
          
          // Profile Picture Selection
          Text(
            'Select your gender',
            style: FontUtility.montserratSemiBold(
              fontSize: 18.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose a profile image that represents your gender',
            style: FontUtility.montserratRegular(
              fontSize: 14.sp,
              color: isDarkMode ? Colors.white70 : AppColors.lightGray,
            ),
          ),
          SizedBox(height: 16.h),
          _buildProfilePictureSelector(isDarkMode),
          SizedBox(height: 24.h),
          
          // Bio field
          CustomTextField(
            controller: _bioController,
            hintText: 'Bio',
            maxLines: 3,
            darkMode: isDarkMode,
          ),
          SizedBox(height: 16.h),
          
          // Location field
          CustomTextField(
            controller: _locationController,
            hintText: 'Location (City, Country)',
            darkMode: isDarkMode,
          ),
          SizedBox(height: 24.h),
          
          // Favorite Categories
          Text(
            'Select your favorite categories',
            style: FontUtility.montserratSemiBold(
              fontSize: 18.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 16.h),
          _buildCategorySelector(isDarkMode),
          SizedBox(height: 24.h),
          
          // Notification Settings
          Text(
            'Notification Preferences',
            style: FontUtility.montserratSemiBold(
              fontSize: 18.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 16.h),
          _buildNotificationSettings(isDarkMode),
          SizedBox(height: 24.h),
          
          // Theme preference
          Text(
            'Display Theme',
            style: FontUtility.montserratSemiBold(
              fontSize: 18.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          SizedBox(height: 16.h),
          _buildThemeSelector(isDarkMode),
          SizedBox(height: 40.h),
          
          // Submit Button
          CustomButton(
            text: 'Create Profile',
            isLoading: _isSubmitting,
            onPressed: _submitProfile,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
  
  Widget _buildProfilePictureSelector(bool isDarkMode) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _profilePictureOptions.map((option) {
              final isSelected = _selectedProfilePicture == option;
              final label = option == 'man.png' ? 'Male' : 'Female';
              
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedProfilePicture = option;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 16.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                            ? Theme.of(context).primaryColor 
                            : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 36.r,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: AssetImage('assets/images/$option'),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    margin: EdgeInsets.only(right: 16.w),
                    child: Text(
                      label,
                      style: FontUtility.montserratMedium(
                        fontSize: 14.sp,
                        color: isSelected
                          ? Theme.of(context).primaryColor
                          : isDarkMode ? Colors.white : AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategorySelector(bool isDarkMode) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _availableCategories.map((category) {
        final isSelected = _selectedCategories.contains(category);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedCategories.remove(category);
              } else {
                _selectedCategories.add(category);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected 
                ? Theme.of(context).primaryColor 
                : isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              category[0].toUpperCase() + category.substring(1),
              style: FontUtility.montserratMedium(
                fontSize: 14.sp,
                color: isSelected 
                  ? Colors.white 
                  : isDarkMode ? Colors.white70 : AppColors.darkGray,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildNotificationSettings(bool isDarkMode) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Email Notifications',
            style: FontUtility.montserratMedium(
              fontSize: 16.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
          activeColor: Theme.of(context).primaryColor,
        ),
        SwitchListTile(
          title: Text(
            'Push Notifications',
            style: FontUtility.montserratMedium(
              fontSize: 16.sp,
              color: isDarkMode ? Colors.white : AppColors.darkGray,
            ),
          ),
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
  
  Widget _buildThemeSelector(bool isDarkMode) {
    return Row(
      children: [
        _buildThemeOption('Default', 'default', isDarkMode),
        SizedBox(width: 16.w),
        _buildThemeOption('Light', 'light', isDarkMode),
        SizedBox(width: 16.w),
        _buildThemeOption('Dark', 'dark', isDarkMode),
      ],
    );
  }
  
  Widget _buildThemeOption(String label, String value, bool isDarkMode) {
    final isSelected = _selectedTheme == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).primaryColor 
            : isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: FontUtility.montserratMedium(
            fontSize: 16.sp,
            color: isSelected 
              ? Colors.white 
              : isDarkMode ? Colors.white70 : AppColors.darkGray,
          ),
        ),
      ),
    );
  }
} 