// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECustomButton.h"

@implementation NECustomButton
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    //    [self setAccessibilityTraits:UIAccessibilityTraitButton|UIAccessibilityTraitSelected];
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.maskBtn];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.left.right.mas_equalTo(0);
      make.size.mas_equalTo(CGSizeMake(75, 75));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      // make.left.right.mas_equalTo(0);
      make.left.mas_equalTo(-40);
      make.right.mas_equalTo(40);
      make.top.mas_equalTo(self.imageView.mas_bottom).offset(8);
      make.bottom.mas_equalTo(0);
    }];

    [self.maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];

    //      self.selected = NO;
    //      NSLog(@"custom button select : %d", self.selected);
  }
  return self;
}

- (UIImageView *)imageView {
  if (!_imageView) {
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = NO;
    _imageView.contentMode = UIViewContentModeCenter;
  }
  return _imageView;
}
- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _titleLabel;
}

- (UIButton *)maskBtn {
  if (!_maskBtn) {
    _maskBtn = [[UIButton alloc] init];
    _maskBtn.backgroundColor = [UIColor clearColor];
  }
  return _maskBtn;
}
@end
