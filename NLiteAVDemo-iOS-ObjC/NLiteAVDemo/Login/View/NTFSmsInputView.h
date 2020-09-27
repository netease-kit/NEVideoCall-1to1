//
//  NTFSmsInputView.h
//  NIMAudioChatroom
//
//  Created by Think on 2020/8/18.
//  Copyright © 2020 netease. All rights reserved.
//

/**
 验证码输入视图
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NTFSmsInputView;

@protocol NTFSmsInputViewDelegate <NSObject>

@optional
- (void)inputViewDidChanged:(NTFSmsInputView *)inputView content:(NSString *)content;

@end

@interface NTFSmsInputView : UIView

@property (nonatomic, assign)   UIKeyboardType          keyBoardType;
@property (nonatomic, weak)     id<NTFSmsInputViewDelegate> delegate;
@property (nonatomic, assign)   NSInteger               maxLenght;
@property (nonatomic, strong)   UIColor                 *borderColor;
@property (nonatomic, strong)   UIColor                 *highlightBorderColor;
@property (nonatomic, assign)   CGFloat                 cornerRadius;

- (void)setupSubviews;

@end

NS_ASSUME_NONNULL_END
