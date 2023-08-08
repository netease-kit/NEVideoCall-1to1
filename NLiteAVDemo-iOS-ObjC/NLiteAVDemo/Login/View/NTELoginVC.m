// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NTELoginVC.h"
#import "NELoginOptions.h"
#import "NENavigator.h"
#import "NESendSmsCodeTask.h"
#import "NEService.h"
#import "NSMacro.h"
#import "NTFInputSmsVC.h"
#import "UIColor+NTES.h"
#import "UIImage+NTES.h"
#import "UIView+NTES.h"

@interface NTELoginVC () <UITextFieldDelegate>

@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) UILabel *areaLab;
@property(nonatomic, strong) UIView *verLine;
@property(nonatomic, strong) UITextField *phoneNumField;
@property(nonatomic, strong) UIView *horLine;
@property(nonatomic, strong) UILabel *tipLab;
@property(nonatomic, strong) UIButton *getSmsBtn;
@property(nonatomic, strong) UITextView *protocolView;
@property(nonatomic, strong) UIButton *cancelBtn;

@property(nonatomic, strong) NELoginOptions *options;

@end

@implementation NTELoginVC

- (instancetype)initWithOptions:(NELoginOptions *_Nullable)options {
  self = [super init];
  if (self) {
    _options = options;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  self.view.backgroundColor = [UIColor whiteColor];
  [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.navigationController setNavigationBarHidden:YES];
}

/**
 *  self code
 */

- (void)setupSubviews {
  [self.view addSubview:self.cancelBtn];
  [self.view addSubview:self.titleLab];
  [self.view addSubview:self.areaLab];
  [self.view addSubview:self.verLine];
  [self.view addSubview:self.phoneNumField];
  [self.view addSubview:self.horLine];
  [self.view addSubview:self.tipLab];
  [self.view addSubview:self.getSmsBtn];
  [self.view addSubview:self.protocolView];
  self.cancelBtn.frame = CGRectMake(self.view.width - 60, 80, 30, 30);
  self.titleLab.frame = CGRectMake(30, 130, self.view.width - 60, 40);
  self.areaLab.frame = CGRectMake(self.titleLab.left, self.titleLab.bottom + 30, 40, 44);
  self.verLine.frame = CGRectMake(self.areaLab.right + 4, self.areaLab.top + 11, 1, 22);
  self.phoneNumField.frame = CGRectMake(self.verLine.right + 10, self.areaLab.top,
                                        self.titleLab.width - self.verLine.right - 10, 44);
  [self.phoneNumField becomeFirstResponder];
  self.horLine.frame =
      CGRectMake(self.titleLab.left, self.phoneNumField.bottom + 1, self.titleLab.width, 1);
  self.tipLab.frame =
      CGRectMake(self.titleLab.left, self.horLine.bottom + 10, self.titleLab.width, 18);
  self.getSmsBtn.frame =
      CGRectMake(self.titleLab.left, self.tipLab.bottom + 36, self.titleLab.width, 50);
  CGFloat safeAreaHeight = 0;
  if (@available(iOS 11.0, *)) {
    safeAreaHeight =
        [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0 ? 34 : 0;
  }
  self.protocolView.frame =
      CGRectMake(self.titleLab.left, self.getSmsBtn.bottom + 30, self.titleLab.width, 30);

  self.protocolView.attributedText = [self protocolText];
  self.protocolView.textAlignment = NSTextAlignmentCenter;

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
  [self.view addGestureRecognizer:tap];
}

- (void)endEditing {
  [self.view endEditing:YES];
}

- (void)getSmsAction {
  NESendSmsCodeTask *task = [NESendSmsCodeTask taskWithSubURL:@"/auth/sendLoginSmsCode"];
  task.req_mobile = _phoneNumField.text;
  [[NEService shared] runTask:task
                   completion:^(NSDictionary *_Nullable data, NSError *_Nullable error) {
                     ntes_main_async_safe(^{
                       if (error) {
                         NSString *msg = [error localizedDescription] ?: @"请求错误";
                         [self.view ne_makeToast:msg];
                       } else {
                         NTFInputSmsVC *vc =
                             [[NTFInputSmsVC alloc] initWithMobile:self.phoneNumField.text
                                                           options:self.options];
                         //            UINavigationController *nav = [[UINavigationController alloc]
                         //            initWithRootViewController:vc]; vc.modalPresentationStyle =
                         //            UIModalPresentationOverFullScreen;
                         [self.navigationController pushViewController:vc animated:YES];
                       }
                     });
                   }];
}

- (NSAttributedString *)protocolText {
  NSDictionary *norAttr = @{NSForegroundColorAttributeName : HEXCOLOR(0x999999)};
  NSMutableAttributedString *attr =
      [[NSMutableAttributedString alloc] initWithString:@"登录即视为您已同意 " attributes:norAttr];

  NSMutableAttributedString *tempAttr =
      [[NSMutableAttributedString alloc] initWithString:@"隐私政策"
                                             attributes:@{
                                               NSForegroundColorAttributeName : HEXCOLOR(0x337EFF),
                                               NSLinkAttributeName : kPrivatePolicyURL
                                             }];
  [attr appendAttributedString:[tempAttr copy]];

  tempAttr = [[NSMutableAttributedString alloc] initWithString:@" 和 " attributes:norAttr];
  [attr appendAttributedString:[tempAttr copy]];

  tempAttr =
      [[NSMutableAttributedString alloc] initWithString:@"用户协议"
                                             attributes:@{
                                               NSForegroundColorAttributeName : HEXCOLOR(0x337EFF),
                                               NSLinkAttributeName : kUserAgreementURL
                                             }];
  [attr appendAttributedString:[tempAttr copy]];

  return [attr copy];
}

#pragma mark - UITextField delegate

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string {
  if (textField != self.phoneNumField) {
    return YES;
  }

  if ([string isEqualToString:@""]) {
    return YES;
  }
  if (textField.text.length >= 11) {
    return NO;
  }
  NSString *validRegEx = @"^[0-9]$";
  NSPredicate *reg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
  if (![reg evaluateWithObject:string]) {
    return NO;
  }

  return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
  BOOL valid = [self validPhoneNum:textField.text];
  self.getSmsBtn.enabled = valid;
}

- (BOOL)validPhoneNum:(NSString *)phoneNum {
  NSString *validRegEx = @"^1[35789]\\d{9}$";
  NSPredicate *reg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
  return [reg evaluateWithObject:phoneNum];
}
- (void)cancelBtnClick {
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - lazy method
- (UIButton *)cancelBtn {
  if (!_cancelBtn) {
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setImage:[UIImage imageNamed:@"login_cancel"] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self
                   action:@selector(cancelBtnClick)
         forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelBtn;
}
- (UILabel *)titleLab {
  if (!_titleLab) {
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont systemFontOfSize:28];
    _titleLab.textColor = [UIColor colorWithHexString:@"#222222"];
    _titleLab.text = @"你好, 欢迎登录";
  }
  return _titleLab;
}

- (UILabel *)areaLab {
  if (!_areaLab) {
    _areaLab = [[UILabel alloc] init];
    _areaLab.font = [UIFont systemFontOfSize:17];
    _areaLab.textColor = [UIColor colorWithHexString:@"#333333"];
    _areaLab.text = @"+86";
  }
  return _areaLab;
}

- (UIView *)verLine {
  if (!_verLine) {
    _verLine = [[UIView alloc] init];
    _verLine.backgroundColor = [UIColor colorWithHexString:@"#DCDFE5"];
  }
  return _verLine;
}

- (UITextField *)phoneNumField {
  if (!_phoneNumField) {
    _phoneNumField = [[UITextField alloc] init];
    _phoneNumField.placeholder = @"请输入手机号";
    _phoneNumField.font = [UIFont systemFontOfSize:17];
    _phoneNumField.textColor = [UIColor colorWithHexString:@"#333333"];
    _phoneNumField.delegate = self;
    _phoneNumField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneNumField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
  }
  return _phoneNumField;
}

- (UIView *)horLine {
  if (!_horLine) {
    _horLine = [[UIView alloc] init];
    _horLine.backgroundColor = [UIColor colorWithHexString:@"#DCDFE5"];
  }
  return _horLine;
}

- (UILabel *)tipLab {
  if (!_tipLab) {
    _tipLab = [[UILabel alloc] init];
    _tipLab.font = [UIFont systemFontOfSize:12];
    _tipLab.textColor = [UIColor colorWithHexString:@"#B0B6BE"];
    _tipLab.text = @"未注册的手机号验证通过后将自动注册";
  }
  return _tipLab;
}

- (UIButton *)getSmsBtn {
  if (!_getSmsBtn) {
    _getSmsBtn = [[UIButton alloc] init];
    _getSmsBtn.enabled = NO;
    [_getSmsBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getSmsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIColor *activeCol = [UIColor colorWithHexString:@"#337EFF"];
    [_getSmsBtn setBackgroundImage:[UIImage ne_imageWithColor:activeCol]
                          forState:UIControlStateNormal];
    UIColor *disableCol = [UIColor colorWithHexString:@"#cccccc"];
    [_getSmsBtn setBackgroundImage:[UIImage ne_imageWithColor:disableCol]
                          forState:UIControlStateDisabled];
    _getSmsBtn.layer.cornerRadius = 25;
    _getSmsBtn.layer.masksToBounds = YES;
    [_getSmsBtn addTarget:self
                   action:@selector(getSmsAction)
         forControlEvents:UIControlEventTouchUpInside];
  }
  return _getSmsBtn;
}

- (UITextView *)protocolView {
  if (!_protocolView) {
    _protocolView = [[UITextView alloc] init];
    _protocolView.textAlignment = NSTextAlignmentCenter;
    _protocolView.editable = NO;
    _protocolView.scrollEnabled = NO;
    _protocolView.backgroundColor = [UIColor whiteColor];
  }
  return _protocolView;
}

@end
