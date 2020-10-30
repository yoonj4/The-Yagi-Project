part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class SetSettings extends SettingsEvent {
  final Settings settings;

  const SetSettings(this.settings);

  @override
  List<Object> get props => [settings];
}
