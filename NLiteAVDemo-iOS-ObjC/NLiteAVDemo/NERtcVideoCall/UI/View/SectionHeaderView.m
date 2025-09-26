// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "SectionHeaderView.h"
#import "NSMacro.h"

@implementation SectionHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  [self addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(14);
    make.left.mas_equalTo(20);
  }];

  [self addSubview:self.contentLabel];
  [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.titleLabel);
    make.top.equalTo(self.titleLabel.mas_bottom).offset(14);
  }];
  [self.contentLabel setHidden:YES];

  [self addSubview:self.dividerLine];
  [self.dividerLine mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.right.mas_equalTo(0);
    make.top.mas_equalTo(4);
    make.height.mas_equalTo(0.5);
  }];
  [self.dividerLine setHidden:YES];
}

- (UILabel *)titleLabel {
  if (nil == _titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = HEXCOLOR(0xCCCCCC);
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.font = [UIFont systemFontOfSize:14.0];
  }
  return _titleLabel;
}

- (UILabel *)contentLabel {
  if (nil == _contentLabel) {
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.font = [UIFont systemFontOfSize:14.0];
    _contentLabel.textColor = HEXCOLORA(0xCCCCCC, 0.5);
  }
  return _contentLabel;
}

+ (CGFloat)hasContentHeight {
  return 70.0;
}

+ (CGFloat)height {
  return 30.0;
}

- (UIView *)dividerLine {
  if (nil == _dividerLine) {
    _dividerLine = [[UIView alloc] init];
    _dividerLine.backgroundColor = HEXCOLORA(0xFFFFFF, 0.1);
  }
  return _dividerLine;
}

@end
