//
//  NTFSmsInputView.m
//  NIMAudioChatroom
//
//  Created by Think on 2020/8/18.
//  Copyright © 2020 netease. All rights reserved.
//

#import "NTFSmsInputView.h"

@interface NTFSmsInputView () <UITextViewDelegate>

@property (nonatomic, strong) UIView            *contairView;
@property (nonatomic, strong) UITextField       *textField;
@property (nonatomic, strong) NSMutableArray    *viewArr;
@property (nonatomic, strong) NSMutableArray    *labelArr;
@property (nonatomic, strong) NSMutableArray    *pointLineArr;

@end

@implementation NTFSmsInputView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxLenght = 4;
        _borderColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1];
        _highlightBorderColor = [UIColor colorWithRed:255/255.0 green:70/255.0 blue:62/255.0 alpha:1];
        _cornerRadius = 4;
        self.backgroundColor = [UIColor clearColor];
        [self.textField becomeFirstResponder];
    }
    return self;
}

- (void)setupSubviews
{
    if (_maxLenght <= 0) {
        return;
    }
    if (_contairView) {
        [_contairView removeFromSuperview];
    }
    _contairView  = [UIView new];
    _contairView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contairView];
    _contairView.frame = self.bounds;
    
    [_contairView addSubview:self.textField];
    self.textField.frame = _contairView.bounds;
    
    CGFloat padding = (CGRectGetWidth(self.frame) - _maxLenght * CGRectGetHeight(self.frame)) / (_maxLenght - 1);
    UIView *lastView;
    for (int i = 0; i < self.maxLenght; i++) {
        UIView *subView = [UIView new];
        subView.backgroundColor = [UIColor whiteColor];
        subView.layer.cornerRadius = _cornerRadius;
        subView.layer.borderWidth = (0.5);
        subView.userInteractionEnabled = NO;
        [_contairView addSubview:subView];
        
        CGFloat leftOffset = 0;
        if (lastView) {
            leftOffset = lastView.frame.origin.x + lastView.frame.size.width + padding;
        }
        subView.frame = CGRectMake(leftOffset, 0, CGRectGetHeight(_contairView.frame), CGRectGetHeight(_contairView.frame));
        
        UILabel *subLabel = [UILabel new];
        subLabel.font = [UIFont systemFontOfSize:38];
        subLabel.textColor = [UIColor darkGrayColor];
        [subView addSubview:subLabel];
        subLabel.frame = subView.bounds;
        subLabel.textAlignment = NSTextAlignmentCenter;
        lastView = subView;
        
        CGRect rect = CGRectMake((CGRectGetHeight(self.frame) - 2) / 2.0, 5, 2, (CGRectGetHeight(self.frame) - 10));
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        CAShapeLayer *line = [CAShapeLayer layer];
        line.path = path.CGPath;
        line.fillColor =  _borderColor.CGColor;
        [subView.layer addSublayer:line];
        if (i == 0) {
            [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
            line.hidden = NO;
            subView.layer.borderColor = _highlightBorderColor.CGColor;
        } else {
            line.hidden = YES;
            subView.layer.borderColor = _borderColor.CGColor;
        }
        [self.viewArr addObject:subView];
        [self.labelArr addObject:subLabel];
        [self.pointLineArr addObject:line];
    }
    
    CGFloat rightVal = 0;
    if (lastView) {
        rightVal = lastView.frame.origin.x + lastView.frame.size.width;
    }
    CGRect frame = _contairView.frame;
    frame.origin.x = rightVal - frame.size.width;
    _contairView.frame = frame;
}

- (void)textFieldDidChanged:(UITextField *)textField
{
    NSString *verStr = textField.text;
    verStr = [verStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (verStr.length >= _maxLenght) {
        verStr = [verStr substringToIndex:_maxLenght];
        [self.textField resignFirstResponder];
    }
    textField.text = verStr;

    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewDidChanged:content:)]) {
        [self.delegate inputViewDidChanged:self content:verStr];
    }

    for (int i= 0; i < self.viewArr.count; i++) {
        UILabel *label = self.labelArr[i];
        if (i<verStr.length) {
            [self changeViewLayerIndex:i pointHidden:YES];
            label.text = [verStr substringWithRange:NSMakeRange(i, 1)];
        } else {
            [self changeViewLayerIndex:i pointHidden:i==verStr.length?NO:YES];
            if (!verStr && verStr.length == 0) {
                [self changeViewLayerIndex:0 pointHidden:NO];
            }
            label.text = @"";
        }
    }
}

- (void)changeViewLayerIndex:(NSInteger)index pointHidden:(BOOL)hidden
{
    UIView *view = self.viewArr[index];
    view.layer.borderColor = hidden ? _borderColor.CGColor : _highlightBorderColor.CGColor;
    CAShapeLayer *line =self.pointLineArr[index];
    if (hidden) {
        [line removeAnimationForKey:@"kOpacityAnimation"];
    } else {
        [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
    }
    line.hidden = hidden;
}

- (CABasicAnimation *)opacityAnimation
{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.9;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return opacityAnimation;
}

#pragma mark -- getter & setter

- (void)setMaxLenght:(NSInteger)maxLenght
{
    _maxLenght = maxLenght;
}

- (void)setKeyBoardType:(UIKeyboardType)keyBoardType
{
    _keyBoardType = keyBoardType;
    self.textField.keyboardType = keyBoardType;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
}

- (void)setHighlightBorderColor:(UIColor *)highlightBorderColor
{
    _highlightBorderColor = highlightBorderColor;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.tintColor = [UIColor clearColor];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor clearColor];
        _textField.keyboardType = UIKeyboardTypeDefault;
        if (@available(iOS 12.0, *)) {
            _textField.textContentType = UITextContentTypeOneTimeCode;
        }
        [_textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

-(NSMutableArray *)pointLineArr
{
    if (!_pointLineArr) {
        _pointLineArr = [NSMutableArray new];
    }
    return _pointLineArr;
}
-(NSMutableArray *)viewArr
{
    if (!_viewArr) {
        _viewArr = [NSMutableArray new];
    }
    return _viewArr;
}
-(NSMutableArray *)labelArr
{
    if (!_labelArr) {
        _labelArr = [NSMutableArray new];
    }
    return _labelArr;
}

@end
