import 'device.dart';

enum Action {
  turnOn,
  turnOff,
  reportStatus,
}

class Command {
  final Action action;
  const Command(this.action);
  Map<String, dynamic> toJson() => {'action': action.name};
  Command.fromJson(Map<String, dynamic> json)
      : action = Action.values.byName(json['action']);
}

class DeviceStatus {
  final Power status;
  const DeviceStatus(this.status);
  Map<String, dynamic> toJson() => {'status': status.name};
  DeviceStatus.fromJson(Map<String, dynamic> json)
      : status = Power.values.byName(json['status']);
}
