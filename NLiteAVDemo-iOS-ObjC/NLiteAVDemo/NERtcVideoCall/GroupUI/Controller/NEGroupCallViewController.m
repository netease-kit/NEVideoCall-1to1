// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupCallViewController.h"
#import "NEGroupCalledViewController.h"
#import "NEGroupContactsController.h"
#import "NEGroupInCallViewController.h"
#import "NEGroupUserController.h"

@interface NEGroupCallViewController () <NEGroupCalledDelegate, NEGroupCallKitDelegate>

@property(nonatomic, strong) NSMutableArray<NEUser *> *datas;

@property(nonatomic, assign) BOOL isCalled;

@property(nonatomic, strong) NEUser *caller;

@property(nonatomic, strong) NEGroupCalledViewController *calledController;

@property(nonatomic, strong) NEGroupInCallViewController *inCallController;

@property(nonatomic, strong) NEVideoOperationView *operationView;

@property(nonatomic, assign) CGFloat factor;

@property(nonatomic, strong) NEExpandButton *cameraBtn;

@property(nonatomic, strong) NEExpandButton *inviteBtn;

@property(nonatomic, strong) UILabel *timerLabel;

@property(nonatomic, strong) NSTimer *timer;

@property(nonatomic, assign) int timerCount;

@property(nonatomic, assign) BOOL isOpenLocalVideo;

@end

@implementation NEGroupCallViewController

- (instancetype)initWithCalled:(BOOL)isCalled withCaller:(NEUser *)caller {
  self = [super init];
  if (self) {
    self.datas = [[NSMutableArray alloc] init];
    self.caller = caller;
    self.isCalled = isCalled;
    self.factor = 1.0;
    self.timerCount = 0;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  if (self.view.frame.size.height < 600) {
    self.factor = 0.5;
  }
  [[NEGroupCallKit sharedInstance] addDelegate:self];
  [[NERtcCallKit sharedInstance] muteLocalVideo:YES];
  [[NERtcCallKit sharedInstance] enableLocalVideo:NO];
  [self setupInCallUI];
  [self.view addSubview:self.timerLabel];
  [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.view);
    make.top.equalTo(self.view).offset(60 * self.factor);
  }];
  if (self.isCalled == YES) {
    [self setupCalledMaskUI];
  } else {
    [self startTimer];
    GroupCallParam *param = [[GroupCallParam alloc] init];
    NSMutableArray *calleeList = [[NSMutableArray alloc] init];
    for (NEUser *user in self.datas) {
      if ([user.imAccid isEqualToString:self.caller.imAccid]) {
        user.state = GroupMemberStateInChannel;
        continue;
      }
      [calleeList addObject:user.imAccid];
    }
    param.calleeList = calleeList;
    NSString *uuid = [self getRandomString];
    param.callId = uuid;
    self.callId = uuid;
    NSLog(@"call id : %@", param.callId);
    NSLog(@"call id length : %lu", (unsigned long)param.callId.length);
    if ([[SettingManager shareInstance] isGroupPush] == YES) {
      param.pushParam.pushMode = GroupPushModeOpen;
      if ([[SettingManager shareInstance] customPushContent].length > 0) {
        param.pushParam.pushContent = [[SettingManager shareInstance] customPushContent];
      }
    } else {
      param.pushParam.pushMode = GroupPushModeClose;
    }

    [[NEGroupCallKit sharedInstance]
         groupCall:param
        completion:^(NSError *_Nullable error, GroupCallResult *_Nullable result) {
          if (error != nil) {
            [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
            [self didBack];
            return;
          }
          NSLog(@"group call :%@  result : %@", error, result);
        }];
  }
}

- (void)addUser:(NSArray<NEUser *> *)users {
  [self.datas addObjectsFromArray:users];
}

- (NSString *)getRandomString {
  NSMutableString *muta = [NSMutableString stringWithString:@"1"];
  for (int i = 0; i < 11; i++) {
    int x = random() % 10;
    [muta appendFormat:@"%d", x];
  }
  return muta;
}

#pragma mark - UI

- (void)setupCalledMaskUI {
  self.calledController = [[NEGroupCalledViewController alloc] initWithCaller:self.caller];
  [self.calledController changeUsers:self.datas];
  [self addChildViewController:self.calledController];
  [self.view addSubview:self.calledController.view];
  self.calledController.delegate = self;
  [self.calledController.view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];
}

- (void)setupInCallUI {
  // 通话主界面(群组通话成员列表)
  self.inCallController = [[NEGroupInCallViewController alloc] init];
  [self refreshCollection];
  [self addChildViewController:self.inCallController];
  [self.view addSubview:self.inCallController.view];
  [self.inCallController.view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];

  // 工具栏(挂断 麦克风 关闭开启式视频等)
  [self.view addSubview:self.operationView];
  [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.view.mas_centerX);
    make.height.mas_equalTo(60);
    make.width.equalTo(self.view).multipliedBy(0.8);
    make.bottom.mas_equalTo(-50 * self.factor);
  }];

  // 前后摄像头
  [self.view addSubview:self.cameraBtn];
  [self.cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(12);
    make.top.equalTo(self.view).offset(56);
  }];

  // 邀请
  [self.view addSubview:self.inviteBtn];
  [self.inviteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.view).offset(-12);
    make.top.equalTo(self.view).offset(56);
    make.width.height.mas_equalTo(40);
  }];
}

- (void)startTimer {
  if (self.timer != nil) {
    return;
  }
  if (self.timerLabel.hidden == YES) {
    self.timerLabel.hidden = NO;
  }
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(figureTimer)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)figureTimer {
  self.timerCount++;
  self.timerLabel.text = [self timeFormatted:self.timerCount];
}

- (NSString *)timeFormatted:(int)totalSeconds {
  if (totalSeconds < 3600) {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
  }
  int seconds = totalSeconds % 60;
  int minutes = (totalSeconds / 60) % 60;
  int hours = totalSeconds / 3600;
  return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}

- (void)setCalledCount {
  NSDate *date = [NSDate date];
  NSTimeInterval time = [date timeIntervalSince1970];
  int value = time - self.startTimestamp / 1000;
  self.timerCount = value;
  NSLog(@"setCalledCount %d", self.timerCount);
}

- (NSMutableArray<NSArray<NEUser *> *> *)chunkArray:(NSArray<NEUser *> *)array
                                           withSize:(NSInteger)size {
  NSMutableArray<NSArray<NEUser *> *> *arrayOfArrays = [NSMutableArray array];
  NSInteger itemsRemaining = [array count];
  NSInteger j = 0;
  while (itemsRemaining) {
    NSRange range = NSMakeRange(j, MIN(size, itemsRemaining));
    NSArray *subarray = [array subarrayWithRange:range];
    [arrayOfArrays addObject:subarray];
    itemsRemaining -= range.length;
    j += range.length;
  }
  return arrayOfArrays;
}

- (void)setLocalVideoEnable:(BOOL)enable {
  for (int i = 0; i < self.datas.count; i++) {
    NEUser *user = [self.datas objectAtIndex:i];
    if (user.imAccid.length > 0 &&
        [user.imAccid isEqualToString:NIMSDK.sharedSDK.loginManager.currentAccount]) {
      user.isOpenVideo = enable;
      user.isShowLocalVideo = enable;
      NSLog(@"setLocalVideoEnable %d", enable);
      NSLog(@"setLocalVideoEnable accid : %@", user.imAccid);
      break;
    }
  }
  [self refreshCollection];
}

#pragma mark - delegate

- (void)calledDidAccept {
  [self.calledController removeFromParentViewController];
  [self.calledController.view removeFromSuperview];
  GroupAcceptParam *param = [[GroupAcceptParam alloc] init];
  param.callId = self.callId;
  __weak typeof(self) weakSelf = self;
  [self startTimer];
  [[NEGroupCallKit sharedInstance]
      groupAccept:param
       completion:^(NSError *_Nullable error, GroupAcceptResult *_Nullable result) {
         if (error != nil) {
           [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
           [weakSelf didBack];
           return;
         }
         NSLog(@"call member user list : %@", result.groupCallInfo.calleeList);
         [DataManager.shareInstance
             fetchUserWithMembers:result.groupCallInfo.calleeList
                       completion:^(NSError *_Nullable error, NSArray<NEUser *> *_Nonnull users) {
                         NSLog(@"call neuser list : %@", users);
                         [weakSelf.datas removeAllObjects];
                         [weakSelf.datas addObjectsFromArray:users];
                         [weakSelf refreshCollection];
                       }];
       }];
}

- (void)calledDidReject {
  GroupHangupParam *param = [[GroupHangupParam alloc] init];
  param.callId = self.callId;
  [[NEGroupCallKit sharedInstance]
      groupHangup:param
       completion:^(NSError *_Nullable error, GroupHangupResult *_Nullable result) {
         if (error != nil) {
           [[UIApplication sharedApplication].keyWindow makeToast:error.localizedDescription];
           return;
         }
       }];
  [self didBack];
}

- (void)refreshCollection {
  NSLog(@"refreshCollection data count %lu", (unsigned long)self.datas.count);
  [self.inCallController changeUsers:[self chunkArray:self.datas withSize:4]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - action
- (void)switchCameraBtn:(UIButton *)button {
  [[NERtcEngine sharedEngine] switchCamera];
}

- (void)microPhoneClick:(UIButton *)button {
  button.selected = !button.selected;
  [[NERtcCallKit sharedInstance] muteLocalAudio:button.selected];
}

- (void)cameraBtnClick:(UIButton *)button {
  if (button.isSelected == YES) {
    if (self.isOpenLocalVideo == NO) {
      [NERtcCallKit.sharedInstance enableLocalVideo:YES];
      self.isOpenLocalVideo = YES;
      NSLog(@"open local video");
    }
    [self setLocalVideoEnable:YES];
    [[NERtcCallKit sharedInstance] muteLocalVideo:NO];
  } else {
    [self setLocalVideoEnable:NO];
    [[NERtcCallKit sharedInstance] muteLocalVideo:YES];
  }
  button.selected = !button.isSelected;
}

- (void)hangupBtnClick:(UIButton *)button {
  NSLog(@"hangup btn click");
  //[self dismissViewControllerAnimated:YES completion:nil];
  [self didBack];
  GroupHangupParam *param = [[GroupHangupParam alloc] init];
  param.callId = self.callId;
  [[NEGroupCallKit sharedInstance]
      groupHangup:param
       completion:^(NSError *_Nullable error, GroupHangupResult *_Nullable result){

       }];
}

- (void)operationSpeakerClick:(UIButton *)btn {
}

- (void)changeCameraFrontOrBack {
  [[NERtcEngine sharedEngine] switchCamera];
}

- (void)inviteUsers {
  __weak typeof(self) weakSelf = self;
  NEGroupContactsController *group = [[NEGroupContactsController alloc] init];
  group.isInvite = YES;
  for (NEUser *user in self.datas) {
    [group.inCallUserDic setObject:user forKey:user.imAccid];
  }
  group.totalCount = GroupCallUserLimit - self.datas.count;
  group.hasJoinCount = self.datas.count;
  group.completion = ^(NSArray<NEUser *> *_Nonnull users) {
    GroupInviteParam *param = [[GroupInviteParam alloc] init];
    param.callId = weakSelf.callId;
    NSMutableArray *calleeList = [[NSMutableArray alloc] init];
    for (NEUser *user in users) {
      [calleeList addObject:user.imAccid];
    }
    param.calleeList = calleeList;

    [[NEGroupCallKit sharedInstance]
        groupInvite:param
         completion:^(NSError *_Nullable error, GroupInviteResult *_Nullable result) {
           NSLog(@"groupInvite : %@", error);
           if (error != nil) {
             [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
             return;
           }
         }];
  };
  group.title = @"邀请";
  group.modalPresentationStyle = UIModalPresentationFullScreen;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:group];
  [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - lazy init

- (UILabel *)timerLabel {
  if (nil == _timerLabel) {
    _timerLabel = [[UILabel alloc] init];
    _timerLabel.textColor = [UIColor whiteColor];
    _timerLabel.font = [UIFont systemFontOfSize:14.0];
    _timerLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _timerLabel;
}

- (NEVideoOperationView *)operationView {
  if (!_operationView) {
    _operationView = [[NEVideoOperationView alloc] init];
    _operationView.layer.cornerRadius = 30;
    [_operationView.microPhone addTarget:self
                                  action:@selector(microPhoneClick:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_operationView.cameraBtn addTarget:self
                                 action:@selector(cameraBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    [_operationView.cameraBtn setSelected:YES];
    [_operationView.hangupBtn addTarget:self
                                 action:@selector(hangupBtnClick:)
                       forControlEvents:UIControlEventTouchUpInside];
    [_operationView.speakerBtn addTarget:self
                                  action:@selector(operationSpeakerClick:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_operationView setGroupStyle];
    _operationView.backgroundColor = [_operationView.backgroundColor colorWithAlphaComponent:0.7];
  }
  return _operationView;
}

- (NEExpandButton *)cameraBtn {
  if (!_cameraBtn) {
    _cameraBtn = [[NEExpandButton alloc] init];
    [_cameraBtn setImage:[UIImage imageNamed:@"group_camera"] forState:UIControlStateNormal];
    [_cameraBtn addTarget:self
                   action:@selector(changeCameraFrontOrBack)
         forControlEvents:UIControlEventTouchUpInside];
  }
  return _cameraBtn;
}

- (NEExpandButton *)inviteBtn {
  if (!_inviteBtn) {
    _inviteBtn = [[NEExpandButton alloc] init];
    [_inviteBtn setImage:[UIImage imageNamed:@"group_add"] forState:UIControlStateNormal];
    [_inviteBtn addTarget:self
                   action:@selector(inviteUsers)
         forControlEvents:UIControlEventTouchUpInside];
  }
  return _inviteBtn;
}

#pragma mark group call delegate

- (void)onGroupHangupWithReason:(NSString *)reason {
  NSLog(@"Group controller onGroupHangupWithReason %@", reason);
  if ([reason isEqualToString:kReasonPeerAccept]) {
    [UIApplication.sharedApplication.keyWindow makeToast:@"其他端已接听"];
  }
  [self didBack];
}

- (void)onGroupUserDidChange:(NSArray<GroupCallMember *> *)members {
  NSLog(@"onGroupUserDidChange member count %ld", [members count]);
  __weak typeof(self) weakSelf = self;
  NSMutableArray *filters = [[NSMutableArray alloc] init];
  for (GroupCallMember *member in members) {
    NSLog(@"memmber state : %lu member video : %d", member.state, member.isOpenVideo);
    if (member.state != GroupMemberStateHangup) {
      [filters addObject:member];
    }
  }
  [[DataManager shareInstance]
      fetchUserWithMembers:filters
                completion:^(NSError *_Nullable error, NSArray<NEUser *> *_Nonnull users) {
                  for (NEUser *user in users) {
                    if ([user.imAccid
                            isEqualToString:NIMSDK.sharedSDK.loginManager.currentAccount]) {
                      user.isShowLocalVideo = !self.operationView.cameraBtn.isSelected;
                      user.isOpenVideo = !self.operationView.cameraBtn.isSelected;
                    }
                  }
                  [weakSelf.datas removeAllObjects];
                  [weakSelf.datas addObjectsFromArray:users];
                  [weakSelf refreshCollection];
                }];
}

- (void)onGroupEndCallWithReason:(NSInteger)reason withCallId:(NSString *)callId {
  NSLog(@"controller onGroupEndCallWithReason :%@  parameter call id : %@", self.callId, callId);
  if ([self.callId isEqualToString:callId]) {
    [self didBack];
  }
}

- (void)onGroupRemoteUserOpenVideo:(uint64_t)uid withOpen:(BOOL)isOpen {
  NSLog(@"controller onGroupRemoteUserOpenVideo %lld  open : %d", uid, isOpen);
  for (NEUser *user in self.datas) {
    NSLog(@"remote video mute change uid : %lld", user.uid);
    if (user.uid == uid) {
      NSLog(@"onGroupRemoteUserOpenVideo : %lld open: %d", uid, isOpen);
      user.isOpenVideo = isOpen;
      [self refreshCollection];
      return;
    }
  }
}

- (void)onGroupError:(NSError *)error {
}

- (void)didBack {
  [[NEGroupCallKit sharedInstance] removeDelegate:self];
  NSLog(@"didback :  %@", self.presentedViewController);
  if (self.presentedViewController != nil) {
    NSLog(@"didback NEGroupContactsController");
    [self dismissViewControllerAnimated:YES completion:nil];
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
