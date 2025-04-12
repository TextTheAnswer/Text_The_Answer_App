abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class CheckoutSessionCreated extends SubscriptionState {
  final String sessionId;
  final String url;

  CheckoutSessionCreated({required this.sessionId, required this.url});
}

class SubscriptionDetailsLoaded extends SubscriptionState {
  final Map<String, dynamic> subscription;

  SubscriptionDetailsLoaded({required this.subscription});
}

class SubscriptionCancelled extends SubscriptionState {
  final Map<String, dynamic> subscription;

  SubscriptionCancelled({required this.subscription});
}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError({required this.message});
}