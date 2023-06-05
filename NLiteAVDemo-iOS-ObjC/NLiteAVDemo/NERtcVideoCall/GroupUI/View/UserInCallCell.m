// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UserInCallCell.h"
#import "NSMacro.h"

@interface UserInCallCell ()

@property(nonatomic, strong) UIImageView *headerImage;

@property(nonatomic, strong) UILabel *nameLabel;

@property(nonatomic, strong) UILabel *connectingState;

@property(nonatomic, strong) NEUser *user;

@property(nonatomic, strong) UIView *preview;

@property(nonatomic, strong) NERtcVideoCanvas *canvas;

@end

@implementation UserInCallCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.contentView.backgroundColor = HEXCOLOR(0x292933);

  [self.contentView addSubview:self.headerImage];
  [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.contentView);
    make.width.height.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
  }];

  [self.contentView addSubview:self.connectingState];
  [self.connectingState mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.headerImage.mas_top).offset(-4);
    make.left.right.equalTo(self.contentView);
  }];

  [self.contentView addSubview:self.preview];
  [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.contentView);
  }];

  UIView *back = [[UIView alloc] init];
  [self.contentView addSubview:back];
  back.backgroundColor = HEXCOLORA(0x000000, 0.5);
  back.clipsToBounds = YES;
  back.layer.cornerRadius = 2.0;
  [back mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(4);
    make.bottom.equalTo(self.contentView).offset(-4);
  }];

  [back addSubview:self.nameLabel];
  [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(back).offset(4);
    make.bottom.right.equalTo(back).offset(-4);
  }];

  self.canvas.container = self.preview;
}

- (UIImageView *)headerImage {
  if (!_headerImage) {
    _headerImage = [[UIImageView alloc] init];
    _headerImage.clipsToBounds = YES;
    _headerImage.layer.cornerRadius = 2.0;
  }
  return _headerImage;
}

- (UILabel *)nameLabel {
  if (!_nameLabel) {
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.backgroundColor = [UIColor clearColor];  // HEXCOLORA(0x000000, 0.5);
    _nameLabel.clipsToBounds = YES;
    _nameLabel.layer.cornerRadius = 2.0;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.font = [UIFont systemFontOfSize:12.0];
  }
  return _nameLabel;
}

- (UILabel *)connectingState {
  if (!_connectingState) {
    _connectingState = [[UILabel alloc] init];
    _connectingState.text = @"待接听...";
    _connectingState.textColor = [UIColor whiteColor];
    _connectingState.font = [UIFont systemFontOfSize:13.0];
    _connectingState.textAlignment = NSTextAlignmentCenter;
  }
  return _connectingState;
}

- (NERtcVideoCanvas *)canvas {
  if (!_canvas) {
    _canvas = [[NERtcVideoCanvas alloc] init];
    _canvas.renderMode = kNERtcVideoRenderScaleCropFill;
  }
  return _canvas;
}

- (UIView *)preview {
  if (!_preview) {
    _preview = [[UIView alloc] init];
  }
  return _preview;
}

- (void)configure:(NEUser *)user {
  [self.headerImage sd_setImageWithURL:[NSURL URLWithString:user.avatar]];
  self.nameLabel.text = user.mobile;
  if (user.state != GroupMemberStateWaitting) {
    self.connectingState.hidden = YES;
  } else {
    self.connectingState.hidden = NO;
  }

  if (user.isOpenVideo == YES && user.isShowLocalVideo == YES) {
    self.preview.hidden = NO;
    [[NERtcEngine sharedEngine] enableLocalVideo:YES];
    [NERtcEngine.sharedEngine setupLocalVideoCanvas:self.canvas];
    [NERtcEngine.sharedEngine startPreview];
    NSLog(@"start preview : %@", self.preview);
  } else if (user.isOpenVideo == YES) {
    self.preview.hidden = NO;
    [NERtcEngine.sharedEngine setupRemoteVideoCanvas:self.canvas forUserID:user.uid];
    [NERtcEngine.sharedEngine subscribeRemoteVideo:YES
                                         forUserID:user.uid
                                        streamType:kNERtcRemoteVideoStreamTypeHigh];
  } else {
    if ([NIMSDK.sharedSDK.loginManager.currentAccount isEqualToString:user.imAccid]) {
      [NERtcEngine.sharedEngine setupLocalVideoCanvas:nil];
      [NERtcEngine.sharedEngine stopPreview];
      self.preview.hidden = YES;
      NSLog(@"stop preview : %@", self.preview);
    } else {
      [NERtcEngine.sharedEngine setupRemoteVideoCanvas:nil forUserID:user.uid];
    }
  }
}

@end
