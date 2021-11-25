//
//  NERtcConactsViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcContactsViewController.h"
#import "NECallViewController.h"
#import "NESearchTask.h"
#import "NEAccount.h"
#import "NESearchResultCell.h"
#import "NECallStatusRecordCell.h"
#import "NESectionHeaderView.h"
#import "NSArray+NTES.h"
#import "NSMacro.h"
#import "NetManager.h"

@interface NERtcContactsViewController ()<UITextFieldDelegate, NIMChatManagerDelegate, UITableViewDelegate, UITableViewDataSource, SearchCellDelegate, NECallViewDelegate>
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

@property(nonatomic, strong) NESectionHeaderView *resultHeader;

@property(nonatomic, strong) NESectionHeaderView *historyHeader;

@property(nonatomic, strong) NESectionHeaderView *recordHeader;

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
    self.title = @"发起呼叫";
    [self setupContent];
    [self addObserver];
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
    [self.contentTable registerClass:[NESearchResultCell class] forCellReuseIdentifier:@"NESearchResultCell"];
    [self.contentTable registerClass:[NECallStatusRecordCell class] forCellReuseIdentifier:@"NECallStatusRecordCell"];
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
    searchBtn.backgroundColor = [UIColor colorWithRed:57/255.0 green:130/255.0 blue:252/255.0 alpha:1.0];
    [searchBtn addTarget:self action:@selector(searchBtn:) forControlEvents:UIControlEventTouchUpInside];
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
    currentPhoneLabel.text = [NSString stringWithFormat:@"您的手机号：%@",[NEAccount shared].userModel.mobile];
    [back addSubview:currentPhoneLabel];
    [currentPhoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarView);
        make.top.equalTo(self.searchBarView.mas_bottom).offset(20);
    }];
    
    return back;
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
    
    NESearchTask *task =  [NESearchTask task];
    task.req_mobile = mobile;
    [task postWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [weakSelf.view makeToast:error.localizedDescription];
        }else {
            NSDictionary *userDic = [data objectForKey:@"data"];
//            NSMutableArray *array = [NSMutableArray array];
            if (userDic) {
                if (userDic) {
                    NEUser *user = [[NEUser alloc] init];
                    user.mobile = [userDic objectForKey:@"mobile"];
                    user.imAccid = [userDic objectForKey:@"imAccid"];
                    user.avatar = [userDic objectForKey:@"avatar"];
//                    [array addObject:user];
                    [weakSelf saveUser:user];
                }
            }else {
                [weakSelf.searchResultData removeAllObjects];
                [weakSelf.view makeToast:@"未找到此用户"];
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
    //发送请求
    [self searchMobile:account];
}

- (void)updateRecord{
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (str.length > 11) {
        return NO;
    }
    NSCharacterSet *invalidCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"].invertedSet;
    return ([str rangeOfCharacterFromSet:invalidCharacters].location == NSNotFound);
}
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.delegate = self;
        _textField.textColor = [UIColor whiteColor];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"输入手机号搜索已注册用户" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:_textField.font}];
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
//        [self.view makeToast:@"呼叫用户不可以是自己哦"];
//        return;
//    }
//    [self didCallWithUser:user withType:NERtcCallTypeVideo];
}

- (void)didCallWithUser:(NEUser *)user withType:(NERtcCallType)callType {
    
    if ([user.imAccid isEqualToString:[NEAccount shared].userModel.imAccid]) {
        [self.view makeToast:@"呼叫用户不可以是自己哦"];
        return;
    }
    
    if ([[NetManager shareInstance] isClose] == YES) {
        [self.view makeToast:@"网络连接异常，请稍后再试"];
        return;
    }
    NECallViewController *callVC = [[NECallViewController alloc] init];
    callVC.localUser = [NEAccount shared].userModel;
    callVC.remoteUser = user;
    callVC.callType = callType;
    callVC.status = NERtcCallStatusCalling;
    callVC.isCaller = YES;
    callVC.delegate = self;
    callVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:callVC animated:YES completion:nil];
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
    while (mutArray.count > 3 ) {
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
    }else {
        [self.recordData addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, 2)]];
    }
    [self writeToFile:recordFileName array:self.recordData];
}

- (NSArray *)readFileName:(NSString *)fileName {
    NEUser *user = [NEAccount shared].userModel;
    fileName = [NSString stringWithFormat:@"%@_%@",fileName, user.imAccid];
    NSArray *array = [NSArray readArchiveFile:fileName];
    return array;
}

- (void)writeToFile:(NSString *)fileName array:(NSArray *)array {
    NEUser *user = [NEAccount shared].userModel;
    fileName = [NSString stringWithFormat:@"%@_%@",fileName, user.imAccid];
    [array writeToFile:fileName];
}

#pragma mark - Observer

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRecord) name:NERECORDCHANGE object:nil];
}

#pragma mark - ui table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.searchResultData.count;
    }else if(section == 1){
        return self.searchHistoryData.count;
    }else if(section == 2){
        return self.recordData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        NEUser *user;
        if (indexPath.section == 0) {
            user = self.searchResultData[indexPath.row];
        } else if(indexPath.section == 1) {
            user = self.searchHistoryData[indexPath.row];
        }
        NESearchResultCell *cell = (NESearchResultCell *)[tableView dequeueReusableCellWithIdentifier:@"NESearchResultCell" forIndexPath:indexPath];
        [cell configureUI:user];
        cell.delegate = self;
        return cell;
    }
    NECallStatusRecordCell *cell = (NECallStatusRecordCell *)[tableView dequeueReusableCellWithIdentifier:@"NECallStatusRecordCell" forIndexPath:indexPath];
    NECallStatusRecordModel *model = self.recordData[indexPath.row];
    [cell configure:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NEUser *user;
    if (indexPath.section == 0 || indexPath.section == 1){
        if (indexPath.section == 0) {
            user = self.searchResultData[indexPath.row];
        } else if(indexPath.section == 1) {
            user = self.searchHistoryData[indexPath.row];
        }
    } else if (indexPath.section == 2) {
        NECallStatusRecordModel *model = self.recordData[indexPath.row];
        user = [[NEUser alloc] init];
        user.imAccid = model.imAccid;
        user.mobile = model.mobile;
        user.avatar = model.avatar;
    }
    [self didCallWithUser:user withType:NERtcCallTypeVideo];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.searchResultData.count > 0) {
            return NESectionHeaderView.height;
        }else {
            return NESectionHeaderView.hasContentHeight;
        }
    }
    
    if (section == 1) {
        if (self.searchHistoryData.count > 0) {
            return NESectionHeaderView.height;
        }
    }
    
    if (section == 2) {
        if (self.recordData.count > 0){
            return NESectionHeaderView.height;
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.searchResultData.count > 0) {
            self.resultHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, NESectionHeaderView.height );
            [self.resultHeader.contentLabel setHidden:YES];
        }else {
            self.resultHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, NESectionHeaderView.hasContentHeight);
            [self.resultHeader.contentLabel setHidden:NO];
        }
        return self.resultHeader;
    }else if(section == 1){
        if (self.searchHistoryData.count > 0) {
            [self.historyHeader.dividerLine setHidden:NO];
            return self.historyHeader;
        }
    }else if(section == 2){
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

#pragma mark - lazy init

- (UIView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[UIView alloc] init];
        _searchBarView.backgroundColor = [UIColor colorWithRed:57/255.0 green:57/255.0 blue:69/255.0 alpha:1.0];
        _searchBarView.layer.cornerRadius = 8;
    }
    return _searchBarView;
}

- (UITableView *)contentTable {
    if (nil == _contentTable) {
        _contentTable = [[UITableView alloc] init];
        _contentTable.delegate = self;
        _contentTable.dataSource = self;
        _contentTable.separatorColor = [UIColor clearColor];
        
    }
    return _contentTable;
}

- (NESectionHeaderView *)resultHeader {
    if (nil == _resultHeader) {
        _resultHeader = [[NESectionHeaderView alloc] init];
        _resultHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, NESectionHeaderView.height);
        _resultHeader.contentLabel.text = @"无";
        _resultHeader.titleLabel.text = @"搜索结果";
    }
    return _resultHeader;
}

- (NESectionHeaderView *)historyHeader {
    if (nil == _historyHeader) {
        _historyHeader = [[NESectionHeaderView alloc] init];
        _historyHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, NESectionHeaderView.height);
        _historyHeader.titleLabel.text = @"最近搜索";
    }
    return _historyHeader;
}

- (NESectionHeaderView *)recordHeader {
    if (nil == _recordHeader) {
        _recordHeader = [[NESectionHeaderView alloc] init];
        _recordHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, NESectionHeaderView.height);
        _recordHeader.titleLabel.text = @"通话记录";
    }
    return _recordHeader;
}

#pragma mark - call view status delegate

- (void)didEndCallWithStatusModel:(NECallStatusRecordModel *)model {
    [[NSNotificationCenter defaultCenter] postNotificationName:NERECORDADD object:model];
}
@end
