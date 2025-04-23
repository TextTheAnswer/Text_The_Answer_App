import 'package:equatable/equatable.dart';

abstract class DemoUserEvent extends Equatable {
  const DemoUserEvent();
  
  @override
  List<Object> get props => [];
}

class CreateDemoUserEvent extends DemoUserEvent {
  final String tier;
  
  const CreateDemoUserEvent({required this.tier});
  
  @override
  List<Object> get props => [tier];
}
