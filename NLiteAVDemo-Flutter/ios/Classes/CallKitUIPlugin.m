// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "CallKitUIPlugin.h"

#if __has_include(<netease_callkit_ui/netease_callkit_ui-Swift.h>)
#import <netease_callkit_ui/netease_callkit_ui-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "netease_callkit_ui-Swift.h"
#endif

@implementation CallKitUIPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftCallKitUIPlugin registerWithRegistrar:registrar];
}
@end
