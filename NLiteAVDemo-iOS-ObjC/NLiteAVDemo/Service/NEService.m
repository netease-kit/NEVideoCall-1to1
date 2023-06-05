// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEService.h"
#import "NSMacro.h"

@interface NEService () <NSURLSessionTaskDelegate>

@end

@implementation NEService

+ (instancetype)shared {
  static id instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[[self class] alloc] init];
  });
  return instance;
}

- (void)URLSession:(NSURLSession *)session
    didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
      completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition,
                                  NSURLCredential *_Nullable))completionHandler {
  NSURLSessionAuthChallengeDisposition disposition =
      NSURLSessionAuthChallengePerformDefaultHandling;
  __block NSURLCredential *credential = nil;

  if ([challenge.protectionSpace.authenticationMethod
          isEqualToString:NSURLAuthenticationMethodServerTrust]) {
    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    if (credential) {
      disposition = NSURLSessionAuthChallengeUseCredential;
    } else {
      disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
  } else {
    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
  }

  if (completionHandler) {
    completionHandler(disposition, credential);
  }
}

- (void)runTask:(id<NEServiceTask>)task completion:(NERequestHandler)completion {
  NSURLRequest *request = [task taskRequest];

  NSURLSession *session =
      [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                    delegate:self
                               delegateQueue:[[NSOperationQueue alloc] init]];

  NSURLSessionTask *sessionTask = [session
      dataTaskWithRequest:request
        completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                            NSError *_Nullable connectionError) {
          NSLog(@"run task error : %@", connectionError);

          id jsonData = nil;
          NSError *error = nil;

          if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger status = [(NSHTTPURLResponse *)response statusCode];
            if (status == 200 && data) {
              jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              if ([jsonData isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = jsonData;
                if ([dict objectForKey:@"code"]) {
                  long code = [[dict objectForKey:@"code"] longValue];
                  if (code != 200) {
                    error = [NSError errorWithDomain:@"ntes domain" code:code userInfo:nil];
                  }
                }
              }
            } else {
              error = [NSError errorWithDomain:@"ntes domain" code:status userInfo:nil];
            }
          } else {
            NSNumber *code = [connectionError.userInfo objectForKey:@"_kCFStreamErrorCodeKey"];
            if (code.integerValue == 50) {
              error = [NSError
                  errorWithDomain:@"ntes domain"
                             code:-1
                         userInfo:@{NSLocalizedDescriptionKey : @"网络连接异常，请稍后再试"}];
            } else {
              error = [NSError errorWithDomain:@"ntes domain"
                                          code:-1
                                      userInfo:@{@"description" : @"connection error"}];
            }
          }
          ntes_main_sync_safe(^{
            if (completion) {
              completion(jsonData, error);
            }
          });
        }];

  /*
  NSURLSessionTask *sessionTask =
  [[NSURLSession sharedSession] dataTaskWithRequest:request
                                  completionHandler:^(NSData * _Nullable data, NSURLResponse *
  _Nullable response, NSError * _Nullable connectionError) {

                                      NSLog(@"run task error : %@", connectionError);

                                      id jsonData = nil;
                                      NSError *error = nil;

                                      if (connectionError == nil && [response
  isKindOfClass:[NSHTTPURLResponse class]]) { NSInteger status = [(NSHTTPURLResponse *)response
  statusCode]; if (status == 200 && data) { jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                         options:0
                                                                                           error:nil];
                                              if ([jsonData isKindOfClass:[NSDictionary class]]) {
                                                  NSDictionary *dict = jsonData;
                                                  if ([dict objectForKey:@"code"]) {
                                                      long code = [[dict objectForKey:@"code"]
  longValue]; if (code != 200) { error = [NSError errorWithDomain:@"ntes domain" code:code
                                                                                  userInfo:nil];
                                                      }
                                                  }
                                              }
                                          }
                                          else{
                                              error = [NSError errorWithDomain:@"ntes domain"
                                                                          code:status
                                                                      userInfo:nil];
                                          }
                                      }
                                      else {
                                          NSNumber *code = [connectionError.userInfo
  objectForKey:@"_kCFStreamErrorCodeKey"]; if (code.integerValue == 50) { error = [NSError
  errorWithDomain:@"ntes domain" code:-1 userInfo:@{NSLocalizedDescriptionKey :
  @"网络连接异常，请稍后再试"}]; }else { error = [NSError errorWithDomain:@"ntes domain" code:-1
                                                                      userInfo:@{@"description" :
  @"connection error"}];
                                          }

                                      }
                                      ntes_main_sync_safe(^{
                                          if (completion) {
                                              completion(jsonData,error);
                                          }
                                      });
                                  }];
  sessionTask.delegate = self;
  */
  [sessionTask resume];
}

@end
