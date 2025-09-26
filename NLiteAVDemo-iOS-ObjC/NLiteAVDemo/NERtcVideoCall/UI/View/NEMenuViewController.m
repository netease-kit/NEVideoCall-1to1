// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEMenuViewController.h"
#import "NEAccount.h"
#import "NECallStatusRecordModel.h"
#import "NEGroupContactsController.h"
#import "NEMenuCell.h"
#import "NENavCustomView.h"
#import "NENavigator.h"
#import "NEPSTNViewController.h"
#import "NERtcContactsViewController.h"
#import "NEUser.h"
#import "NSArray+NTES.h"

@interface NEMenuViewController () <UITableViewDelegate,
                                    UITableViewDataSource,
                                    NERtcCallKitDelegate,
                                    NEGroupCallKitDelegate,
                                    V2NIMMessageListener>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) UIImageView *bgImageView;
@end

static NSString *cellID = @"menuCellID";

@implementation NEMenuViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
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
  customView.userButton.accessibilityIdentifier = @"user_btn";
  [customView.userButton addTarget:self
                            action:@selector(userButtonClick:)
                  forControlEvents:UIControlEventTouchUpInside];

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
  NSString *rtcVersion =
      [NSBundle bundleForClass:[NERtcEngine class]].infoDictionary[@"CFBundleShortVersionString"];
  NSString *IMVersion = [[NIMSDK sharedSDK] sdkVersion];
  versionLabel.text = [NSString stringWithFormat:@"NIMSDK_LITE:%@ \n NERtcSDK:%@ \nNERtcCallKit:%@ "
                                                 @"\n 本APP仅用于展示网易云信实时音视频各类功能",
                                                 IMVersion, rtcVersion, [NERtcCallKit versionCode]];
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
  //  [[NIMSDK sharedSDK].chatManager addDelegate:self];
  [[[NIMSDK sharedSDK] v2MessageService] addMessageListener:self];

  [[NEGroupCallKit sharedInstance] addDelegate:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(recordAddNotification:)
                                               name:NERECORDADD
                                             object:nil];

  [NEAccount
      addObserverForObject:self
               actionBlock:^(NEAccountAction action) {
                 if (action == NEAccountActionLogin) {
                   // IM登录
                   NEUser *user = [NEAccount shared].userModel;
                   [[NERtcCallKit sharedInstance]
                            login:user.imAccid
                            token:user.imToken
                       completion:^(NSError *_Nullable error) {
                         if (error) {
                           [self.view
                               ne_makeToast:[NSString stringWithFormat:@"IM登录失败%@",
                                                                       error.localizedDescription]];
                         } else {
                           // 首次登录成功之后上传deviceToken
                           NSData *deviceToken =
                               [[NSUserDefaults standardUserDefaults] objectForKey:deviceTokenKey];
                           NSData *pushkitDeviceToken = [[NSUserDefaults standardUserDefaults]
                               objectForKey:pushKitDeviceTokenKey];

                           [[NERtcCallKit sharedInstance] updateApnsToken:deviceToken];
                           [[NERtcCallKit sharedInstance] updatePushKitToken:pushkitDeviceToken];

                           [self updateUserInfo:[NEAccount shared].userModel];
                         }
                       }];
                 } else {
                   // IM退出
                   [[NERtcCallKit sharedInstance] logout:^(NSError *_Nullable error){
                   }];
                 }
               }];
}

- (void)updateUserInfo:(NEUser *)user {
  V2NIMUserUpdateParams *param = [[V2NIMUserUpdateParams alloc] init];
  param.avatar = user.avatar;
  param.mobile = user.mobile;

  [[NIMSDK sharedSDK].v2UserService updateSelfUserProfile:param
      success:^{
      }
      failure:^(V2NIMError *_Nonnull error) {
        if (error) {
          NSLog(@"updateUserInfo error:%@", error);
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
    [NEAccount
        loginByTokenWithCompletion:^(NSDictionary *_Nullable data, NSError *_Nullable error) {
          if (error) {
            NSString *msg = data[@"msg"] ?: @"请求错误";
            [self.view ne_makeToast:msg];
          } else {
            [[NERtcCallKit sharedInstance] login:[NEAccount shared].userModel.imAccid
                                           token:[NEAccount shared].userModel.imToken
                                      completion:^(NSError *_Nullable error) {
                                        NSLog(@"login im error : %@", error);
                                        if (error) {
                                          [self.view ne_makeToast:error.localizedDescription];
                                        } else {
                                          [self.view ne_makeToast:@"IM登录成功"];
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
    UIAlertController *alerVC = [UIAlertController
        alertControllerWithTitle:@""
                         message:[NSString stringWithFormat:@"确认退出登录%@",
                                                            [NEAccount shared].userModel.mobile]
                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *_Nonnull action){

                                                         }];
    UIAlertAction *okAction = [UIAlertAction
        actionWithTitle:@"确认"
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *_Nonnull action) {
                  [NEAccount logoutWithCompletion:^(NSDictionary *_Nullable data,
                                                    NSError *_Nullable error) {
                    if (error) {
                      [self.view ne_makeToast:error.localizedDescription];
                    } else {
                      [[NERtcCallKit sharedInstance] logout:^(NSError *_Nullable error) {
                        if (error) {
                          [weakSelf.view ne_makeToast:error.localizedDescription];
                        } else {
                          [weakSelf.view ne_makeToast:@"已退出登录"];
                        }
                      }];
                    }
                  }];
                }];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];

    [self presentViewController:alerVC animated:YES completion:nil];
  } else {
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
  NECallUIKitConfig *config = [[NERtcCallUIKit sharedInstance] valueForKey:@"config"];
  if (config.uiConfig.disableShowCalleeView == NO) {
    NSLog(@"callee view show in call ui kit");
    return;
  }

  [NIMSDK.sharedSDK.v2UserService getUserListFromCloud:@[ invitor ]
      success:^(NSArray<V2NIMUser *> *_Nonnull result) {
        if (result.count < 1) {
          return;
        }

        V2NIMUser *user = result.firstObject;

        NEUser *remoteUser = [[NEUser alloc] init];
        remoteUser.imAccid = user.accountId;
        remoteUser.mobile = user.mobile;
        remoteUser.avatar = user.avatar;

        NEPSTNViewController *callVC = [[NEPSTNViewController alloc] init];
        callVC.localUser = [NEAccount shared].userModel;
        callVC.remoteUser = remoteUser;
        callVC.status = NERtcCallStatusCalled;
        callVC.callType = type;
        callVC.isCaller = NO;
        if (type == NERtcCallTypeAudio) {
          callVC.callKitType = PSTN;
        } else {
          callVC.callKitType = CALLKIT;
        }
        callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self.navigationController presentViewController:callVC animated:YES completion:nil];
      }
      failure:^(V2NIMError *_Nonnull error) {
        if (error) {
          [self.view ne_makeToast:error.description];
          return;
        }
      }];

  /*
    if (type == NERtcCallTypeAudio) {
        NEUser *remoteUser = [[NEUser alloc] init];
        remoteUser.imAccid = imUser.userId;
        remoteUser.mobile = imUser.userInfo.mobile;
        remoteUser.avatar = imUser.userInfo.avatarUrl;

        NEPSTNViewController *callVC = [[NEPSTNViewController alloc] init];
        callVC.localUser = [NEAccount shared].userModel;
        callVC.remoteUser = remoteUser;
        callVC.status = NERtcCallStatusCalled;
        callVC.callType = type;
        callVC.isCaller = NO;
        callVC.callKitType = PSTN;
        callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self.navigationController presentViewController:callVC animated:YES
    completion:nil]; }else { NECallViewController *callVC = [[NECallViewController
    alloc] init]; NEUICallParam *callParam = [[NEUICallParam alloc] init];
          callParam.remoteUserAccid = imUser.userId;
          callParam.remoteShowName = imUser.userInfo.mobile;
          callParam.remoteAvatar = imUser.userInfo.avatarUrl;
          callParam.currentUserAccid = [NEAccount shared].userModel.imAccid;
          callVC.callParam = callParam;
          callVC.isCaller = NO;
          callVC.status = NERtcCallStatusCalled;
          callVC.callType = type;
          callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
          [self.navigationController presentViewController:callVC animated:YES
    completion:nil];
    }*/
}

#pragma mark - IM delegate
/* v1
- (void)willSendMessage:(NIMMessage *)message {
  [self assmebleRecordWithMessage:message withCaller:YES];
}

- (void)sendMessage:(NIMMessage *)message progress:(float)progress {
}


- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages {
  NSLog(@"onRecvMessages current account : %@", [NIMSDK.sharedSDK.v2LoginService getLoginUser]);
  for (NIMMessage *message in messages) {
    if ([message.from isEqualToString:[NEAccount shared].userModel.imAccid]) {
      [self assmebleRecordWithMessage:message withCaller:YES];
      return;
    }
    [self assmebleRecordWithMessage:message withCaller:NO];
  }
}
*/

- (void)onSendMessage:(V2NIMMessage *)message {
  if (message.sendingState == V2NIM_MESSAGE_SENDING_STATE_SENDING) {
    [self assmebleRecordWithV2Message:message withCaller:YES];
  }
}

- (void)onReceiveMessages:(NSArray<V2NIMMessage *> *)messages;
{
  NSLog(@"onRecvMessages current account : %@", [NIMSDK.sharedSDK.v2LoginService getLoginUser]);
  for (V2NIMMessage *message in messages) {
    if ([message.senderId isEqualToString:[NEAccount shared].userModel.imAccid]) {
      [self assmebleRecordWithV2Message:message withCaller:YES];
      return;
    }
    [self assmebleRecordWithV2Message:message withCaller:NO];
  }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NEMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
  if (indexPath.row == 0) {
    cell.iconView.image = [UIImage imageNamed:@"menu_single_icon"];
  } else if (indexPath.row == 1) {
    cell.iconView.image = [UIImage imageNamed:@"menu_single_icon"];
    cell.titleLabel.text = @"多人音视频通话";
  } else if (indexPath.row == 2) {
    cell.iconView.image = [UIImage imageNamed:@"pstn"];
    cell.titleLabel.text = @"融合呼叫";
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (![NEAccount shared].hasLogin) {
    [[NENavigator shared] loginWithOptions:nil];
  } else {
    NERtcContactsViewController *contact = [[NERtcContactsViewController alloc] init];
    if (indexPath.row == 0) {
      contact.callKitType = CALLKIT;
    } else if (indexPath.row == 1) {
      NEGroupContactsController *group = [[NEGroupContactsController alloc] init];
      [self.navigationController pushViewController:group animated:YES];
      return;
    } else if (indexPath.row == 2) {
      contact.callKitType = PSTN;
    }
    [self.navigationController pushViewController:contact animated:YES];
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
    NSString *filename =
        [NSString stringWithFormat:@"%@_%@", recordFileName, [NEAccount shared].userModel.imAccid];
    NSArray *records = [NSArray readArchiveFile:filename];
    NSMutableArray *mutableArray = [NSMutableArray new];
    [mutableArray addObject:obj];
    if (records.count <= 2) {
      [mutableArray addObjectsFromArray:records];
    } else {
      [mutableArray addObjectsFromArray:[records subarrayWithRange:NSMakeRange(0, 2)]];
    }
    [mutableArray writeToFile:filename];
    [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDCHANGE object:nil];
  }
}

- (void)assmebleRecordWithMessage:(NIMMessage *)message withCaller:(BOOL)isCaller {
  if (message.messageType == NIMMessageTypeRtcCallRecord) {
    NECallStatusRecordModel *record = [[NECallStatusRecordModel alloc] init];

    if ([message.messageObject isKindOfClass:[NIMRtcCallRecordObject class]]) {
      NIMRtcCallRecordObject *recordObject = (NIMRtcCallRecordObject *)message.messageObject;
      NSTimeInterval startTime = message.timestamp;
      record.isCaller = isCaller;
      record.status = recordObject.callStatus;
      record.isVideoCall = recordObject.callType == NIMRtcCallTypeVideo ? YES : NO;

      if (recordObject.durations.count > 0) {
        NSNumber *durationNumber =
            [recordObject.durations objectForKey:[NEAccount shared].userModel.imAccid];
        record.duration = durationNumber.integerValue;
        startTime = startTime - record.duration;
      }
      record.startTime = [NSDate dateWithTimeIntervalSince1970:startTime];

      NIMUserSearchOption *option = [[NIMUserSearchOption alloc] init];
      option.searchRange = NIMUserSearchRangeOptionAll;
      option.searchContentOption = NIMUserSearchContentOptionUserId;
      if (isCaller == YES) {
        option.searchContent = message.session.sessionId;
        record.imAccid = message.session.sessionId;

      } else {
        record.imAccid = message.from;
        option.searchContent = message.from;
      }

      [NIMSDK.sharedSDK.v2UserService getUserListFromCloud:@[ record.imAccid ]
          success:^(NSArray<V2NIMUser *> *_Nonnull result) {
            if (result.count < 1) {
              return;
            }

            V2NIMUser *user = result.firstObject;
            NSLog(@"serch user : %lu", (unsigned long)result.count);
            if (user) {
              record.mobile = user.mobile;
              record.avatar = user.avatar;
              NSLog(@"on call happen");
              [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:record];
            }
          }
          failure:^(V2NIMError *_Nonnull error) {
            if (error) {
              NSLog(@"search error : %@", error);
            }
          }];
    }
  }
}

- (void)assmebleRecordWithV2Message:(V2NIMMessage *)message withCaller:(BOOL)isCaller {
  if (message.messageType == V2NIM_MESSAGE_TYPE_CALL) {
    NECallStatusRecordModel *record = [[NECallStatusRecordModel alloc] init];

    if ([message.attachment isKindOfClass:[V2NIMMessageCallAttachment class]]) {
      V2NIMMessageCallAttachment *recordObject = (V2NIMMessageCallAttachment *)message.attachment;
      NSTimeInterval startTime = message.createTime;
      record.isCaller = isCaller;
      record.status = recordObject.status;
      record.isVideoCall = recordObject.type == NIMRtcCallTypeVideo ? YES : NO;

      if (recordObject.durations.count > 0) {
        for (V2NIMMessageCallDuration *duration in recordObject.durations) {
          if ([duration.accountId isEqualToString:[NEAccount shared].userModel.imAccid]) {
            record.duration = duration.duration;
            startTime = startTime - record.duration;
          }
        }
      }
      record.startTime = [NSDate dateWithTimeIntervalSince1970:startTime];

      NIMUserSearchOption *option = [[NIMUserSearchOption alloc] init];
      option.searchRange = NIMUserSearchRangeOptionAll;
      option.searchContentOption = NIMUserSearchContentOptionUserId;

      if (isCaller == YES) {
        option.searchContent = message.receiverId;
        record.imAccid = message.receiverId;

      } else {
        record.imAccid = message.senderId;
        option.searchContent = message.senderId;
      }
    }

    [NIMSDK.sharedSDK.v2UserService getUserListFromCloud:@[ record.imAccid ]
        success:^(NSArray<V2NIMUser *> *_Nonnull result) {
          if (result.count < 1) {
            return;
          }

          V2NIMUser *user = result.firstObject;
          NSLog(@"serch user : %lu", (unsigned long)result.count);
          if (user) {
            record.mobile = user.mobile;
            record.avatar = user.avatar;
            NSLog(@"on call happen");
            [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:record];
          }
        }
        failure:^(V2NIMError *_Nonnull error) {
          if (error) {
            NSLog(@"search error : %@", error);
          }
        }];
  }
}

@end
