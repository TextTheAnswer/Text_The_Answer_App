import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_the_answer/blocs/profile/profile_bloc.dart';
import 'package:text_the_answer/blocs/profile/profile_event.dart';
import 'package:text_the_answer/blocs/profile/profile_state.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/profile.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/theme/theme_cubit.dart';
import 'package:text_the_answer/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileData profile;

  const EditProfileScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.profile.bio);
    _locationController = TextEditingController(text: widget.profile.profile.location);

    // Listen for changes to track if user has made edits
    _nameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final hasChanges = 
      _nameController.text != widget.profile.name ||
      _bioController.text != widget.profile.profile.bio ||
      _locationController.text != widget.profile.profile.location;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      _isLoading = true;
    });

    // Only include fields that have changed
    final String? name = _nameController.text != widget.profile.name
        ? _nameController.text.trim()
        : null;

    final String? bio = _bioController.text != widget.profile.profile.bio
        ? _bioController.text.trim()
        : null;

    final String? location = _locationController.text != widget.profile.profile.location
        ? _locationController.text.trim()
        : null;

    final profileBloc = context.read<ProfileBloc>();
    profileBloc.add(UpdateProfileEvent(
      name: name,
      bio: bio,
      location: location,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdating) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is ProfileLoaded) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ProfileUpdateError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isDarkMode = context.select<ThemeCubit, bool>(
          (cubit) => cubit.state.mode == AppThemeMode.dark,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Edit Profile',
              style: FontUtility.montserratBold(
                fontSize: 20.sp,
                color: isDarkMode ? Colors.white : AppColors.darkGray,
              ),
            ),
            actions: [
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.all(12.r),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.save,
                    color: _hasChanges
                        ? isDarkMode
                            ? Colors.white
                            : AppColors.primary
                        : isDarkMode
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.5),
                  ),
                  onPressed: _hasChanges ? _saveProfile : null,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: isDarkMode
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.primary.withOpacity(0.2),
                        backgroundImage: widget.profile.profile.imageUrl.isNotEmpty
                            ? NetworkImage(widget.profile.profile.imageUrl)
                            : null,
                        child: widget.profile.profile.imageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50.r,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                Text(
                  'Name',
                  style: FontUtility.montserratMedium(
                    fontSize: 16.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Your Name',
                  darkMode: isDarkMode,
                  prefixIcon: Icon(Icons.person_outline),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                ),
                
                SizedBox(height: 24.h),
                
                Text(
                  'Bio',
                  style: FontUtility.montserratMedium(
                    fontSize: 16.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _bioController,
                  hintText: 'Tell us about yourself',
                  darkMode: isDarkMode,
                  prefixIcon: Icon(Icons.info_outline),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                ),
                
                SizedBox(height: 24.h),
                
                Text(
                  'Location',
                  style: FontUtility.montserratMedium(
                    fontSize: 16.sp,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _locationController,
                  hintText: 'Your Location',
                  darkMode: isDarkMode,
                  prefixIcon: Icon(Icons.location_on_outlined),
                  keyboardType: TextInputType.text,
                ),
                
                SizedBox(height: 40.h),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      disabledBackgroundColor: isDarkMode
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: FontUtility.montserratBold(
                              fontSize: 16.sp,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 