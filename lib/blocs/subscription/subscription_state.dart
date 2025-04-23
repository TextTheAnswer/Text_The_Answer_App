import 'package:equatable/equatable.dart';
import 'package:text_the_answer/models/user_profile_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class CheckoutSessionCreated extends SubscriptionState {
  final String checkoutUrl;

  const CheckoutSessionCreated(this.checkoutUrl);

  @override
  List<Object?> get props => [checkoutUrl];
}

class SubscriptionDetailsLoaded extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionDetailsLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCancelled extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionCancelled(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}