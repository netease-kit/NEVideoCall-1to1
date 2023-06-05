// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "LocalServerManager.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"
@interface LocalServerManager ()

@property(nonatomic, strong) GCDWebServer *webServer;

@end

@implementation LocalServerManager

+ (id)shareInstance {
  static LocalServerManager *shareInstance = nil;
  static dispatch_once_t once_token;
  dispatch_once(&once_token, ^{
    if (!shareInstance) {
      shareInstance = [[self alloc] init];
    }
  });
  return shareInstance;
}

- (void)startServer {
  self.webServer = [[GCDWebServer alloc] init];
  [self.webServer addGETHandlerForBasePath:@"/"
                             directoryPath:NSHomeDirectory()
                             indexFilename:nil
                                  cacheAge:3600
                        allowRangeRequests:true];
  [self.webServer addHandlerForMethod:@"GET"
                                 path:@"/token"
                         requestClass:[GCDWebServerRequest class]
                         processBlock:^GCDWebServerResponse *_Nullable(
                             __kindof GCDWebServerRequest *_Nonnull request) {
                           NSMutableString *deviceTokenString = [NSMutableString string];
                           NSData *deviceToken = (NSData *)[[NSUserDefaults standardUserDefaults]
                               objectForKey:deviceTokenKey];
                           if (deviceToken != nil) {
                             const char *bytes = deviceToken.bytes;
                             NSInteger iCount = deviceToken.length;
                             for (int i = 0; i < iCount; i++) {
                               [deviceTokenString appendFormat:@"%02x", bytes[i] & 0x000000FF];
                             }
                           } else {
                             [deviceTokenString appendString:@"token is empty"];
                           }
                           return [GCDWebServerDataResponse responseWithText:deviceTokenString];
                         }];
  [self.webServer startWithPort:8080 bonjourName:@"GCD Web Server"];
}

@end
