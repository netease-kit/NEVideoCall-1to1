// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);

  @override
  String toString() => '($item1, $item2)';
}
