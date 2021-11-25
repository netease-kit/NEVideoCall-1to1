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
#import "NEUser.h"
#import "NECallViewController.h"
#import "NSArray+NTES.h"
#import "NENavigator.h"
#import "NEAccount.h"
#import "NECallStatusRecordModel.h"
#import "NetManager.h"

@interface NEMenuViewController ()<UITableViewDelegate,UITableViewDataSource,NERtcCallKitDelegate, NIMChatManagerDelegate>
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
    [NetManager shareInstance];
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
    NSString *rtcVersion = [NSBundle bundleForClass:[NERtcEngine class]].infoDictionary[@"CFBundleShortVersionString"];
    NSString *IMVersion = [[NIMSDK sharedSDK] sdkVersion];
    versionLabel.text = [NSString stringWithFormat:@"NIMSDK_LITE:%@ \n NERtcSDK:%@ \nNERtcCallKit:%@ \n 本APP仅用于展示网易云信实时音视频各类功能",IMVersion,rtcVersion,[NERtcCallKit versionCode]];
    versionLabel.numberOfLines = 0;
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
    
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.bottom.mas_equalTo(-40);
        make.height.mas_equalTo(80);
    }];
}

- (void)addObserver {
    
    [[NERtcCallKit sharedInstance] addDelegate:self];
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordAddNotification:) name:NERECORDADD object:nil];
    
    [NEAccount addObserverForObject:self actionBlock:^(NEAccountAction action) {
        
        if (action == NEAccountActionLogin) {
            //IM登录
            NEUser *user = [NEAccount shared].userModel;
            [[NERtcCallKit sharedInstance] login:user.imAccid token:user.imToken completion:^(NSError * _Nullable error) {
                if (error) {
                    [self.view makeToast:[NSString stringWithFormat:@"IM登录失败%@",error.localizedDescription]];
                }else{
                    // 首次登录成功之后上传deviceToken
                    NSData *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:deviceTokenKey];
                    [[NERtcCallKit sharedInstance] updateApnsToken:deviceToken];
                    [self updateUserInfo:[NEAccount shared].userModel];
                }
            }];
        }else {
            //IM退出
            [[NERtcCallKit sharedInstance] logout:^(NSError * _Nullable error) {
            }];
        }
    }];
}
- (void)updateUserInfo:(NEUser *)user {
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    if (user.mobile) {
        [ext setObject:user.mobile forKey:@(NIMUserInfoUpdateTagMobile)];
    }
    if (user.avatar) {
        [ext setObject:user.avatar forKey:@(NIMUserInfoUpdateTagAvatar)];
    }
    [NIMSDK.sharedSDK.userManager updateMyUserInfo:ext.copy completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"updateUserInfo error:%@",error);
            return;
        }
    }];
}
- (void)removeObserver {
    [[NERtcCallKit sharedInstance] removeDelegate:self];
    [NEAccount removeObserverForObject:self];
}
- (void)autoLogin {
    if ([[NEAccount shared].accessToken length] > 0) {
        [NEAccount loginByTokenWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
            if (error) {
                NSString *msg = data[@"msg"] ?: @"请求错误";
                [self.view makeToast:msg];
            }else {
                [[NERtcCallKit sharedInstance] login:[NEAccount shared].userModel.imAccid token:[NEAccount shared].userModel.imToken completion:^(NSError * _Nullable error) {
                    if (error) {
                        [self.view makeToast:error.localizedDescription];
                    }else {
                        [self.view makeToast:@"IM登录成功"];
                        [self updateUserInfo:[NEAccount shared].userModel];
                    }
                }];
            }
        }];
    }
}

- (void)userButtonClick:(UIButton *)button {
    
    __weak typeof(self) weakSelf = self;
    if ([NEAccount shared].hasLogin) {
        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:@"确认退出登录%@",[NEAccount shared].userModel.mobile] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [NEAccount logoutWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
                if (error) {
                    [self.view makeToast:error.localizedDescription];
                }else {
                    [[NERtcCallKit sharedInstance] logout:^(NSError * _Nullable error) {
                        if (error) {
                            [weakSelf.view makeToast:error.localizedDescription];
                        }else {
                            [weakSelf.view makeToast:@"已退出登录"];
                        }
                    }];
                }
            }];
        }];
        [alerVC addAction:cancelAction];
        [alerVC addAction:okAction];
        
        [self presentViewController:alerVC animated:YES completion:nil];
    }else {
        [[NENavigator shared] loginWithOptions:nil];
    }
}

#pragma mark - NERtcVideoCallDelegate
- (void)onInvited:(NSString *)invitor
          userIDs:(NSArray<NSString *> *)userIDs
      isFromGroup:(BOOL)isFromGroup
          groupID:(nullable NSString *)groupID
             type:(NERtcCallType)type
       attachment:(nullable NSString *)attachment {
    NSLog(@"menu controoler onInvited");
    [NIMSDK.sharedSDK.userManager fetchUserInfos:@[invitor] completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
        if (error) {
            [self.view makeToast:error.description];
            return;
        }else {
            NIMUser *imUser = users.firstObject;
            NEUser *remoteUser = [[NEUser alloc] init];
            remoteUser.imAccid = imUser.userId;
            remoteUser.mobile = imUser.userInfo.mobile;
            remoteUser.avatar = imUser.userInfo.avatarUrl;
            
            NECallViewController *callVC = [[NECallViewController alloc] init];
            callVC.localUser = [NEAccount shared].userModel;
            callVC.remoteUser = remoteUser;
            callVC.status = NERtcCallStatusCalled;
            callVC.callType = type;
            callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self.navigationController presentViewController:callVC animated:YES completion:nil];
            
        }
    }];
    
}

#pragma mark - IM delegate

- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages {
    
    for (NIMMessage *message in messages) {
        if (message.messageType == NIMMessageTypeRtcCallRecord) {
            NECallStatusRecordModel *record = [[NECallStatusRecordModel alloc] init];
            if ([message.from isEqualToString:[NEAccount shared].userModel.imAccid]) {
                return;
            }
            if ([message.messageObject isKindOfClass:[NIMRtcCallRecordObject class]]) {
                
                NIMRtcCallRecordObject *recordObject = (NIMRtcCallRecordObject *)message.messageObject;
                NSTimeInterval startTime = message.timestamp;
                record.isCaller = NO;
                record.status = recordObject.callStatus;
                record.isVideoCall = recordObject.callType == NIMRtcCallTypeVideo ? YES : NO;
                record.imAccid = message.from;
                if (recordObject.durations.count > 0) {
                    NSNumber *durationNumber = [recordObject.durations objectForKey: [NEAccount shared].userModel.imAccid];
                    record.duration = durationNumber.integerValue;
                    startTime = startTime - record.duration;
                }
                record.startTime = [NSDate dateWithTimeIntervalSince1970:startTime];

                NIMUserSearchOption *option = [[NIMUserSearchOption alloc] init];
                option.searchRange = NIMUserSearchRangeOptionAll;
                option.searchContentOption = NIMUserSearchContentOptionUserId;
                option.searchContent = message.from;
                [[[NIMSDK sharedSDK] userManager] searchUserWithOption:option completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
                    NIMUser *user = users.firstObject;
                    if (user) {
                        record.mobile = user.userInfo.mobile;
                        record.avatar = user.userInfo.avatarUrl;
                        NSLog(@"on call happen");
                        [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:record];
                    }
                }];
            }
        }
    }
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

#pragma mark - NSNotification
- (void)recordAddNotification:(NSNotification *)noti {
    NSObject *obj = noti.object;
    if ([obj isKindOfClass:[NECallStatusRecordModel class]]) {
        NECallStatusRecordModel *model = (NECallStatusRecordModel *)obj;
        NSLog(@"record caller : %d", model.isCaller);
        NSLog(@"record isvideo : %d", model.isVideoCall);
        NSString *filename = [NSString stringWithFormat:@"%@_%@",recordFileName, [NEAccount shared].userModel.imAccid];
        NSArray *records = [NSArray readArchiveFile:filename];
        NSMutableArray *mutableArray = [NSMutableArray new];
        [mutableArray addObject:obj];
        if (records.count <= 2) {
            [mutableArray addObjectsFromArray:records];
        }else {
            [mutableArray addObjectsFromArray:[records subarrayWithRange:NSMakeRange(0, 2)]];
        }
        [mutableArray writeToFile:filename];
        [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDCHANGE object:nil];
    }
}


@end
