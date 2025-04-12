abstract class SubscriptionEvent {}

class CreateCheckoutSession extends SubscriptionEvent {}

class FetchSubscriptionDetails extends SubscriptionEvent {}

class CancelSubscription extends SubscriptionEvent {}