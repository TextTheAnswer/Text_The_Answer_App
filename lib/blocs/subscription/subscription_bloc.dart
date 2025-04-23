import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import '../../models/subscription.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final ApiService _apiService;

  SubscriptionBloc({required ApiService apiService}) 
      : _apiService = apiService,
        super(SubscriptionInitial()) {
    on<CreateCheckoutSession>(_onCreateCheckoutSession);
    on<CancelSubscription>(_onCancelSubscription);
    on<FetchSubscriptionDetails>(_onFetchSubscriptionDetails);
  }

  Future<void> _onCreateCheckoutSession(
    CreateCheckoutSession event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    try {
      final response = await _apiService.createCheckoutSession();
      
      if (response.containsKey('url')) {
        emit(CheckoutSessionCreated(response['url']));
      } else {
        emit(SubscriptionError('Failed to create checkout session'));
      }
    } catch (e) {
      emit(SubscriptionError('An error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    try {
      final response = await _apiService.cancelSubscription();
      
      if (response.containsKey('success') && response['success'] == true) {
        final subscriptionData = await _apiService.getSubscriptionDetails();
        final subscription = Subscription.fromJson(subscriptionData);
        emit(SubscriptionCancelled(subscription));
      } else {
        emit(SubscriptionError(response['message'] ?? 'Failed to cancel subscription'));
      }
    } catch (e) {
      emit(SubscriptionError('An error occurred: ${e.toString()}'));
    }
  }
  
  Future<void> _onFetchSubscriptionDetails(
    FetchSubscriptionDetails event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    
    try {
      final response = await _apiService.getSubscriptionDetails();
      try {
        final subscription = Subscription.fromJson(response);
        emit(SubscriptionDetailsLoaded(subscription));
      } catch (e) {
        emit(SubscriptionError('Failed to parse subscription data: ${e.toString()}'));
      }
    } catch (e) {
      emit(SubscriptionError('An error occurred: ${e.toString()}'));
    }
  }
}
