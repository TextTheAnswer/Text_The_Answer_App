import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class CreateCheckoutSession extends SubscriptionEvent {
  const CreateCheckoutSession();
}

class CancelSubscription extends SubscriptionEvent {
  const CancelSubscription();
}

class FetchSubscriptionDetails extends SubscriptionEvent {
  const FetchSubscriptionDetails();
}
