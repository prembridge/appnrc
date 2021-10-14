import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/* 
class NetStatus extends StateNotifier<ConnectivityResult> {
  NetStatus() : super(null) {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {});
  }
}

final netStatus =
    StateNotifierProvider<NetStatus, ConnectivityResult>((ref) => NetStatus());
 */
final netProvider = StreamProvider<ConnectivityResult>((ref) async* {
  // Open the connection
  final net = Connectivity().onConnectivityChanged;

  // Close the connection when the stream is destroyed

  // Parse the value received and emit a Message instance

  await for (final value in net) {
    yield value;
  }
});
