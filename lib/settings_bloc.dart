import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_yagi_project/models/settings/settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(SettingsState initialState) : super(initialState);

  bool currentStateIsInitialized = true;

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event.props.first is Settings) {
      if (!currentStateIsInitialized) {
        currentStateIsInitialized = true;
        yield SettingsInitial(settings: event.props.first);
      } else {
        currentStateIsInitialized = false;
        yield SettingsAlternate(settings: event.props.first);
      }
    }
  }
}
