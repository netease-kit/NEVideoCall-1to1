// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import '../pages/home_page.dart';
import '../constants/router_name.dart';

class RoutesRegister {
  static Map<String, WidgetBuilder> routes(RouteSettings settings) {
    return {
      RouterName.homePage: (context) => HomePageRoute(),
      RouterName.loginPage: (context) => const LoginRoute(),
    };
  }
}
