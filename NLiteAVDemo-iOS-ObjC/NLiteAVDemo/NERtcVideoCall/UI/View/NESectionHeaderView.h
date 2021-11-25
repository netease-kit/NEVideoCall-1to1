//
//  NESectionHeaderView.h
//  NLiteAVDemo
//
//  Created by yu chen on 2021/10/18.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NESectionHeaderView : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *contentLabel;
@property(nonatomic, strong) UIView *dividerLine;

+ (CGFloat)hasContentHeight;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
