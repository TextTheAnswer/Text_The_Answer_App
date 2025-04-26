import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';
import '../../blocs/subscription/subscription_event.dart';
import '../../blocs/subscription/subscription_state.dart';
import '../../models/subscription_plan.dart';
import '../../widgets/subscription_plan_card.dart';
import '../../config/colors.dart';
import 'checkout_screen.dart';
import 'education_verification_screen.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SubscriptionPlansScreen({
    required this.toggleTheme,
    Key? key,
  }) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SubscriptionPlan> _plans = SubscriptionPlan.getAvailablePlans();
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SubscriptionPlan> _getPlansByType(String type) {
    return _plans.where((plan) => plan.type == type).toList();
  }

  void _selectPlan(String planId) {
    setState(() {
      _selectedPlanId = planId;
    });
  }

  void _subscribeToPlan() {
    if (_selectedPlanId != null) {
      final selectedPlan = _plans.firstWhere((plan) => plan.id == _selectedPlanId);
      
      // Navigate to different screens based on plan type
      if (selectedPlan.type == 'premium') {
        // For premium plans, go to checkout
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutScreen(
              plan: selectedPlan,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
      } else if (selectedPlan.type == 'student') {
        // For student plans, go to education verification
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EducationVerificationScreen(
              plan: selectedPlan,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subscription plan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Plan'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          children: [
            // Header and benefits section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Unlock Premium Features',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBenefitItem(Icons.group, 'Private lobbies'),
                      _buildBenefitItem(Icons.school, 'Study materials'),
                      _buildBenefitItem(Icons.analytics, 'Statistics'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tabs for Premium and Student
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white,
                      tabs: const [
                        Tab(text: 'PREMIUM'),
                        Tab(text: 'STUDENT'),
                      ],
                      onTap: (index) {
                        // Clear selection when switching tabs
                        setState(() {
                          _selectedPlanId = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Subscription plans
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Premium plans
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: _getPlansByType('premium').map((plan) => 
                      SubscriptionPlanCard(
                        plan: plan,
                        isSelected: _selectedPlanId == plan.id,
                        onTap: () => _selectPlan(plan.id),
                      )
                    ).toList(),
                  ),
                  
                  // Student plans
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    children: _getPlansByType('student').map((plan) => 
                      SubscriptionPlanCard(
                        plan: plan,
                        isSelected: _selectedPlanId == plan.id,
                        onTap: () => _selectPlan(plan.id),
                      )
                    ).toList(),
                  ),
                ],
              ),
            ),
            
            // Subscribe button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Plan comparison link
                  if (_selectedPlanId != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextButton(
                        onPressed: _showPlanComparison,
                        child: Text(
                          'Compare all plans',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  
                  // Subscribe button
                  ElevatedButton(
                    onPressed: _subscribeToPlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _getButtonText(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getButtonText() {
    if (_selectedPlanId == null) {
      return 'SELECT A PLAN';
    }
    
    final selectedPlan = _plans.firstWhere((plan) => plan.id == _selectedPlanId);
    if (selectedPlan.type == 'premium') {
      return 'PROCEED TO CHECKOUT';
    } else if (selectedPlan.type == 'student') {
      return 'VERIFY STUDENT STATUS';
    }
    
    return 'SUBSCRIBE NOW';
  }

  void _showPlanComparison() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: _buildPlanComparisonTable(),
        ),
      ),
    );
  }
  
  Widget _buildPlanComparisonTable() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Comparison',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                ),
                children: [
                  _buildTableCell('Features', isHeader: true),
                  _buildTableCell('Premium Monthly', isHeader: true),
                  _buildTableCell('Premium Yearly', isHeader: true),
                  _buildTableCell('Student Monthly', isHeader: true),
                  _buildTableCell('Student Yearly', isHeader: true),
                ],
              ),
              // Price row
              TableRow(
                children: [
                  _buildTableCell('Price'),
                  _buildTableCell('\$9.99/mo'),
                  _buildTableCell('\$7.99/mo\n(billed annually)'),
                  _buildTableCell('\$4.99/mo'),
                  _buildTableCell('\$3.99/mo\n(billed annually)'),
                ],
              ),
              // Features rows
              ...['Unlimited quizzes', 'Ad-free experience', 'Custom study materials', 
                'Create private lobbies', 'Analytics', 'Priority support'].map((feature) {
                return TableRow(
                  children: [
                    _buildTableCell(feature),
                    _buildTableCell(_hasFeature(feature, 'premium_monthly') ? '✓' : '✗'),
                    _buildTableCell(_hasFeature(feature, 'premium_yearly') ? '✓' : '✗'),
                    _buildTableCell(_hasFeature(feature, 'student_monthly') ? '✓' : '✗'),
                    _buildTableCell(_hasFeature(feature, 'student_yearly') ? '✓' : '✗'),
                  ],
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 30),
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
  
  bool _hasFeature(String feature, String planId) {
    // Special handling for analytics feature that differs between plans
    if (feature == 'Analytics') {
      if (planId.contains('premium')) {
        return true; // Both premium plans have analytics
      } else if (planId == 'student_yearly') {
        return true; // Only student yearly has analytics
      }
      return false;
    }
    
    // Special handling for priority support
    if (feature == 'Priority support') {
      return planId == 'premium_yearly'; // Only premium yearly has priority support
    }
    
    // All plans have these features
    return ['Unlimited quizzes', 'Ad-free experience', 'Custom study materials', 'Create private lobbies'].contains(feature);
  }
  
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.center,
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
} 