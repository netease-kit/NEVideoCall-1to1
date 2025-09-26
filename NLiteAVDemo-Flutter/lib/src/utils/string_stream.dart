// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class StringStream {
  static String makeNull(String? str, String defaultValue) {
    String nonNullableString = str?.isEmpty == false ? str! : defaultValue;
    return nonNullableString;
  }

  static String makeNonNull(String str, String defaultValue) {
    String nonNullableString = str.isEmpty ? defaultValue : str;
    return nonNullableString;
  }
}
