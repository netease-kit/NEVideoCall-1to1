//
//  NESearchResultCell.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NESearchResultCell.h"

@implementation NESearchResultCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.centerY.mas_equalTo(0);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconView.mas_right).offset(10);
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-10);
        }];
    }
    return self;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 6;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}
@end
