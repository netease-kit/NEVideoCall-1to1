// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NERtcContactsViewController.h"
#import <NERtcCallUIKit/NERtcCallUIKit.h>
#import "NEAccount.h"
#import "NECallStatusRecordCell.h"
#import "NECallUISettingViewController.h"
#import "NEPSTNViewController.h"
#import "NERtcSettingViewController.h"
#import "NESearchResultCell.h"
#import "NESearchTask.h"
#import "NSArray+NTES.h"
#import "NSMacro.h"
#import "SectionHeaderView.h"

@interface NERtcContactsViewController () <UITextFieldDelegate,
                                           NIMChatManagerDelegate,
                                           UITableViewDelegate,
                                           UITableViewDataSource,
                                           SearchCellDelegate,
                                           NECallViewDelegate>
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
/// 通话记录
@property(nonatomic, strong) NSMutableArray *recordData;

@property(nonatomic, strong) SectionHeaderView *resultHeader;

@property(nonatomic, strong) SectionHeaderView *historyHeader;

@property(nonatomic, strong) SectionHeaderView *recordHeader;

@end

@implementation NERtcContactsViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.searchResultData = [[NSMutableArray alloc] init];
    self.searchHistoryData = [[NSMutableArray alloc] init];
    self.recordData = [[NSMutableArray alloc] init];
    [self loadHistoryData];
    [self loadRecordData];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  if (self.callKitType == CALLKIT) {
    self.title = @"发起呼叫";
  } else if (self.callKitType == PSTN) {
    self.title = @"发起融合呼叫";
  }
  [self setupContent];
  [self setSetting];
  [self addObserver];
  //  [[NERingPlayerManager shareInstance] playRingWithRingType:CRTRejectRing isRtcPlay:YES];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NERECORDCHANGE object:nil];
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

- (void)setSetting {
  UIBarButtonItem *rightItem =
      [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"]
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(goToSettingView)];
  [rightItem setTintColor:UIColor.whiteColor];

  UIBarButtonItem *setting2 = [[UIBarButtonItem alloc] initWithTitle:@"设置2"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(goToUISetting)];
  [setting2 setTintColor:UIColor.whiteColor];
  //  self.navigationItem.rightBarButtonItems = @[ rightItem, setting2 ];
}

#pragma mark - view conroller change

- (void)goToSettingView {
  NERtcSettingViewController *setting = [[NERtcSettingViewController alloc] init];
  [self.navigationController pushViewController:setting animated:YES];
}

- (void)goToUISetting {
  NECallUISettingViewController *setting = [[NECallUISettingViewController alloc] init];
  [self.navigationController pushViewController:setting animated:YES];
}

#pragma mark - data
- (void)loadHistoryData {
  [self.searchHistoryData removeAllObjects];
  NSArray *records = [self readFileName:historyFileName];
  [self.searchHistoryData addObjectsFromArray:records];
}

- (void)loadRecordData {
  [self.recordData removeAllObjects];
  NSArray *array = [self readFileName:recordFileName];
  [self.recordData addObjectsFromArray:array];
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

- (void)updateRecord {
  [self loadRecordData];
  [self.contentTable reloadData];
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

#pragma mark - SearchCellDelegate
- (void)didSelectSearchUser:(NEUser *)user {
  //    if ([user.imAccid isEqualToString:[NEAccount shared].userModel.imAccid]) {
  //        [self.view ne_makeToast:@"呼叫用户不可以是自己哦"];
  //        return;
  //    }
  //    [self didCallWithUser:user withType:NERtcCallTypeVideo];
}

- (void)didCallWithUser:(NEUser *)user withType:(NECallType)callType {
  if ([user.imAccid isEqualToString:[NEAccount shared].userModel.imAccid]) {
    [self.view ne_makeToast:@"呼叫用户不可以是自己哦"];
    return;
  }

  if ([[NetManager shareInstance] isClose] == YES) {
    [self.view ne_makeToast:@"网络连接异常，请稍后再试"];
    return;
  }

  if ([NECallEngine sharedInstance].callStatus != NECallStatusIdle) {
    [self.view ne_makeToast:@"正在通话中"];
    return;
  }

  NECallUIKitConfig *config = [[NERtcCallUIKit sharedInstance] valueForKey:@"config"];
  if (config.uiConfig.disableShowCalleeView == YES) {
    NEPSTNViewController *callVC = [[NEPSTNViewController alloc] init];
    callVC.localUser = [NEAccount shared].userModel;
    callVC.remoteUser = user;
    callVC.callType = callType;
    callVC.status = NERtcCallStatusCalling;
    callVC.isCaller = YES;
    callVC.delegate = self;
    callVC.callKitType = self.callKitType;
    callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:callVC animated:YES completion:nil];
    return;
  }

  NEUICallParam *callParam = [[NEUICallParam alloc] init];
  callParam.remoteUserAccid = user.imAccid;
  callParam.remoteShowName = user.mobile;
  callParam.remoteAvatar = user.avatar;
  callParam.channelName = [[SettingManager shareInstance] customChannelName];
  callParam.remoteDefaultImage = [[SettingManager shareInstance] remoteDefaultImage];
  callParam.muteDefaultImage = [[SettingManager shareInstance] muteDefaultImage];
  callParam.extra = [[SettingManager shareInstance] globalExtra];
  callParam.callType = callType;
  [[NERtcCallUIKit sharedInstance] callWithParam:callParam];
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

- (void)saveRecord:(NECallStatusRecordModel *)record {
  NSArray *array = [self readFileName:recordFileName];
  [self.recordData removeAllObjects];
  [self.recordData addObject:record];
  if (array.count <= 2) {
    [self.recordData addObjectsFromArray:array];
  } else {
    [self.recordData addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, 2)]];
  }
  [self writeToFile:recordFileName array:self.recordData];
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

#pragma mark - Observer

- (void)addObserver {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateRecord)
                                               name:NERECORDCHANGE
                                             object:nil];
}

#pragma mark - ui table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return self.searchResultData.count;
  } else if (section == 1) {
    return self.searchHistoryData.count;
  } else if (section == 2) {
    return self.recordData.count;
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
    cell.delegate = self;
    return cell;
  }
  NECallStatusRecordCell *cell = (NECallStatusRecordCell *)[tableView
      dequeueReusableCellWithIdentifier:@"NECallStatusRecordCell"
                           forIndexPath:indexPath];
  cell.accessibilityIdentifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
  NSLog(@"record cell id : %@ ", cell.accessibilityIdentifier);
  NECallStatusRecordModel *model = self.recordData[indexPath.row];
  [cell configure:model];
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
  } else if (indexPath.section == 2) {
    NECallStatusRecordModel *model = self.recordData[indexPath.row];
    user = [[NEUser alloc] init];
    user.imAccid = model.imAccid;
    user.mobile = model.mobile;
    user.avatar = model.avatar;
  }
  if (self.callKitType == CALLKIT) {
    [self didCallWithUser:user withType:[self isAudioCall] ? NECallTypeAudio : NECallTypeVideo];
  } else if (self.callKitType == PSTN) {
    [self didCallWithUser:user withType:NECallTypeAudio];
  }
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
    if (self.recordData.count > 0) {
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
    if (self.recordData.count > 0) {
      [self.recordHeader.dividerLine setHidden:NO];
      return self.recordHeader;
    }
  }
  return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
  view.backgroundColor = [UIColor clearColor];
  return view;
}

#pragma mark - lazy init

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
    _recordHeader.titleLabel.text = @"通话记录";
  }
  return _recordHeader;
}

- (BOOL)isAudioCall {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSNumber *number = [defaults objectForKey:@"audio_call"];
  return number.boolValue;
}

#pragma mark - call view status delegate

- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model {
  [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:model];
}
@end
