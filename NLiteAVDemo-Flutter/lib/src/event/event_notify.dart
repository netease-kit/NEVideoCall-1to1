typedef NEEventCallback = void Function(dynamic arg);

class NEEventNotify {
  NEEventNotify._newObject();

  static final NEEventNotify _singleton = NEEventNotify._newObject();

  factory NEEventNotify() => _singleton;

  final _messageQueue = <Object, List<NEEventCallback>>{};

  void register(String eventName, NEEventCallback? callback) {
    if (eventName != null && callback != null) {
      if (_messageQueue[eventName] == null) {
        _messageQueue[eventName] = <NEEventCallback>[];
      }
      _messageQueue[eventName]?.add(callback);
    }
  }

  void unregister(String eventName, NEEventCallback? callback) {
    if (eventName != null && callback != null) {
      var list = _messageQueue[eventName];
      if (list != null) {
        list.remove(callback);
      }
    }
  }

  void notify(String eventName, [Map<String, dynamic>? arg]) {
    var list = _messageQueue[eventName];
    if (list != null && list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        list[i](arg);
      }
    }
  }
}

const loginSuccessEvent = 'LOGIN_SUCCESS_EVENT';
const logoutSuccessEvent = 'LOGOUT_SUCCESS_EVENT';
const imSDKInitSuccessEvent = 'IM_SDK_INIT_SUCCESS_EVENT';
