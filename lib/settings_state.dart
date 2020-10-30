part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  SettingsInitial({this.settings});

  final Settings settings;

  @override
  List<Object> get props => [settings];
}

class SettingsAlternate extends SettingsState {
  SettingsAlternate({this.settings});

  final Settings settings;

  @override
  List<Object> get props => [settings];
}
