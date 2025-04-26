import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../config/colors.dart';
import '../../models/subscription_plan.dart';
import '../../router/routes.dart';

class EducationVerificationScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  final VoidCallback toggleTheme;

  const EducationVerificationScreen({
    Key? key,
    required this.plan,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  State<EducationVerificationScreen> createState() => _EducationVerificationScreenState();
}

class _EducationVerificationScreenState extends State<EducationVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String _selectedYear = 'Freshman';
  bool _isSubmitting = false;
  
  // Status can be: 'initial', 'pending', 'verified', 'rejected'
  String _verificationStatus = 'initial';
  String? _errorMessage;

  final List<String> _yearOptions = [
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate Student',
    'PhD Student',
    'Faculty',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isEduEmail(String email) {
    return email.endsWith('.edu');
  }

  void _submitVerification() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
        _verificationStatus = 'pending';
        _errorMessage = null;
      });

      // Mock API call - in a real app, this would call the backend
      // Simulate an API delay
      Future.delayed(const Duration(seconds: 2), () {
        if (_isEduEmail(_emailController.text)) {
          setState(() {
            _verificationStatus = 'verified';
            _isSubmitting = false;
          });
        } else {
          setState(() {
            _verificationStatus = 'rejected';
            _errorMessage = 'Please use a valid .edu email address.';
            _isSubmitting = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Verification'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.plan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.plan.formattedPrice,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'Student Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'To receive the student discount, please provide your academic email and current year of study.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (_verificationStatus == 'initial' || _verificationStatus == 'pending' || _verificationStatus == 'rejected')
                _buildVerificationForm(),
              
              if (_verificationStatus == 'verified')
                _buildSuccessMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Academic Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Academic Email',
              hintText: 'your.name@university.edu',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email),
              errorText: _errorMessage,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your academic email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Year of Study
          DropdownButtonFormField<String>(
            value: _selectedYear,
            decoration: InputDecoration(
              labelText: 'Year of Study',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.school),
            ),
            items: _yearOptions.map((String year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedYear = newValue;
                });
              }
            },
          ),
          
          const SizedBox(height: 30),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          if (_verificationStatus == 'pending')
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verification in progress. This usually takes a few moments.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Verification Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your student status has been verified. You now have access to the ${widget.plan.name}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 30),
        
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.home,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Using Premium Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 