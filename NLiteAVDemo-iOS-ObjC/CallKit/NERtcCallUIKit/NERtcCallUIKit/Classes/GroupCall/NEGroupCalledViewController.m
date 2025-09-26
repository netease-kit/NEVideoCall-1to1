// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupCalledViewController.h"
#import <Masonry/Masonry.h>
#import "NEGroupUserController.h"
// #import <NERtcSDK/NERtcSDK.h>
#import <SDWebImage/SDWebImage.h>
#import "NECallUIKitMacro.h"
#import "NECustomButton.h"

@interface NEGroupCalledViewController ()

@property(nonatomic, strong) NEGroupUser *caller;

@property(nonatomic, strong) UIImageView *bgImageView;
/// 拒绝接听
@property(nonatomic, strong) NECustomButton *rejectBtn;
/// 接听
@property(nonatomic, strong) NECustomButton *acceptBtn;

@property(nonatomic, strong) UIImageView *callerImageView;

@property(nonatomic, strong) UILabel *callerNameLabel;

@property(nonatomic, strong) UILabel *centerSubtitleLabel;

@property(nonatomic, strong) UILabel *membersCountLabel;

@property(nonatomic, assign) CGFloat radius;
@property(nonatomic, assign) CGFloat titleFontSize;
@property(nonatomic, assign) CGFloat subTitleFontSize;
@property(nonatomic, assign) CGFloat factor;
@property(nonatomic, assign) int timerCount;
@property(nonatomic, strong) NEGroupUserController *userController;

@end

@implementation NEGroupCalledViewController

- (instancetype)initWithCaller:(NEGroupUser *)caller {
  self = [super init];
  if (self) {
    self.caller = caller;
    self.factor = 1;
    self.radius = 4.0;
    self.titleFontSize = 20.0;
    self.subTitleFontSize = 14.0;
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
  [self setupUI];
}

- (void)setupUI {
  [self.view addSubview:self.bgImageView];
  [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];

  UIToolbar *toolbar = [[UIToolbar alloc] init];
  toolbar.barStyle = UIBarStyleBlackOpaque;
  [self.view addSubview:toolbar];
  [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
  }];

  CGSize buttonSize = CGSizeMake(75, 103);

  [self.view addSubview:self.callerImageView];
  [self.callerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(90, 90));
    make.top.equalTo(self.view).offset(136 * self.factor);
    make.centerX.equalTo(self.view);
  }];

  [self.view addSubview:self.callerNameLabel];
  [self.callerNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.callerImageView.mas_bottom).offset(10 * self.factor);
    make.right.left.equalTo(self.view);
  }];

  [self.view addSubview:self.centerSubtitleLabel];
  [self.centerSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.callerNameLabel.mas_bottom).offset(10 * self.factor);
    make.right.left.equalTo(self.view);
  }];

  [self.view addSubview:self.membersCountLabel];
  [self.membersCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.centerSubtitleLabel.mas_bottom).offset(10 * self.factor);
    make.right.left.equalTo(self.view);
  }];

  [self.view addSubview:self.userController.view];
  [self.userController.view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.view);
    make.top.equalTo(self.membersCountLabel.mas_bottom);
    make.height.mas_equalTo(90);
  }];

  /// 接听和拒接按钮
  [self.view addSubview:self.rejectBtn];
  [self.rejectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(-self.view.frame.size.width / 4.0);
    make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
    make.size.mas_equalTo(buttonSize);
  }];

  [self.view addSubview:self.acceptBtn];
  [self.acceptBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(self.view.frame.size.width / 4.0);
    make.bottom.mas_equalTo(self.view.mas_bottom).offset(-80 * self.factor);
    make.size.mas_equalTo(buttonSize);
  }];

  [self.bgImageView
      sd_setImageWithURL:[NSURL URLWithString:nil]
        placeholderImage:[UIImage imageNamed:@"avator"
                                                  inBundle:[NSBundle bundleForClass:[NERtcCallUIKit
                                                                                        class]]
                             compatibleWithTraitCollection:nil]];
  [self.callerImageView
      sd_setImageWithURL:[NSURL URLWithString:self.caller.avatar]
        placeholderImage:[UIImage imageNamed:@"avator"
                                                  inBundle:[NSBundle bundleForClass:[NERtcCallUIKit
                                                                                        class]]
                             compatibleWithTraitCollection:nil]];
  self.callerNameLabel.text = self.caller.nickname;
}

- (void)removeSelf {
  [self removeFromParentViewController];
  [self.view removeFromSuperview];
}

- (void)changeUsers:(NSArray<NEGroupUser *> *)users {
  [self.userController removeAllUsers];
  [self.userController addUsers:users];
  if ([self.userController getAllUsers].count > 0) {
    self.membersCountLabel.text =
        [NSString stringWithFormat:@"还有%lu人参与通话", [self.userController getAllUsers].count];
    self.userController.view.hidden = NO;
  } else {
    self.userController.view.hidden = YES;
  }
}

#pragma mark - action

- (void)rejectEvent:(NECustomButton *)button {
  if (self.delegate && [self.delegate respondsToSelector:@selector(calledDidReject)]) {
    [self.delegate calledDidReject];
  }
}

- (void)acceptEvent:(NECustomButton *)button {
  if (self.delegate && [self.delegate respondsToSelector:@selector(calledDidAccept)]) {
    [self.delegate calledDidAccept];
  }
}

#pragma mark - lazy init

- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] init];
    _bgImageView.userInteractionEnabled = YES;
  }
  return _bgImageView;
}

- (NEGroupUserController *)userController {
  if (!_userController) {
    _userController = [[NEGroupUserController alloc] init];
    _userController.disableCancelUser = YES;
    _userController.hideHeaderSection = YES;
  }
  return _userController;
}

- (NECustomButton *)rejectBtn {
  if (!_rejectBtn) {
    _rejectBtn = [[NECustomButton alloc] init];
    _rejectBtn.titleLabel.text = @"拒绝";
    _rejectBtn.imageView.image =
        [UIImage imageNamed:@"call_cancel"
                                 inBundle:[NSBundle bundleForClass:[NERtcCallUIKit class]]
            compatibleWithTraitCollection:nil];
    [_rejectBtn.maskBtn addTarget:self
                           action:@selector(rejectEvent:)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _rejectBtn;
}

- (NECustomButton *)acceptBtn {
  if (!_acceptBtn) {
    _acceptBtn = [[NECustomButton alloc] init];
    _acceptBtn.titleLabel.text = @"接听";
    _acceptBtn.imageView.image =
        [UIImage imageNamed:@"call_accept"
                                 inBundle:[NSBundle bundleForClass:[NERtcCallUIKit class]]
            compatibleWithTraitCollection:nil];
    _acceptBtn.imageView.contentMode = UIViewContentModeCenter;
    _acceptBtn.accessibilityIdentifier = @"accept";
    [_acceptBtn.maskBtn addTarget:self
                           action:@selector(acceptEvent:)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _acceptBtn;
}

- (UILabel *)callerNameLabel {
  if (nil == _callerNameLabel) {
    _callerNameLabel = [[UILabel alloc] init];
    _callerNameLabel.textColor = [UIColor whiteColor];
    _callerNameLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
    _callerNameLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _callerNameLabel;
}

- (UIImageView *)callerImageView {
  if (nil == _callerImageView) {
    _callerImageView = [[UIImageView alloc] init];
    _callerImageView.image = [UIImage imageNamed:@"avator"
                                        inBundle:[NSBundle bundleForClass:[NERtcCallUIKit class]]
                   compatibleWithTraitCollection:nil];
    _callerImageView.clipsToBounds = YES;
    _callerImageView.layer.cornerRadius = self.radius;
  }
  return _callerImageView;
}

- (UILabel *)centerSubtitleLabel {
  if (nil == _centerSubtitleLabel) {
    _centerSubtitleLabel = [[UILabel alloc] init];
    _centerSubtitleLabel.textColor = [UIColor whiteColor];
    _centerSubtitleLabel.font = [UIFont systemFontOfSize:self.subTitleFontSize];
    _centerSubtitleLabel.text = @"邀请您加入多人通话……";
    _centerSubtitleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _centerSubtitleLabel;
}

- (UILabel *)membersCountLabel {
  if (!_membersCountLabel) {
    _membersCountLabel = [[UILabel alloc] init];
    _membersCountLabel.textColor = [UIColor whiteColor];
    _membersCountLabel.font = [UIFont systemFontOfSize:self.subTitleFontSize];
    _membersCountLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _membersCountLabel;
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

@end
