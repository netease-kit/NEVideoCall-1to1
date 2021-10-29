//
//  NESearchResultCell.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEExpandButton.h"
#import "NEUser.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SearchCellDelegate <NSObject>

- (void)didSelectSearchUser:(NEUser *)user;

@end

@interface NESearchResultCell : UITableViewCell

@property(nonatomic, weak) id<SearchCellDelegate> delegate;

- (void)configureUI:(NEUser *)user;

@end

NS_ASSUME_NONNULL_END
