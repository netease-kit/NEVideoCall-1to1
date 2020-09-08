//
//  NEMenuViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEMenuViewController.h"
#import "NENavCustomView.h"
#import "NEMenuCell.h"
#import "NERtcContactsViewController.h"
#import "NERtcVideoCall.h"

#import "NEUser.h"
#import "NECallViewController.h"

#import "NENavigator.h"
#import "NEAccount.h"

@interface NEMenuViewController ()<UITableViewDelegate,UITableViewDataSource,NERtcVideoCallDelegate>
@property(strong,nonatomic)UITableView *tableView;
@property(strong,nonatomic)UIImageView *bgImageView;
@end

static NSString *cellID = @"menuCellID";
@implementation NEMenuViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addObserver];
    [self autoLogin];
}
#pragma mark - private
- (void)setupUI {
    [self.view addSubview:self.bgImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    NENavCustomView *customView = [[NENavCustomView alloc] init];
    [self.view addSubview:customView];
    [customView.userButton addTarget:self action:@selector(userButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(statusHeight + 80);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_bottom);
        make.right.mas_equalTo(-20);
        make.left.mas_equalTo(20);
        make.bottom.mas_equalTo(0);
    }];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.textColor = [UIColor whiteColor];
    versionLabel.font = [UIFont systemFontOfSize:14];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"NIMSDK_LITE:v7.8.4 \n NERtcSDK:v3.5.1 \n Demo:v%@ build:%@",appVersion,appBuild];
    versionLabel.numberOfLines = 0;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.bottom.mas_equalTo(-40);
        make.height.mas_equalTo(60);
    }];
}

- (void)addObserver {
    [[NERtcVideoCall shared] addDelegate:self];
    [NEAccount addObserverForObject:self actionBlock:^(NEAccountAction action) {
        if (action == NEAccountActionLogin) {
            //IM登录
            NEUser *user = [NEAccount shared].userModel;
            [[NERtcVideoCall shared] login:user success:^{
                // 首次登录成功之后上传deviceToken
                NSData *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:deviceTokenKey];
                [[NERtcVideoCall shared] updateApnsToken:deviceToken];
            } failed:^(NSError * _Nonnull error) {
                [self.view makeToast:[NSString stringWithFormat:@"IM登录失败%@",error.localizedDescription]];
            }];
        }else {
            //IM退出
            [[NERtcVideoCall shared] logout];
        }
    }];
}

- (void)removeObserver {
    [[NERtcVideoCall shared] removeDelegate:self];
    [NEAccount removeObserverForObject:self];
}
- (void)autoLogin {
    if ([[NEAccount shared].accessToken length] > 0) {
        [NEAccount loginByTokenWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSString *msg = data[@"msg"] ?: @"请求错误";
                [self.view makeToast:msg];
            }else {
                [[NERtcVideoCall shared] login:[NEAccount shared].userModel success:^{
                    [self.view makeToast:@"IM登录成功"];
                } failed:^(NSError * _Nonnull error) {
                    [self.view makeToast:error.localizedDescription];
                }];
            }
        }];
    }
}
- (void)userButtonClick:(UIButton *)button {
    if ([NEAccount shared].hasLogin) {
        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"确认退出登录%@",[NEAccount shared].userModel.mobile] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NEAccount logoutWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
                if (error) {
                    [self.view makeToast:error.localizedDescription];
                }else {
                    [[NERtcVideoCall shared] logout];
                }
            }];

        }];
        [alerVC addAction:cancelAction];
        [alerVC addAction:okAction];
        [self presentViewController:alerVC animated:YES completion:nil];
    }
}
#pragma mark - NERtcVideoCallDelegate
- (void)onInvitedByUser:(NEUser *)user {
    //接听
    NECallViewController *callVC = [[NECallViewController alloc] init];
    callVC.localUser = [NEAccount shared].userModel;
    callVC.remoteUser = user;
    callVC.status = NECallStatusCalled;
    callVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:callVC animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NEMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.iconView.image = [UIImage imageNamed:@"menu_single_icon"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (![NEAccount shared].hasLogin) {
            [[NENavigator shared] loginWithOptions:nil];
        }else {
            NERtcContactsViewController *contact = [[NERtcContactsViewController alloc] init];
            [self.navigationController pushViewController:contact animated:YES];
        }
    }
}

#pragma mark - property
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 104;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[NEMenuCell class] forCellReuseIdentifier:cellID];
    }
    return _tableView;
}
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bg"]];
    }
    return _bgImageView;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
