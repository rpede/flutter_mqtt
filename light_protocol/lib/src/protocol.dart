import 'device.dart';
import 'messages.dart';
import 'mqtt_json_adapter.dart';

const controllerTopic = 'light-controller';
const deviceTopic = 'light-bulb';

abstract class BaseJsonProtocol<Tin, Tout> {
  initialize(PublishMessage<Tout> publish) {}
  processMessage(String topic, Tin messageIn, PublishMessage<Tout> publish);
  Tin convertFromJsonIn(String topic, dynamic jsonIn);
  Map<String, dynamic> convertToJsonOut(String topic, Tout messageOut);
}

class DeviceProtocol extends BaseJsonProtocol<Command, DeviceStatus> {
  final Device device;
  final String controllerTopic;

  DeviceProtocol({required this.device, required this.controllerTopic});

  @override
  Command convertFromJsonIn(String topic, jsonIn) => Command.fromJson(jsonIn);

  @override
  Map<String, dynamic> convertToJsonOut(String topic, DeviceStatus messageOut) =>
      messageOut.toJson();

  @override
  processMessage(
      String topic, Command messageIn, PublishMessage<DeviceStatus> publish) async {
    switch (messageIn.action) {
      case Action.turnOn:
        await device.turnOn();
        break;
      case Action.turnOff:
        await device.turnOff();
        break;
      case Action.reportStatus:
        break;
    }
    publish(controllerTopic, DeviceStatus(device.power));
  }
}

mixin ControllerProtocol implements BaseJsonProtocol<DeviceStatus, Command> {
  @override
  DeviceStatus convertFromJsonIn(String topic, jsonIn) => DeviceStatus.fromJson(jsonIn);

  @override
  Map<String, dynamic> convertToJsonOut(String topic, Command messageOut) =>
      messageOut.toJson();
}
