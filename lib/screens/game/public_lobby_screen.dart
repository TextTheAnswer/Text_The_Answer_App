import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:text_the_answer/config/colors.dart';
import 'package:text_the_answer/utils/font_utility.dart';
import 'package:text_the_answer/utils/logger/debug_print.dart';
import 'package:text_the_answer/utils/orientation/portrait_mode_mixin.dart';
import 'package:text_the_answer/widgets/app_bar/custom_app_bar.dart';
import 'package:text_the_answer/widgets/custom_3D_button.dart';

class PublicLobbyScreen extends StatefulWidget {
  const PublicLobbyScreen({super.key});

  @override
  State<PublicLobbyScreen> createState() => _PublicLobbyScreenState();
}

class _PublicLobbyScreenState extends State<PublicLobbyScreen>
    with PortraitStatefulModeMixin<PublicLobbyScreen> {
  final TextEditingController _textController = TextEditingController();

  //TODO: Implement browser public lobbies ui and functionality

  /// Add space after every 3 digits (e.g., 123 456)
  String _formatInput(String text) {
    return text
        .replaceAllMapped(RegExp(r'.{1,3}'), (match) => '${match.group(0)} ')
        .trim();
  }

  /// Callback for submission
  void _onSubmit() {
    final String rawText = _textController.text.replaceAll(' ', '');
    final bool isValid = RegExp(r'^\d{6}$').hasMatch(rawText);

    if (!isValid) {
      printDebug('Please enter a valid 6-digit PIN');
      return;
    }

    //TODO: Perform api request here
    printDebug('Validation is complete');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: CustomAppBar(
        title: Text('Join Game'),
        showBackArrow: false,
        leadingIcon: Icons.close,
        onPressed: context.pop,
        shouldCenterTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              // -- Enter Pin Text Field
              child: TextField(
                controller: _textController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  hintText: 'ENTER PIN',
                  hintStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                keyboardType: TextInputType.number,
                cursorColor: Colors.white,
                cursorWidth: 6,
                maxLength: 7,
                cursorRadius: Radius.circular(100),
                inputFormatters: [
                  // Allow only numbers [0 - 9]
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatInput(
                      newValue.text.replaceAll(' ', ''),
                    );
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // -- Join Now Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: Custom3DButton(
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(100),
                onPressed: _onSubmit,
                child: Text(
                  'JOIN NOW',
                  style: FontUtility.inter(
                    color: AppColors.buttonPrimary,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
