class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval;
  final String type;
  final List<String> features;
  final String priceId;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.interval,
    required this.type,
    required this.features,
    required this.priceId,
  });

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}/${interval == 'month' ? 'mo' : 'yr'}';
  }

  String get savings {
    if (interval == 'year') {
      // Calculate savings for yearly plans (typically 20% off monthly price)
      return '${getSavingsPercentage()}% savings';
    }
    return '';
  }

  int getSavingsPercentage() {
    if (interval == 'year') {
      return 20; // 20% savings for yearly plans
    }
    return 0;
  }

  static List<SubscriptionPlan> getAvailablePlans() {
    return [
      SubscriptionPlan(
        id: 'premium_monthly',
        name: 'Premium Monthly',
        description: 'Unlock all premium features with monthly billing',
        price: 9.99,
        interval: 'month',
        type: 'premium',
        priceId: 'price_premium_monthly',
        features: [
          'Unlimited quizzes',
          'Ad-free experience',
          'Custom study materials',
          'Create private lobbies',
          'Advanced analytics',
        ],
      ),
      SubscriptionPlan(
        id: 'premium_yearly',
        name: 'Premium Yearly',
        description: 'Unlock all premium features with yearly billing',
        price: 95.88, // $7.99/month billed annually
        interval: 'year',
        type: 'premium',
        priceId: 'price_premium_yearly',
        features: [
          'Unlimited quizzes',
          'Ad-free experience',
          'Custom study materials',
          'Create private lobbies',
          'Advanced analytics',
          'Priority support',
        ],
      ),
      SubscriptionPlan(
        id: 'student_monthly',
        name: 'Student Monthly',
        description: 'Special plan for students with monthly billing',
        price: 4.99,
        interval: 'month',
        type: 'student',
        priceId: 'price_student_monthly',
        features: [
          'Unlimited quizzes',
          'Ad-free experience',
          'Custom study materials',
          'Create private lobbies',
        ],
      ),
      SubscriptionPlan(
        id: 'student_yearly',
        name: 'Student Yearly',
        description: 'Special plan for students with yearly billing',
        price: 47.88, // $3.99/month billed annually
        interval: 'year',
        type: 'student',
        priceId: 'price_student_yearly',
        features: [
          'Unlimited quizzes',
          'Ad-free experience',
          'Custom study materials',
          'Create private lobbies',
          'Basic analytics',
        ],
      ),
    ];
  }
} 