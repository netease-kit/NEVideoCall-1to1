// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NSDictionary+NTESJson.h"

@implementation NSDictionary (NTESJson)

- (NSString *)jsonBody {
  NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
  if (data) {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  }
  return nil;
}

- (NSString *)jsonString:(NSString *)key {
  id object = [self objectForKey:key];
  if ([object isKindOfClass:[NSString class]]) {
    return object;
  } else if ([object isKindOfClass:[NSNumber class]]) {
    return [object stringValue];
  }
  return nil;
}

- (NSDictionary *)jsonDict:(NSString *)key {
  id object = [self objectForKey:key];
  return [object isKindOfClass:[NSDictionary class]] ? object : nil;
}

- (NSArray *)jsonArray:(NSString *)key {
  id object = [self objectForKey:key];
  return [object isKindOfClass:[NSArray class]] ? object : nil;
}

- (NSArray *)jsonStringArray:(NSString *)key {
  NSArray *array = [self jsonArray:key];
  BOOL invalid = NO;
  for (id item in array) {
    if (![item isKindOfClass:[NSString class]]) {
      invalid = YES;
    }
  }
  return invalid ? nil : array;
}

- (BOOL)jsonBool:(NSString *)key {
  id object = [self objectForKey:key];
  if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
    return [object boolValue];
  }
  return NO;
}

- (NSInteger)jsonInteger:(NSString *)key {
  id object = [self objectForKey:key];
  if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
    return [object integerValue];
  }
  return 0;
}

- (long long)jsonLongLong:(NSString *)key {
  id object = [self objectForKey:key];
  if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
    return [object longLongValue];
  }
  return 0;
}

- (unsigned long long)jsonUnsignedLongLong:(NSString *)key {
  id object = [self objectForKey:key];
  if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
    return [object unsignedLongLongValue];
  }
  return 0;
}

- (double)jsonDouble:(NSString *)key {
  id object = [self objectForKey:key];
  if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
    return [object doubleValue];
  }
  return 0;
}

@end
