import 'device.dart';

enum Action {
  turnOn,
  turnOff,
  reportStatus,
}

/// Controller sends commands to device
class Command {
  final Action action;
  const Command(this.action);
  Map<String, dynamic> toJson() => {'action': action.name};
  Command.fromJson(Map<String, dynamic> json)
      : action = Action.values.byName(json['action']);
}

/// Device responds with status update
class DeviceStatus {
  final Power power;
  const DeviceStatus(this.power);
  Map<String, dynamic> toJson() => {'power': power.name};
  DeviceStatus.fromJson(Map<String, dynamic> json)
      : power = Power.values.byName(json['power']);
}
