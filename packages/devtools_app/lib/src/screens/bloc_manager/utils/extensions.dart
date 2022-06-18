import 'package:vm_service/vm_service.dart';

/// An extension on [Event].
extension EventExtension on Event {
  /// Whether or not this [Event] comes from the `Bloc Manager` package.
  bool get isBlocManagerEvent => extensionKind == 'bloc_manager_event';

  /// Whether or not this [Event] has data.
  bool get hasData => extensionData?.data != null;

  /// The payload provided by the event.
  ///
  /// This is a shortcut to [extensionData.data].
  Map<String, dynamic>? get payload => extensionData?.data;
}
