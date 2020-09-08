//
//  NERtcConactsViewController.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NERtcContactsViewController.h"
#import "NEHistoryView.h"
#import "NESearchResultView.h"
#import "NECallViewController.h"
#import "NESearchTask.h"
#import "NEAccount.h"

static NSString *fileName = @"searchHistory";

@interface NERtcContactsViewController ()<UITextFieldDelegate,NEUserListViewDelegate>
@property(strong,nonatomic)UIView *searchBarView;
@property(strong,nonatomic)UITextField *textField;
@property(strong,nonatomic)NSArray *historyArray;
@property(strong,nonatomic)NEHistoryView *historyView;
@property(strong,nonatomic)NESearchResultView *resultView;
@end

@implementation NERtcContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    self.title = @"发起呼叫";
    UIColor *color = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:45/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:color];
    self.view.backgroundColor = color;
    [self setupSearchBar];
    [self setupHistoryView];
    [self setupSearchResultView];
    [self loadHistoryData];
}

#pragma mark - UI
- (void)setupSearchBar {
    [self.view addSubview:self.searchBarView];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    [self.searchBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(statusHeight + 44 + 8);
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
    searchBtn.layer.cornerRadius = 8;
    searchBtn.clipsToBounds = YES;
    searchBtn.backgroundColor = [UIColor colorWithRed:57/255.0 green:130/255.0 blue:252/255.0 alpha:1.0];
    [searchBtn addTarget:self action:@selector(searchBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBarView addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textField.mas_right).offset(10);
        make.right.mas_equalTo(-6);
        make.top.mas_equalTo(6);
        make.bottom.mas_equalTo(- 6);
        make.width.mas_equalTo(48);
    }];
}

- (void)setupHistoryView {
    [self.view addSubview:self.historyView];
    [self.historyView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [self.historyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.searchBarView.mas_bottom).offset(24);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(0);
    }];
    
}

- (void)setupSearchResultView {
    [self.view addSubview:self.resultView];
    CGFloat top = self.historyArray.count > 0 ? 24 : 0;
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.historyView.mas_bottom).offset(top);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - data
- (void)loadHistoryData {
    self.historyArray = [self readFileName:fileName];
    [self.historyView updateTitle:@"最近搜索" dataArray:self.historyArray];
}
- (void)searchMobile:(NSString *)mobile {
    NESearchTask *task =  [NESearchTask task];
    task.req_mobile = mobile;
    [task postWithCompletion:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        if (error) {
            [self.view makeToast:error.localizedDescription];
        }else {
            NSDictionary *userDic = [data objectForKey:@"data"];
            NSMutableArray *array = [NSMutableArray array];
            if (userDic) {
                if (userDic) {
                    NEUser *user = [[NEUser alloc] init];
                    user.mobile = [userDic objectForKey:@"mobile"];
                    user.imAccid = [userDic objectForKey:@"imAccid"];
                    user.avatar = [userDic objectForKey:@"avatar"];
                    [array addObject:user];
                    [self saveUser:user];
                }
                [self.resultView updateTitle:@"搜索结果" dataArray:array];
            }else {
                [self.view makeToast:@"暂无搜索结果"];
                [self.resultView updateTitle:@"" dataArray:array];
            }
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
    NSArray *historys = [self readFileName:fileName];
    if ([self.historyArray.firstObject isEqual:historys.firstObject]) {
        return YES;
    }
    self.historyArray = historys;
    [self.historyView updateTitle:@"最近搜索" dataArray:self.historyArray];
    return YES;
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

- (UIView *)searchBarView {
    if (!_searchBarView) {
        _searchBarView = [[UIView alloc] init];
        _searchBarView.backgroundColor = [UIColor colorWithRed:57/255.0 green:57/255.0 blue:69/255.0 alpha:1.0];
        _searchBarView.layer.cornerRadius = 8;
    }
    return _searchBarView;
}

- (NEHistoryView *)historyView {
    if (!_historyView) {
        _historyView = [[NEHistoryView alloc] init];
        _historyView.delegate = self;
    }
    return _historyView;
}

- (NESearchResultView *)resultView {
    if (!_resultView) {
        _resultView = [[NESearchResultView alloc] init];
        _resultView.delegate = self;
    }
    return _resultView;
}
#pragma mark - NEUserListViewDelegate
- (void)didSelectUser:(NEUser *)user {
    if ([user.imAccid isEqualToString:[NEAccount shared].userModel.imAccid]) {
        [self.view makeToast:@"呼叫用户不可以是自己哦"];
        return;
    }
    NECallViewController *callVC = [[NECallViewController alloc] init];
    callVC.localUser = [NEAccount shared].userModel;
    callVC.remoteUser = user;
    callVC.status = NECallStatusCall;
    callVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:callVC animated:YES completion:nil];
}

#pragma mark - file read & write
- (void)saveUser:(NEUser *)user {
    NSArray *array = [self readFileName:fileName];
    for (NEUser *saveUser in array) {
        if ([saveUser.mobile isEqualToString:user.mobile]) {
            return;
        }
    }
    NSMutableArray *mutArray = [NSMutableArray array];
    [mutArray addObjectsFromArray:array];
    
    if (mutArray.count >= 10) {
        [mutArray removeLastObject];
    }
    [mutArray insertObject:user atIndex:0];
    [self writeToFile:fileName array:mutArray];
}

- (NSArray *)readFileName:(NSString *)fileName {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return array;
}

- (void)writeToFile:(NSString *)fileName array:(NSArray *)array {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",fileName]];
    [NSKeyedArchiver archiveRootObject:array toFile:filePath];
}
@end
