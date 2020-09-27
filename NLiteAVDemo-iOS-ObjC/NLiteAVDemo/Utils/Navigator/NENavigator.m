//
//  NENavigator.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NENavigator.h"
#import "NTELoginVC.h"
#import "NEAccount.h"

@interface NENavigator ()

@end

@implementation NENavigator

+ (NENavigator *)shared
{
    static NENavigator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NENavigator alloc] init];
    });
    return instance;
}

- (void)loginWithOptions:(NELoginOptions * _Nullable)options
{
    if ([NEAccount shared].hasLogin) {
        return;
    }
    if (_loginNavigationController && _navigationController.presentingViewController == _loginNavigationController) {
        return;
    }
    NTELoginVC *loginVC = [[NTELoginVC alloc] initWithOptions:options];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    loginNav.navigationBar.barTintColor = [UIColor whiteColor];
    loginNav.navigationBar.translucent = NO;
    loginNav.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    [_navigationController presentViewController:loginNav animated:YES completion:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.loginNavigationController = loginNav;
    }];
}

- (void)closeLoginWithCompletion:(_Nullable NELoginBlock)completion
{
    if (_loginNavigationController.presentingViewController) {
        [_loginNavigationController dismissViewControllerAnimated:YES completion:completion];
    } else {
        if (_loginNavigationController.navigationController) {
            [_loginNavigationController.navigationController popViewControllerAnimated:NO];
        } else {
            [_loginNavigationController popViewControllerAnimated:NO];
        }
        if (completion) {
            completion();
        }
    }
}

@end
