//
//  NEBaseUserListView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEUser.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NEUserListViewDelegate <NSObject>
- (void)didSelectUser:(NEUser *)user;
@end

@interface NEBaseUserListView : UIView
@property(strong,nonatomic)UILabel *titleLabel;
@property(weak,nonatomic)id <NEUserListViewDelegate> delegate;
@property(strong,nonatomic)NSArray <NEUser *>*dataArray;
- (void)updateTitle:(NSString *)title dataArray:(NSArray <NEUser *>*)dataArray;
@end

NS_ASSUME_NONNULL_END
