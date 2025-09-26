// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (NTESJson)

- (NSString *)jsonBody;

- (NSString *)jsonString:(NSString *)key;

- (NSDictionary *)jsonDict:(NSString *)key;
- (NSArray *)jsonArray:(NSString *)key;
- (NSArray *)jsonStringArray:(NSString *)key;

- (BOOL)jsonBool:(NSString *)key;
- (NSInteger)jsonInteger:(NSString *)key;
- (long long)jsonLongLong:(NSString *)key;
- (unsigned long long)jsonUnsignedLongLong:(NSString *)key;

- (double)jsonDouble:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
