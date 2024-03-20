import 'device.dart';
import 'messages.dart';
import 'mqtt_json_adapter.dart';

const controllerTopic = 'light-controller';
const deviceTopic = 'light-bulb';

class DeviceProtocol extends JsonProtocol<Command, Status> {
  final Device device;
  final String controllerTopic;

  DeviceProtocol({required this.device, required this.controllerTopic});

  @override
  Command convertFromJsonIn(String topic, jsonIn) => Command.fromJson(jsonIn);

  @override
  convertToJsonOut(String topic, Status messageOut) => messageOut.toJson();

  @override
  processMessage(
      String topic, Command messageIn, PublishMessage<Status> publish) async {
    switch (messageIn.action) {
      case Action.turnOn:
        await device.turnOn();
        publish(controllerTopic, Status(device.power));
        break;
      case Action.turnOff:
        await device.turnOff();
        publish(controllerTopic, Status(device.power));
        break;
      case Action.reportStatus:
        publish(controllerTopic, Status(device.power));
        break;
    }
  }
}

mixin ControllerProtocol implements JsonProtocol<Status, Command> {
  @override
  Status convertFromJsonIn(String topic, jsonIn) => Status.fromJson(jsonIn);

  @override
  dynamic convertToJsonOut(String topic, Command messageOut) =>
      messageOut.toJson();
}
