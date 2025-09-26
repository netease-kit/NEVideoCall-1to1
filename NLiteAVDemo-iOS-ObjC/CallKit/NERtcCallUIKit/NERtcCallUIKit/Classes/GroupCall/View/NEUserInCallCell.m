// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUserInCallCell.h"
#import <Masonry/Masonry.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import <NERtcSDK/NERtcSDK.h>
#import <SDWebImage/SDWebImage.h>
#import <YXAlog_iOS/YXAlog.h>
#import "NECallUIKitMacro.h"
#import "NEGroupUser.h"

@interface NEUserInCallCell ()

@property(nonatomic, strong) UIImageView *headerImage;

@property(nonatomic, strong) UILabel *nameLabel;

@property(nonatomic, strong) UILabel *connectingState;

@property(nonatomic, strong) NEGroupUser *user;

@property(nonatomic, strong) UIView *preview;

@property(nonatomic, strong) NERtcVideoCanvas *canvas;

@end

@implementation NEUserInCallCell

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

- (void)configure:(NEGroupUser *)user {
  // 设置头像
  [self.headerImage
      sd_setImageWithURL:[NSURL URLWithString:user.avatar]
        placeholderImage:[UIImage imageNamed:@"avator"
                                                  inBundle:[NSBundle bundleForClass:[NERtcCallUIKit
                                                                                        class]]
                             compatibleWithTraitCollection:nil]];
  self.nameLabel.text = user.nickname;

  // 设置连接状态
  if (user.state != GroupMemberStateWaitting) {
    self.connectingState.hidden = YES;
  } else {
    self.connectingState.hidden = NO;
  }

  // 判断当前用户是否为本地用户
  NSString *currentUserId = [NIMSDK.sharedSDK.v2LoginService getLoginUser];
  BOOL isLocalUser = [currentUserId isEqualToString:user.imAccid];

  if (user.isOpenVideo == YES && user.isShowLocalVideo == YES) {
    // 本地用户开启视频
    self.preview.hidden = NO;
    [[NERtcEngine sharedEngine] enableLocalVideo:YES];
    [NERtcEngine.sharedEngine setupLocalVideoCanvas:self.canvas];
    [NERtcEngine.sharedEngine startPreview];
    YXAlogInfo(@"[NEUserInCallCell] 本地视频预览开始: %@", user.imAccid);

  } else if (user.isOpenVideo == YES) {
    // 远程用户开启视频
    self.preview.hidden = NO;
    if (user.uid > 0) {
      [NERtcEngine.sharedEngine setupRemoteVideoCanvas:self.canvas forUserID:user.uid];
    }
    YXAlogInfo(@"[NEUserInCallCell] 远程视频订阅: userID=%llu, user=%@", user.uid, user.imAccid);

  } else {
    // 关闭视频
    if (isLocalUser) {
      // 本地用户关闭视频
      [NERtcEngine.sharedEngine setupLocalVideoCanvas:nil];
      [NERtcEngine.sharedEngine stopPreview];
      self.preview.hidden = YES;
      YXAlogInfo(@"[NEUserInCallCell] 本地视频预览停止: %@", user.imAccid);
    } else {
      // 远程用户关闭视频
      if (user.uid > 0) {
        [NERtcEngine.sharedEngine setupRemoteVideoCanvas:nil forUserID:user.uid];
      }
    }
  }
}

@end
