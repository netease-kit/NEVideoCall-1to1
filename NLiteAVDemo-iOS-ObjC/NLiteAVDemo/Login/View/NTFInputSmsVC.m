// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NTFInputSmsVC.h"
#import "NEAccount.h"
#import "NECountDownButton.h"
#import "NELoginOptions.h"
#import "NENavigator.h"
#import "NESendSmsCodeTask.h"
#import "NEService.h"
#import "NSMacro.h"
#import "NTFSmsInputView.h"
#import "UIImage+NTES.h"
#import "UIView+NTES.h"

@interface NTFInputSmsVC () <NTFSmsInputViewDelegate, NECountDownButtonDelegate>

@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) UILabel *infoLab;
@property(nonatomic, strong) NTFSmsInputView *inputView;
@property(nonatomic, strong) NECountDownButton *countDownBtn;
@property(nonatomic, strong) UIButton *nextBtn;
@property(nonatomic, strong) UITextView *protocolView;
@property(nonatomic, copy) NSString *smsCode;

@property(nonatomic, copy) NSString *mobile;
@property(nonatomic, strong) NELoginOptions *options;
@property(nonatomic, assign) NSTimeInterval lastSmsTimestamp;
@property(nonatomic, assign) int32_t smsCount;

@end

@implementation NTFInputSmsVC

- (instancetype)initWithMobile:(NSString *)mobile options:(NELoginOptions *_Nullable)options {
  self = [super init];
  if (self) {
    _mobile = mobile;
    _options = options;
  }
  return self;
}

- (void)dealloc {
  [_countDownBtn releaseTimer];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loadin g the view.

  [self setupViews];
  [self.countDownBtn startCount];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:NO];
  //  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  //    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
}

/**
 *  custom code
 */

- (void)willEnterForeground {
  // 进入前台时,重置计时器
  if (_lastSmsTimestamp <= 0) {
    return;
  }

  NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
  int32_t tmp = current - _lastSmsTimestamp;
  int32_t diff = (tmp > 0) ? round(tmp) : round(-tmp);
  if (diff > _smsCount) {
    [self.countDownBtn stop];
    self.countDownBtn.enabled = YES;
    _lastSmsTimestamp = 0;
    _smsCount = 0;
  } else {
    [self.countDownBtn startWithCount:(_smsCount - diff)];
  }
}

- (void)didEnterBackground {
  // 进入后台停止计时器
  if (self.countDownBtn.counting) {
    return;
  }

  _lastSmsTimestamp = [[NSDate date] timeIntervalSince1970];
  _smsCount = self.countDownBtn.restCountNum;
  [self.countDownBtn stop];
}

- (void)setupViews {
  self.view.backgroundColor = [UIColor whiteColor];

  self.navigationController.navigationBar.translucent = NO;
  self.edgesForExtendedLayout = UIRectEdgeNone;
  UIView *backgroundView = [self.navigationController.navigationBar subviews].firstObject;
  UIView *navLine = backgroundView.subviews.firstObject;
  navLine.hidden = YES;

  self.navigationController.navigationBar.topItem.title = @"";

  [self.view addSubview:self.titleLab];
  [self.view addSubview:self.infoLab];
  [self.view addSubview:self.inputView];
  [self.view addSubview:self.countDownBtn];
  [self.view addSubview:self.nextBtn];
  [self.view addSubview:self.protocolView];

  self.titleLab.frame = CGRectMake(30, 16, self.view.width - 60, 40);
  self.infoLab.frame =
      CGRectMake(self.titleLab.left, self.titleLab.bottom + 8, self.titleLab.width, 44);
  self.inputView.frame = CGRectMake(60, self.infoLab.bottom + 30, self.view.width - 120, 48);
  self.countDownBtn.frame = CGRectMake(60, self.inputView.bottom + 14, self.view.width - 120, 40);
  self.nextBtn.frame =
      CGRectMake(self.titleLab.left, self.countDownBtn.bottom + 50, self.titleLab.width, 50);
  self.protocolView.frame =
      CGRectMake(self.titleLab.left, self.nextBtn.bottom + 30, self.titleLab.width, 30);

  self.protocolView.attributedText = [self protocolText];
  self.protocolView.textAlignment = NSTextAlignmentCenter;

  self.infoLab.attributedText = [self attrInfo:(_mobile ?: @"")];
  [self.inputView setupSubviews];

  UITapGestureRecognizer *tap =
      [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
  [self.view addGestureRecognizer:tap];
}

- (void)endEditing {
  [self.view endEditing:YES];
}

- (NSAttributedString *)attrInfo:(NSString *)mobile {
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.minimumLineHeight = 22;
  style.maximumLineHeight = 22;
  NSDictionary *attr = @{
    NSForegroundColorAttributeName : HEXCOLOR(0x333333),
    NSFontAttributeName : [UIFont systemFontOfSize:14],
    NSParagraphStyleAttributeName : style
  };
  NSString *str = [NSString stringWithFormat:@"验证码已发送至 +86-%@, 请在下方输入验证码", mobile];
  return [[NSAttributedString alloc] initWithString:str attributes:attr];
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

- (void)textFieldDidChange:(UITextField *)textField {
  BOOL valid = [self validSmsNum:textField.text];
  self.nextBtn.enabled = valid;
}

- (BOOL)validSmsNum:(NSString *)smsNum {
  NSString *validRegEx = @"^1[35789]\\d{9}$";
  NSPredicate *reg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validRegEx];
  return [reg evaluateWithObject:smsNum];
}

- (void)nextAction {
  if ([_mobile length] > 0 && [_smsCode length] > 0) {
    [NEAccount loginWithMobile:_mobile
                       smsCode:_smsCode
                    completion:^(NSDictionary *_Nullable data, NSError *_Nullable error) {
                      if (error) {
                        if (self.options.failedBlock) {
                          self.options.failedBlock();
                        }
                        NSString *msg = data[@"msg"] ?: @"请求错误";
                        [self.view ne_makeToast:msg];
                      } else {
                        if (self.options.successBlock) {
                          self.options.successBlock();
                        }
                        [[NENavigator shared] closeLoginWithCompletion:nil];
                        [self.view ne_makeToast:@"登录成功"];
                      }
                    }];
  } else {
    ntes_main_async_safe(^{
      [self.view ne_makeToast:@"参数不合法"];
    });
  }
}

- (NSAttributedString *)countDownTextWithSecond:(int32_t)second {
  NSString *secondStr = [NSString stringWithFormat:@"%ds", second];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
      initWithString:secondStr
          attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x2953FF)}];
  NSAttributedString *tmp = [[NSAttributedString alloc]
      initWithString:@" 后重新发送验证码"
          attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x333333)}];
  [attr appendAttributedString:tmp];

  return [attr copy];
  ;
}

#pragma mark - NECountDownButtonDelegate

- (void)clickCountButton:(NECountDownButton *)button {
  NESendSmsCodeTask *task = [NESendSmsCodeTask taskWithSubURL:@"/auth/sendLoginSmsCode"];
  task.req_mobile = _mobile;
  [[NEService shared] runTask:task
                   completion:^(NSDictionary *_Nullable data, NSError *_Nullable error) {
                     ntes_main_async_safe(^{
                       if (error) {
                         NSString *msg = [error localizedDescription] ?: @"请求错误";
                         [self.view ne_makeToast:msg];
                       } else {
                         [self.countDownBtn startCount];
                         [self.view ne_makeToast:@"验证码已发送,请注意查收"];
                       }
                     });
                   }];
}

- (NSAttributedString *)countingAttrTitleForButton:(NECountDownButton *)button
                                             count:(int32_t)count {
  NSAttributedString *text = [self countDownTextWithSecond:count];
  return text;
}

- (void)endCountWithButton:(NECountDownButton *)button {
  NSAttributedString *text = [[NSAttributedString alloc]
      initWithString:@"重新发送"
          attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x2953FF)}];
  button.titleLabel.attributedText = text;
}

#pragma mark - NTFSmsInputViewDelegate

- (void)inputViewDidChanged:(NTFSmsInputView *)inputView content:(NSString *)content {
  if (inputView != self.inputView) {
    return;
  }
  _smsCode = content;
  BOOL enable = NO;
  if ([content length] == inputView.maxLenght) {
    enable = YES;
  }
  self.nextBtn.enabled = enable;
}

#pragma mark - lazy method

- (UILabel *)titleLab {
  if (!_titleLab) {
    _titleLab = [[UILabel alloc] init];
    _titleLab.font = [UIFont systemFontOfSize:28];
    _titleLab.textColor = HEXCOLOR(0x222222);
    _titleLab.text = @"请输入验证码";
  }
  return _titleLab;
}

- (UILabel *)infoLab {
  if (!_infoLab) {
    _infoLab = [[UILabel alloc] init];
    _infoLab.numberOfLines = 2;
  }
  return _infoLab;
}

- (NTFSmsInputView *)inputView {
  if (!_inputView) {
    _inputView = [[NTFSmsInputView alloc] init];
    _inputView.maxLenght = 4;
    _inputView.borderColor = HEXCOLOR(0xcccccc);
    _inputView.highlightBorderColor = HEXCOLOR(0x337EFF);
    _inputView.cornerRadius = 12;
    _inputView.keyBoardType = UIKeyboardTypeNumberPad;
    _inputView.delegate = self;
  }
  return _inputView;
}

- (NECountDownButton *)countDownBtn {
  if (!_countDownBtn) {
    NSAttributedString *text = [[NSAttributedString alloc]
        initWithString:@"重新发送"
            attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x2953FF)}];
    ;
    _countDownBtn = [[NECountDownButton alloc] initWithAttributeTitle:text];
    _countDownBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _countDownBtn.delegate = self;
  }
  return _countDownBtn;
}

- (UIButton *)nextBtn {
  if (!_nextBtn) {
    _nextBtn = [[UIButton alloc] init];
    _nextBtn.enabled = NO;
    [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIColor *activeCol = HEXCOLOR(0x337EFF);
    [_nextBtn setBackgroundImage:[UIImage ne_imageWithColor:activeCol]
                        forState:UIControlStateNormal];
    UIColor *disableCol = HEXCOLOR(0xcccccc);
    [_nextBtn setBackgroundImage:[UIImage ne_imageWithColor:disableCol]
                        forState:UIControlStateDisabled];
    _nextBtn.layer.cornerRadius = 25;
    _nextBtn.layer.masksToBounds = YES;
    [_nextBtn addTarget:self
                  action:@selector(nextAction)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _nextBtn;
}

- (UITextView *)protocolView {
  if (!_protocolView) {
    _protocolView = [[UITextView alloc] init];
    _protocolView.textAlignment = NSTextAlignmentCenter;
    _protocolView.editable = NO;
    _protocolView.backgroundColor = [UIColor whiteColor];
    _protocolView.scrollEnabled = NO;
  }
  return _protocolView;
}

@end
