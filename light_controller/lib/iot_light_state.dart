enum LightStatus {
  on,
  off,
  unknown,
}

enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
}

/// Combines MQTT connection status with power status of IoT light.
class AppState {
  final ConnectionStatus connection;
  final LightStatus light;

  AppState({
    required this.connection,
    required this.light,
  });

  factory AppState.initial() {
    return AppState(
      connection: ConnectionStatus.disconnected,
      light: LightStatus.unknown,
    );
  }

  copyWith({ConnectionStatus? connection, LightStatus? light}) {
    return AppState(
      connection: connection ?? this.connection,
      light: light ?? this.light,
    );
  }
}
