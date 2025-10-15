// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

enum AuthState {
  init,
  authed,
  tokenIllegal,
  kicked,
}

class AuthStateManager {
  static AuthStateManager? _instance;
  AuthState _state = AuthState.init;
  String? _errorTip;

  factory AuthStateManager() => _instance ??= AuthStateManager._internal();

  AuthStateManager._internal();

  AuthState get state => _state;
  String? get errorTip => _errorTip;

  void updateState({required AuthState state, String? errorTip}) {
    _state = state;
    _errorTip = errorTip;
  }
}
