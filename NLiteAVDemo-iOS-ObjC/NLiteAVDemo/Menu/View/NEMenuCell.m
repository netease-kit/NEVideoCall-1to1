// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEMenuCell.h"

@implementation NEMenuCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self initUI];
  }
  return self;
}
- (void)initUI {
  NSInteger padding = 20;
  NSInteger arrowLeft = 14;

  CGFloat width = [UIScreen mainScreen].bounds.size.width;
  if (width <= 320) {
    padding = 10;
    arrowLeft = 4;
  }
  self.backgroundColor = [UIColor clearColor];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  UIView *bgView = [[UIView alloc] init];
  bgView.layer.cornerRadius = 16;
  bgView.backgroundColor = [UIColor colorWithRed:50 / 255.0
                                           green:55 / 255.0
                                            blue:89 / 255.0
                                           alpha:1.0];
  [self.contentView addSubview:bgView];
  [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsMake(8, padding, 8, padding));
  }];

  [bgView addSubview:self.iconView];
  [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(bgView.mas_left).offset(24);
    make.centerY.mas_equalTo(0);
    make.size.mas_equalTo(CGSizeMake(48, 48));
  }];

  [bgView addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(0);
    make.left.mas_equalTo(self.iconView.mas_right).offset(14);
    make.height.mas_equalTo(25);
  }];

  UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_arrow"]];
  arrow.contentMode = UIViewContentModeCenter;
  [bgView addSubview:arrow];
  [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-arrowLeft);
    make.centerY.mas_equalTo(0);
    make.size.mas_equalTo(CGSizeMake(20, 20));
  }];
}

- (UIImageView *)iconView {
  if (!_iconView) {
    _iconView = [[UIImageView alloc] init];
  }
  return _iconView;
}
- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"一对一音视频通话";
  }
  return _titleLabel;
}
@end
