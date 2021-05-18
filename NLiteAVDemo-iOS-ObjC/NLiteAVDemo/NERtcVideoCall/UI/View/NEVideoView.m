//
//  NEVideoView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/26.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEVideoView.h"

@implementation NEVideoView
- (instancetype)init
{
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
@end
