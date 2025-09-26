// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVideoView.h"

@implementation NEVideoView
- (instancetype)init {
  self = [super init];
  if (self) {
    [self addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];
  }
  return self;
}
- (UIView *)videoView {
  if (!_videoView) {
    _videoView = [[UIView alloc] init];
  }
  return _videoView;
}
- (UIView *)maskView {
  if (!_maskView) {
    _maskView = [[UIView alloc] init];
    _maskView.backgroundColor = [UIColor darkGrayColor];
    _maskView.hidden = YES;
  }
  return _maskView;
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel.numberOfLines = 0;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _titleLabel;
}

- (UIImageView *)imageView {
  if (_imageView == nil) {
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
  }
  return _imageView;
}
@end
