//
//  NEService.m
//  NEDemo
//
//  Created by Think on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEService.h"
#import "NSMacro.h"

@implementation NEService

+ (instancetype)shared
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)runTask:(id<NEServiceTask>)task completion:(NERequestHandler)completion
{
    NSURLRequest *request = [task taskRequest];
    NSURLSessionTask *sessionTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        
                                        id jsonData = nil;
                                        NSError *error = nil;
                                        
                                        if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                                            NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                            if (status == 200 && data) {
                                                jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:nil];
                                                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                                                    NSDictionary *dict = jsonData;
                                                    if ([dict objectForKey:@"code"]) {
                                                        long code = [[dict objectForKey:@"code"] longValue];
                                                        if (code != 200) {
                                                            error = [NSError errorWithDomain:@"ntes domain"
                                                                                        code:code
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
                                            error = [NSError errorWithDomain:@"ntes domain"
                                                                        code:-1
                                                                    userInfo:@{@"description" : @"connection error"}];
                                        }
                                        ntes_main_sync_safe(^{
                                            if (completion) {
                                                completion(jsonData,error);
                                            }
                                        });
                                    }];
    
    [sessionTask resume];
}

@end
