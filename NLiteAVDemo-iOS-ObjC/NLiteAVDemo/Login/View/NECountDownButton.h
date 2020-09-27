//
//  NECountDownButton.h
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

/**
 倒计时按钮
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NECountDownButton;

/**
 倒计时按钮协议
 */
@protocol NECountDownButtonDelegate <NSObject>

- (void)clickCountButton:(NECountDownButton *)button;

@optional

- (int32_t)countNumForButton:(NECountDownButton *)button;

- (void)startCountWithButton:(NECountDownButton *)button;

- (NSAttributedString *)countingAttrTitleForButton:(NECountDownButton *)button count:(int32_t)count;

- (void)endCountWithButton:(NECountDownButton *)button;

@end

@interface NECountDownButton : UIButton

@property (nonatomic, weak) id<NECountDownButtonDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL    counting;
@property (nonatomic, assign, readonly) int32_t restCountNum;

- (instancetype)initWithAttributeTitle:(NSAttributedString *)attributeTitle;

- (void)startCount;

- (void)startWithCount:(int32_t)count;

- (void)stop;

- (void)releaseTimer;

@end

NS_ASSUME_NONNULL_END
