// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NETask.h"
#import <objc/runtime.h>
#import "NEAccount.h"
#import "NEService.h"
#import "NSDictionary+NTESJson.h"

@interface NETask ()
@property(strong, nonatomic) NSString *URLString;
@end

@implementation NETask
+ (instancetype)task {
  return [self taskWithSubURL:nil];
}
+ (instancetype)taskWithSubURL:(NSString *__nullable)subURL {
  NSString *URLString = [baseURL stringByAppendingString:subURL];
  return [self taskWithURLString:URLString];
};

+ (instancetype)taskWithURLString:(NSString *)urlString {
  NETask *task = [[self alloc] init];
  task.URLString = urlString;
  return task;
};

- (NSString *)getURL {
  return self.URLString;
}

- (NSURLRequest *)taskRequest {
  //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL
  //    URLWithString:self.URLString]
  //                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
  //                                                            timeoutInterval:30];
  NSMutableURLRequest *request =
      [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.URLString]];
  [request setHTTPMethod:@"POST"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
  [request setValue:[NEAccount shared].accessToken forHTTPHeaderField:@"accessToken"];
  [request setValue:kAppKey forHTTPHeaderField:@"appkey"];

  NSDictionary *parameterDic = [self getProperties];
  if (parameterDic.count > 0) {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameterDic
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
      return nil;
    }
    [request setHTTPBody:data];
  }
  return request;
}

- (void)postWithCompletion:(NERequestHandler)completion {
  [[NEService shared] runTask:self completion:completion];
}

// 返回当前类的所有属性
- (NSDictionary *)getProperties {
  NSMutableDictionary *dic = [NSMutableDictionary dictionary];
  // 获取当前类的所有属性
  unsigned int count;  // 记录属性个数
  objc_property_t *properties = class_copyPropertyList([self class], &count);
  for (int i = 0; i < count; i++) {
    objc_property_t property = properties[i];
    const char *cName = property_getName(property);
    NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
    if ([name containsString:@"req_"]) {
      id value = [self valueForKey:name];
      NSRange range = [name rangeOfString:@"req_"];
      NSString *key = [name substringFromIndex:range.location + range.length];
      if (value == nil) {
        value = [NSNull null];
        [dic setObject:value forKey:key];
      } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]] ||
                 [value isKindOfClass:[NSNull class]]) {
        [dic setObject:value forKey:key];
      } else {
        return nil;
      }
    }
  }
  return dic.copy;
}

@end
