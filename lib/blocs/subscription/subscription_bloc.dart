import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final ApiService _apiService = ApiService();

  SubscriptionBloc() : super(SubscriptionInitial()) {
    on<CreateCheckoutSession>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final response = await _apiService.createCheckoutSession();
        emit(CheckoutSessionCreated(
          sessionId: response['sessionId'],
          url: response['url'],
        ));
      } catch (e) {
        print('SubscriptionBloc Error (CreateCheckoutSession): $e'); // Debug statement
        emit(SubscriptionError(message: e.toString()));
      }
    });

    on<FetchSubscriptionDetails>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final subscription = await _apiService.getSubscriptionDetails();
        emit(SubscriptionDetailsLoaded(subscription: subscription));
      } catch (e) {
        print('SubscriptionBloc Error (FetchSubscriptionDetails): $e'); // Debug statement
        emit(SubscriptionError(message: e.toString()));
      }
    });

    on<CancelSubscription>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final response = await _apiService.cancelSubscription();
        emit(SubscriptionCancelled(subscription: response['subscription']));
      } catch (e) {
        print('SubscriptionBloc Error (CancelSubscription): $e'); // Debug statement
        emit(SubscriptionError(message: e.toString()));
      }
    });
  }
}