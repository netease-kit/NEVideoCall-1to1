// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupContactsController.h"
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import <NERtcCallUIKit/NEUIGroupCallParam.h>
#import "Attachment.h"
#import "GroupSettingViewController.h"
#import "GroupUserController.h"
#import "NEAccount.h"
#import "NECallStatusRecordCell.h"
#import "NEPSTNViewController.h"
#import "NERtcSettingViewController.h"
#import "NESearchResultCell.h"
#import "NESearchTask.h"
#import "NSArray+NTES.h"
#import "NSMacro.h"
#import "SectionHeaderView.h"

@interface NEGroupContactsController () <UITextFieldDelegate,
                                         NIMChatManagerDelegate,
                                         UITableViewDelegate,
                                         UITableViewDataSource,
                                         SearchCellDelegate,
                                         GroupUserDelegagte,
                                         V2NIMMessageListener>
@property(nonatomic, strong) UIView *searchBarView;
@property(nonatomic, strong) UITextField *textField;

@property(nonatomic, strong) UIView *searchResutlTitleView;

@property(nonatomic, strong) UIView *searchHistroyTitleView;

@property(nonatomic, strong) UIView *recordTitleView;

@property(nonatomic, strong) UILabel *currentUserPhone;

@property(nonatomic, strong) UITableView *contentTable;
/// 搜索结果
@property(nonatomic, strong) NSMutableArray *searchResultData;
/// 最近搜索
@property(nonatomic, strong) NSMutableArray *searchHistoryData;

@property(nonatomic, strong) NSMutableDictionary<NSString *, NEUser *> *flagDic;

@property(nonatomic, strong) SectionHeaderView *resultHeader;

@property(nonatomic, strong) SectionHeaderView *historyHeader;

@property(nonatomic, strong) SectionHeaderView *recordHeader;

@property(nonatomic, strong) GroupUserController *userController;

@property(nonatomic, strong) NEExpandButton *callBtn;

@end

@implementation NEGroupContactsController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.searchResultData = [[NSMutableArray alloc] init];
    self.searchHistoryData = [[NSMutableArray alloc] init];
    self.flagDic = [[NSMutableDictionary alloc] init];
    self.inCallUserDic = [[NSMutableDictionary alloc] init];
    [self loadHistoryData];
    self.totalCount = GroupCallUserLimit;
    self.hasJoinCount = 1;
    [[[NIMSDK sharedSDK] v2MessageService] addMessageListener:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"发起多人呼叫";
  if (self.calledUsers == nil) {
    self.calledUsers = [[NSMutableArray alloc] init];
  } else {
    for (NEUser *user in self.calledUsers) {
      if (user.imAccid.length > 0) {
        [self.flagDic setObject:user forKey:user.imAccid];
      }
    }
  }
  [self setupContent];
  [self setSetting];
  NSLog(@"current accid : %@", [[NIMSDK sharedSDK].v2LoginService getLoginUser]);
}

- (void)setSetting {
  UIBarButtonItem *rightItem =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(goToSettingView)];
  [rightItem setTintColor:UIColor.whiteColor];
  self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)userCountDidChange {
  if ([self.userController getAllUsers].count > 0) {
    _callBtn.hidden = NO;
  } else {
    _callBtn.hidden = YES;
  }
  if (self.isInvite == YES) {
    [_callBtn
        setTitle:[NSString stringWithFormat:@"发起呼叫(%lu/15)",
                                            (unsigned long)[self.userController getAllUsers].count +
                                                15 - self.totalCount]
        forState:UIControlStateNormal];
  } else {
    [_callBtn
        setTitle:[NSString stringWithFormat:@"发起呼叫(%lu/15)",
                                            (unsigned long)[self.userController getAllUsers].count]
        forState:UIControlStateNormal];
  }
}

- (void)backAction:(UIButton *)backButton {
  if (self.isInvite == YES) {
    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

- (void)goToSettingView {
  GroupSettingViewController *setting = [[GroupSettingViewController alloc] init];
  [self.navigationController pushViewController:setting animated:YES];
}

#pragma mark - UI

- (void)setupContent {
  [self.view addSubview:self.contentTable];
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  [self.contentTable mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.top.mas_equalTo(statusHeight + 44);
  }];
  self.contentTable.tableHeaderView = [self getHeaderView];
  self.contentTable.delegate = self;
  self.contentTable.dataSource = self;
  self.contentTable.backgroundColor = [UIColor clearColor];
  self.contentTable.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  [self.contentTable registerClass:[NESearchResultCell class]
            forCellReuseIdentifier:@"NESearchResultCell"];
  [self.contentTable registerClass:[NECallStatusRecordCell class]
            forCellReuseIdentifier:@"NECallStatusRecordCell"];

  self.userController = [[GroupUserController alloc] init];
  [self addChildViewController:self.userController];
  self.userController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
  self.contentTable.tableFooterView = self.userController.view;
  self.userController.weakTable = self.contentTable;
  self.userController.delegate = self;

  [self.view addSubview:self.callBtn];
  [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).offset(40);
    make.right.equalTo(self.view).offset(-40);
    make.height.mas_equalTo(44);
    make.bottom.equalTo(self.view).offset(-60);
  }];
  if (self.isInvite == YES) {
    [self userCountDidChange];
  }
}

- (UIView *)getHeaderView {
  // 搜索框与手机号
  UIView *back = [[UIView alloc] init];
  back.backgroundColor = UIColor.clearColor;
  back.frame = CGRectMake(0, 0, self.view.frame.size.width, 40 + 8 + 40);

  [back addSubview:self.searchBarView];
  [self.searchBarView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.right.mas_equalTo(-20);
    make.top.mas_equalTo(8);
    make.height.mas_equalTo(40);
  }];
  [self.searchBarView addSubview:self.textField];
  [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(10);
    make.top.mas_equalTo(0);
    make.height.mas_equalTo(40);
  }];
  UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
  [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
  searchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
  searchBtn.layer.cornerRadius = 4.0;
  searchBtn.clipsToBounds = YES;
  searchBtn.backgroundColor = [UIColor colorWithRed:57 / 255.0
                                              green:130 / 255.0
                                               blue:252 / 255.0
                                              alpha:1.0];
  [searchBtn addTarget:self
                action:@selector(searchBtn:)
      forControlEvents:UIControlEventTouchUpInside];
  [self.searchBarView addSubview:searchBtn];
  [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.textField.mas_right).offset(10);
    make.right.mas_equalTo(-6);
    make.top.mas_equalTo(6);
    make.bottom.mas_equalTo(-6);
    make.width.mas_equalTo(48);
  }];

  UILabel *currentPhoneLabel = [[UILabel alloc] init];
  currentPhoneLabel.textAlignment = NSTextAlignmentLeft;
  currentPhoneLabel.textColor = HEXCOLORA(0xFFFFFF, 0.5);
  currentPhoneLabel.font = [UIFont systemFontOfSize:14.0];
  currentPhoneLabel.text =
      [NSString stringWithFormat:@"您的手机号：%@", [NEAccount shared].userModel.mobile];
  [back addSubview:currentPhoneLabel];
  [currentPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchBarView);
    make.top.equalTo(self.searchBarView.mas_bottom).offset(20);
  }];

  return back;
}

- (void)didSelectSearchUser:(NEUser *)user {
}

#pragma mark - user controller delegate

- (void)didRemoveWithUser:(NEUser *)user {
  [self.flagDic removeObjectForKey:user.imAccid];
  [self.contentTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
                   withRowAnimation:UITableViewRowAnimationNone];
  [self userCountDidChange];
}

#pragma mark - data
- (void)loadHistoryData {
  [self.searchHistoryData removeAllObjects];
  NSArray *records = [self readFileName:historyFileName];
  [self.searchHistoryData addObjectsFromArray:records];
}

- (void)searchMobile:(NSString *)mobile {
  __weak typeof(self) weakSelf = self;

  NESearchTask *task = [NESearchTask task];
  task.req_mobile = mobile;
  [task postWithCompletion:^(NSDictionary *_Nullable data, NSError *_Nullable error) {
    if (error) {
      [weakSelf.view ne_makeToast:error.localizedDescription];
    } else {
      NSDictionary *userDic = [data objectForKey:@"data"];
      if (userDic) {
        if (userDic) {
          NEUser *user = [[NEUser alloc] init];
          user.mobile = [userDic objectForKey:@"mobile"];
          user.imAccid = [userDic objectForKey:@"imAccid"];
          user.avatar = [userDic objectForKey:@"avatar"];
          [weakSelf saveUser:user];
        }
      } else {
        [weakSelf.searchResultData removeAllObjects];
        [weakSelf.view ne_makeToast:@"未找到此用户"];
      }
      [weakSelf.contentTable reloadData];
    }
  }];
}

- (void)searchUser:(NSString *)account {
  [self.textField resignFirstResponder];
  if (!account.length) {
    return;
  }
  // 发送请求
  [self searchMobile:account];
}

#pragma mark - event
- (void)searchBtn:(UIButton *)button {
  [self searchUser:self.textField.text];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  if (self.textField.isFirstResponder) {
    [self.textField resignFirstResponder];
  }
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self searchUser:textField.text];
  return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  return YES;
}
- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if (str.length > 11) {
    return NO;
  }
  NSCharacterSet *invalidCharacters =
      [NSCharacterSet characterSetWithCharactersInString:@"0123456789"].invertedSet;
  return ([str rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound);
}
- (UITextField *)textField {
  if (!_textField) {
    _textField = [[UITextField alloc] init];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.delegate = self;
    _textField.textColor = [UIColor whiteColor];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
        initWithString:@"输入手机号搜索已注册用户"
            attributes:@{
              NSForegroundColorAttributeName : [UIColor grayColor],
              NSFontAttributeName : _textField.font
            }];
    _textField.attributedPlaceholder = string;
    _textField.layer.cornerRadius = 8;

    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
  }
  return _textField;
}

#pragma mark - file read & write
- (void)saveUser:(NEUser *)user {
  NSArray *array = [self readFileName:historyFileName];
  [self.searchResultData removeAllObjects];
  [self.searchResultData addObject:user];
  NSMutableArray *mutArray = [NSMutableArray array];
  [mutArray addObject:user];
  [mutArray addObjectsFromArray:array];
  for (NEUser *saveUser in array) {
    if ([saveUser.mobile isEqualToString:user.mobile]) {
      [mutArray removeObject:saveUser];
    }
  }
  while (mutArray.count > RecordCountLimit) {
    [mutArray removeLastObject];
  }
  [self writeToFile:historyFileName array:mutArray];
}

- (NSArray *)readFileName:(NSString *)fileName {
  NEUser *user = [NEAccount shared].userModel;
  fileName = [NSString stringWithFormat:@"%@_%@", fileName, user.imAccid];
  NSArray *array = [NSArray readArchiveFile:fileName];
  return array;
}

- (void)writeToFile:(NSString *)fileName array:(NSArray *)array {
  NEUser *user = [NEAccount shared].userModel;
  fileName = [NSString stringWithFormat:@"%@_%@", fileName, user.imAccid];
  [array writeToFile:fileName];
}

- (void)didCall {
  if ([self.userController getAllUsers].count <= 0) {
    [[UIApplication sharedApplication].keyWindow ne_makeToast:@"请选择通话成员"];
    return;
  }

  if (self.isInvite == YES) {
    if (self.completion) {
      self.completion([self.userController getAllUsers]);
    }
    [self backAction:nil];
  } else {
    NSLog(@"current user : %@", [NEAccount shared].userModel);

    // 获取被叫用户ID列表
    NSMutableArray<NSString *> *remoteUserIds = [[NSMutableArray alloc] init];
    NSArray<NEUser *> *allValues = [self.flagDic allValues];
    for (NEUser *user in allValues) {
      if (user.imAccid.length > 0) {
        [remoteUserIds addObject:user.imAccid];
      }
    }

    // 创建群组通话参数（使用最新的简化接口）
    NEUIGroupCallParam *groupCallParam = [[NEUIGroupCallParam alloc] init];
    groupCallParam.remoteUsers = remoteUserIds;

    // 发起群组通话（主叫用户信息会自动获取）
    [[NERtcCallUIKit sharedInstance] groupCallWithParam:groupCallParam];
  }
}

#pragma mark - 转换方法
// 注意：convertToGroupUser 方法已移除，用户信息转换现在在 NERtcCallUIKit 内部处理

#pragma mark - ui table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return self.searchResultData.count;
  } else if (section == 1) {
    return self.searchHistoryData.count;
  } else if (section == 2) {
    return self.calledUsers.count;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 || indexPath.section == 1) {
    NEUser *user;
    if (indexPath.section == 0) {
      user = self.searchResultData[indexPath.row];
    } else if (indexPath.section == 1) {
      user = self.searchHistoryData[indexPath.row];
    }
    NESearchResultCell *cell =
        (NESearchResultCell *)[tableView dequeueReusableCellWithIdentifier:@"NESearchResultCell"
                                                              forIndexPath:indexPath];
    [cell configureUI:user];
    NEUser *calledUser = [self.flagDic objectForKey:user.imAccid];
    if (calledUser != nil) {
      [cell setGrayBtn];
    } else {
      [cell setBlueBtn];
    }

    NEUser *inCallUser = [self.inCallUserDic objectForKey:user.imAccid];
    if (inCallUser != nil) {
      [cell setConectting];
    }
    cell.delegate = self;
    return cell;
  }
  NECallStatusRecordCell *cell = (NECallStatusRecordCell *)[tableView
      dequeueReusableCellWithIdentifier:@"NECallStatusRecordCell"
                           forIndexPath:indexPath];
  cell.accessibilityIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NEUser *user;
  if (indexPath.section == 0 || indexPath.section == 1) {
    if (indexPath.section == 0) {
      user = self.searchResultData[indexPath.row];
    } else if (indexPath.section == 1) {
      user = self.searchHistoryData[indexPath.row];
    }
  }
  if ([user.imAccid isEqualToString:[NIMSDK.sharedSDK.v2LoginService getLoginUser]]) {
    [UIApplication.sharedApplication.keyWindow ne_makeToast:@"不能呼叫自己"];
    return;
  }
  NEUser *inCallUser = [self.inCallUserDic objectForKey:user.imAccid];
  if (inCallUser != nil) {
    return;
  }

  NEUser *calledUser = [self.flagDic objectForKey:user.imAccid];
  if (calledUser == nil) {
    if ((self.hasJoinCount + [self.userController getAllUsers].count) >= GroupCallUserLimit) {
      [UIApplication.sharedApplication.keyWindow ne_makeToast:@"邀请已达上限"];
      return;
    }
    [self.userController addUsers:@[ user ]];
    [self.flagDic setObject:user forKey:user.imAccid];
    [tableView reloadData];
    //        NESearchResultCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //        [cell setGrayBtn];
  } else {
    [self.userController removeUsers:@[ calledUser ]];
    [self.flagDic removeObjectForKey:user.imAccid];
    [tableView reloadData];
    //        NESearchResultCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //        [cell setBlueBtn];
  }
  [self userCountDidChange];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    if (self.searchResultData.count > 0) {
      return SectionHeaderView.height;
    } else {
      return SectionHeaderView.hasContentHeight;
    }
  }

  if (section == 1) {
    if (self.searchHistoryData.count > 0) {
      return SectionHeaderView.height;
    }
  }

  if (section == 2) {
    if (self.calledUsers.count > 0) {
      return SectionHeaderView.height;
    }
  }

  return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    if (self.searchResultData.count > 0) {
      self.resultHeader.frame =
          CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
      [self.resultHeader.contentLabel setHidden:YES];
    } else {
      self.resultHeader.frame =
          CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.hasContentHeight);
      [self.resultHeader.contentLabel setHidden:NO];
    }
    return self.resultHeader;
  } else if (section == 1) {
    if (self.searchHistoryData.count > 0) {
      [self.historyHeader.dividerLine setHidden:NO];
      return self.historyHeader;
    }
  } else if (section == 2) {
    if (self.calledUsers.count > 0) {
      [self.recordHeader.dividerLine setHidden:NO];
      return self.recordHeader;
    }
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0;
}

#pragma mark - lazy init

- (NEExpandButton *)callBtn {
  if (!_callBtn) {
    _callBtn = [[NEExpandButton alloc] init];
    [_callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _callBtn.backgroundColor = HEXCOLOR(0x337EFF);
    _callBtn.layer.cornerRadius = 2.0;
    _callBtn.clipsToBounds = YES;
    [_callBtn setTitle:@"发起呼叫(0/15)" forState:UIControlStateNormal];
    [_callBtn addTarget:self
                  action:@selector(didCall)
        forControlEvents:UIControlEventTouchUpInside];
    _callBtn.hidden = YES;
  }
  return _callBtn;
}

- (UIView *)searchBarView {
  if (!_searchBarView) {
    _searchBarView = [[UIView alloc] init];
    _searchBarView.backgroundColor = [UIColor colorWithRed:57 / 255.0
                                                     green:57 / 255.0
                                                      blue:69 / 255.0
                                                     alpha:1.0];
    _searchBarView.layer.cornerRadius = 8;
  }
  return _searchBarView;
}

- (UITableView *)contentTable {
  if (nil == _contentTable) {
    _contentTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _contentTable.delegate = self;
    _contentTable.dataSource = self;
    _contentTable.separatorColor = [UIColor clearColor];
  }
  return _contentTable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 0;
}

- (SectionHeaderView *)resultHeader {
  if (nil == _resultHeader) {
    _resultHeader = [[SectionHeaderView alloc] init];
    _resultHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _resultHeader.contentLabel.text = @"无";
    _resultHeader.titleLabel.text = @"搜索结果";
  }
  return _resultHeader;
}

- (SectionHeaderView *)historyHeader {
  if (nil == _historyHeader) {
    _historyHeader = [[SectionHeaderView alloc] init];
    _historyHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _historyHeader.titleLabel.text = @"最近搜索";
  }
  return _historyHeader;
}

- (SectionHeaderView *)recordHeader {
  if (nil == _recordHeader) {
    _recordHeader = [[SectionHeaderView alloc] init];
    _recordHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, SectionHeaderView.height);
    _recordHeader.titleLabel.text = kWaittingCalledUser;
  }
  return _recordHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
  view.backgroundColor = [UIColor clearColor];
  return view;
}

- (void)testAccid:(NSString *)accid {
  //  NIMSession *session = [NIMSession session:accid type:NIMSessionTypeP2P];

#warning ya
  // 构造自定义消息附件
  //  NIMCustomObject *object = [[NIMCustomObject alloc] init];
  //  Attachment *attachment = [[Attachment alloc] init];
  //  object.attachment = attachment;
  //

  //    V2NIMMessageCustomAttachment *attachment =  [[V2NIMMessageCustomAttachment alloc] init];

  //  // 构造出具体消息并注入附件
  //  NIMMessage *message = [[NIMMessage alloc] init];
  //  message.messageObject = object;
  //
  //  // 错误反馈对象
  //  NSError *error = nil;
  //
  //  // 发送消息
  //  [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:&error];

  //    + (V2NIMMessage *)createCustomMessageWithAttachment:(V2NIMMessageCustomAttachment
  //    *)attachment
  //                                                subType:(int)subType;

  //    V2NIMMessage *message = [V2NIMMessageCreator createCustomMessageWithAttachment:attachment
  //    subType:0]; V2NIMSendMessageParams *params = [[V2NIMSendMessageParams alloc] init];
  //
  //    [[[NIMSDK sharedSDK] v2MessageService] sendMessage:message conversationId:@"conversationId"
  //    params:params success:^(V2NIMSendMessageResult * _Nonnull result) {
  //
  //    } failure:^(V2NIMError * _Nonnull error) {
  //
  //    } progress:^(NSUInteger) {
  //
  //    }];
}

#pragma mark - call view status delegate

- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model {
  [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:model];
}

//- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error {
//    NSLog(@"send complete : %@", error);
//    if (error == nil) {
//        [[UIApplication sharedApplication].keyWindow ne_makeToast:@"自定义消息发送成功"];
//    }
//}
//
//- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages {
//    NSLog(@"contacts onRecvMessages : %lu", (unsigned long)messages.count);
//    for (NIMMessage *message in messages) {
//        if (message.messageType == NIMMessageTypeCustom) {
//            [[UIApplication sharedApplication].keyWindow ne_makeToast:@"收到消息"];
//        }
//    }
//}
@end
