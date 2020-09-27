//
//  NEVideoOperationView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/25.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEVideoOperationView.h"

@implementation NEVideoOperationView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:39/255.0 green:48/255.0 blue:48/255.0 alpha:1.0];
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.microPhone,self.cameraBtn,self.hangupBtn]];
    stackView.distribution = UIStackViewDistributionFillEqually;
    
    [self addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 30, 0, 30));
    }];
}
- (UIButton *)microPhone {
    if (!_microPhone) {
        _microPhone = [UIButton buttonWithType:UIButtonTypeCustom];
        [_microPhone setImage:[UIImage imageNamed:@"call_voice_on"] forState:UIControlStateNormal];
        [_microPhone setImage:[UIImage imageNamed:@"call_voice_off"] forState:UIControlStateSelected];
    }
    return _microPhone;
}
- (UIButton *)cameraBtn {
    if (!_cameraBtn) {
        _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraBtn setImage:[UIImage imageNamed:@"call_camera_on"] forState:UIControlStateNormal];
        [_cameraBtn setImage:[UIImage imageNamed:@"call_camera_off"] forState:UIControlStateSelected];
    }
    return _cameraBtn;
}
- (UIButton *)hangupBtn {
    if (!_hangupBtn) {
        _hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hangupBtn setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
    }
    return _hangupBtn;
}

@end
