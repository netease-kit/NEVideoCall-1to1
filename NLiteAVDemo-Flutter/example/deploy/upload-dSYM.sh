# Copyright (c) 2022 NetEase, Inc. All rights reserved.
# Use of this source code is governed by a MIT license that can be
# found in the LICENSE file.

#!/bin/bash

ios/Pods/FirebaseCrashlytics/upload-symbols \
    -gsp ios/GoogleService-Info.plist \
    -p ios \
    build/ios/Release-iphoneos/Runner.app.dSYM \
    build/ios/Release-iphoneos/MeetingBroadcaster.appex.dSYM