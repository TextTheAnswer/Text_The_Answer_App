class Subscription {
  final String? id;
  final String? customerId;
  final String? planId;
  final String status;
  final int? currentPeriodStart;
  final int? currentPeriodEnd;
  final String? interval;
  final bool cancelAtPeriodEnd;

  Subscription({
    this.id,
    this.customerId,
    this.planId,
    required this.status,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.interval,
    this.cancelAtPeriodEnd = false,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      customerId: json['customerId'],
      planId: json['planId'],
      status: json['status'] ?? 'inactive',
      currentPeriodStart: json['currentPeriodStart'],
      currentPeriodEnd: json['currentPeriodEnd'],
      interval: json['interval'],
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'planId': planId,
      'status': status,
      'currentPeriodStart': currentPeriodStart,
      'currentPeriodEnd': currentPeriodEnd,
      'interval': interval,
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
    };
  }
} 