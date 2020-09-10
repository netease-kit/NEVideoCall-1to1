//
//  NECountDownButton.m
//  NLiteAVDemo
//
//  Created by Think on 2020/8/28.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NECountDownButton.h"

const int32_t defaultCount = 60;

@interface NECountDownButton ()

@property (nonatomic, strong)   NSTimer     *timer;
@property (nonatomic, copy)     NSAttributedString    *attributeTitle;

@property (nonatomic, assign, readwrite) BOOL    counting;
@property (nonatomic, assign, readwrite) int32_t restCountNum;

@end

@implementation NECountDownButton

- (instancetype)initWithAttributeTitle:(NSAttributedString *)attributeTitle
{
    self = [super init];
    if (self) {
        _attributeTitle = attributeTitle;
        
        [self setAttributedTitle:_attributeTitle forState:UIControlStateNormal];
        [self setAttributedTitle:_attributeTitle forState:UIControlStateDisabled];
        [self addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setCounting:(BOOL)counting
{
    if (_counting == counting) { return; }
    _counting = counting;
}

- (void)setEnabled:(BOOL)enabled
{
    if (_counting) { return; }
    [super setEnabled:enabled];
}

- (void)clickBtn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCountButton:)]) {
        [self.delegate clickCountButton:self];
    }
}

- (void)startCount
{
    [self startWithCount:0];
}

- (void)startWithCount:(int32_t)count
{
    if (count <= 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(countNumForButton:)]) {
            _restCountNum = [self.delegate countNumForButton:self];
        }
        if (_restCountNum <= 0) { _restCountNum = defaultCount; }
    } else {
        _restCountNum = count;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(startCountWithButton:)]) {
        [self.delegate startCountWithButton:self];
    }
    
    if (_timer) { [self releaseTimer]; }
    
    // order is important
    self.enabled = NO;
    self.counting = YES;
    
    [self refreshButton];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshButton) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    [self releaseTimer];
    self.counting = NO;
    
    [self _setTitleForState:UIControlStateNormal];
    [self _setTitleForState:UIControlStateDisabled];
}

- (void)refreshButton
{
    _restCountNum--;
    
    if ([self.delegate respondsToSelector:@selector(countingAttrTitleForButton:count:)]) {
        NSAttributedString *title = [self.delegate countingAttrTitleForButton:self count:_restCountNum];
        [self setAttributedTitle:title forState:UIControlStateDisabled];
    }
    
    if (_restCountNum <= 0) {
        [self releaseTimer];
        
        // order is important
        self.counting = NO;
        self.enabled = YES;
        [self _setTitleForState:UIControlStateDisabled];
        
        if ([self.delegate respondsToSelector:@selector(endCountWithButton:)]) {
            [self.delegate endCountWithButton:self];
        }
    }
}

- (void)releaseTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)_setTitleForState:(UIControlState)state
{
    [self setAttributedTitle:_attributeTitle forState:state];
}

@end
