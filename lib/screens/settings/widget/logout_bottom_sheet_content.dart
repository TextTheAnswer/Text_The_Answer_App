import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_bloc.dart';
import 'package:text_the_answer/blocs/auth/auth_event.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/router/routes.dart';
import 'package:text_the_answer/widgets/bottom_sheet/bottom_sheet_shell.dart';
import 'package:text_the_answer/widgets/custom_3d_button.dart';

class LogoutBottomSheetContent extends StatelessWidget {
  const LogoutBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomSheetShell(
      headerText: 'Logout',
      headerTextColor: Colors.red,
      children: [
        // -- Text
        Center(child: Text('Are you sure you want to log out?')),
        SizedBox(height: 30),

        // -- Action
        Row(
          children: [
            // -- Cancel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Custom3DButton(
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Text('Cancel'),
                ),
              ),
            ),

            // -- Logout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Custom3DButton(
                  backgroundColor: AppColors.buttonPrimary,
                  onPressed: () {
                    context.read<AuthBloc>().add(SignOutEvent());
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, Routes.login);
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Text('Logout'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
