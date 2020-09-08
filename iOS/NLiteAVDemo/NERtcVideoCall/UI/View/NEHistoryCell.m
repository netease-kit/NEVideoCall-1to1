//
//  NEHistoryCell.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEHistoryCell.h"

@implementation NEHistoryCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.avator];
        [self.avator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}
- (UIImageView *)avator {
    if (!_avator) {
        _avator = [[UIImageView alloc] init];
        _avator.layer.cornerRadius = 6;
        _avator.clipsToBounds = YES;
    }
    return _avator;
}
@end
