import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/models/user_profile_full_model.dart';
import 'package:text_the_answer/models/user_profile_model.dart';
import 'package:text_the_answer/utils/constants/breakpoint.dart';
import 'package:text_the_answer/utils/validators/validation.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/widgets/custom_3d_button.dart';
import 'package:text_the_answer/widgets/custom_bottom_button_with_divider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profileDetails});

  final ProfileData profileDetails;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // -- Text Controller
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;

  late final ValueNotifier<XFile?> _pickedImageNotifier;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.profileDetails.name,
    );
    _emailController = TextEditingController(text: widget.profileDetails.email);
    _usernameController = TextEditingController(text: widget.profileDetails.id);
    _pickedImageNotifier = ValueNotifier(null);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _pickedImageNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _pickedImageNotifier.value = picked;
    }
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Perform remove action
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile saved successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackArrow: true, title: Text('Personal Info')),
      bottomNavigationBar: CustomBottomButtonWithDivider(
        child: Custom3DButton(
          backgroundColor: AppColors.buttonPrimary,
          borderRadius: BorderRadius.circular(100),
          onPressed: _saveProfile,
          child: Text('Save'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > kTabletBreakingPoint;

            final profileHeader = ValueListenableBuilder<XFile?>(
              valueListenable: _pickedImageNotifier,
              builder: (context, pickedFile, _) {
                return _EditProfilePicture(
                  networkImageUrl: widget.profileDetails.profile?.imageUrl,
                  localFile: pickedFile,
                  onEditPressed: _pickNewImage,
                );
              },
            );

            final formFields = Column(
              children: <Widget>[
                // -- Full name
                TextFormField(
                  controller: _fullNameController,
                  validator:
                      (value) =>
                          CustomValidator.validateEmptyText('Full name', value),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Email
                TextFormField(
                  controller: _emailController,
                  validator: CustomValidator.validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Username
                TextFormField(
                  controller: _usernameController,
                  validator:
                      (value) =>
                          CustomValidator.validateEmptyText('Username', value),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );

            return Form(
              key: _formKey,
              child:
                  isWide
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Center(child: profileHeader),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(child: formFields),
                          ),
                        ],
                      )
                      : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              profileHeader,
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 20),
                              formFields,
                            ],
                          ),
                        ),
                      ),
            );
          },
        ),
      ),
    );
  }
}

class _EditProfilePicture extends StatelessWidget {
  const _EditProfilePicture({
    this.networkImageUrl,
    this.localFile,
    this.onEditPressed,
  });

  final String? networkImageUrl;
  final XFile? localFile;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;

    if (localFile != null) {
      imageProvider = FileImage(File(localFile!.path));
    } else {
      imageProvider = CachedNetworkImageProvider(networkImageUrl!);
    }

    return Stack(
      children: [
        // -- Image
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey,
          backgroundImage: imageProvider,
        ),

        // -- Edit Button
        Positioned(
          bottom: 1,
          right: 1,
          child: GestureDetector(
            onTap: onEditPressed,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.buttonPrimary,
              ),
              child: Icon(IconsaxPlusBold.edit_2, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
