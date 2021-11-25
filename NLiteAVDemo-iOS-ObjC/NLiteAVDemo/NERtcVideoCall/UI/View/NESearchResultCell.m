//
//  NESearchResultCell.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NESearchResultCell.h"
#import "NSMacro.h"

@interface NESearchResultCell ()

@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) NEExpandButton *callBtn;
@property(nonatomic, strong) NEUser *user;

@end

@implementation NESearchResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.callBtn];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.size.mas_equalTo(CGSizeMake(28, 28));
            make.centerY.mas_equalTo(0);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconView.mas_right).offset(10);
            make.centerY.mas_equalTo(0);
            make.right.mas_equalTo(-10);
        }];
        [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-20);
            make.width.mas_equalTo(48);
            make.height.mas_equalTo(28);
        }];
        self.callBtn.enabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (NEExpandButton *)callBtn {
    if (nil == _callBtn) {
        _callBtn = [NEExpandButton buttonWithType:UIButtonTypeCustom];
        [_callBtn setTitle:@"呼叫" forState:UIControlStateNormal];
        [_callBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _callBtn.layer.borderWidth = 1;
        _callBtn.layer.cornerRadius = 2;
        _callBtn.layer.borderColor = HEXCOLORA(0xFFFFFF, 0.2).CGColor;
        [_callBtn addTarget:self action:@selector(callClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callBtn;
}

- (void)configureUI:(NEUser *)user {
    self.user = user;
    self.titleLabel.text = user.mobile;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
}

- (void)callClick {
    if ([self.delegate respondsToSelector:@selector(didSelectSearchUser:)]) {
        [self.delegate didSelectSearchUser:self.user];
    }
}
@end
