import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class CreateCheckoutSession extends SubscriptionEvent {
  final String priceId;
  
  const CreateCheckoutSession({required this.priceId});
  
  @override
  List<Object?> get props => [priceId];
}

class CancelSubscription extends SubscriptionEvent {
  const CancelSubscription();
}

class FetchSubscriptionDetails extends SubscriptionEvent {
  const FetchSubscriptionDetails();
}
