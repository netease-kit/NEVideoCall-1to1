//
//  NECallStatusRecordCell.h
//  NLiteAVDemo
//
//  Created by chenyu on 2021/10/14.
//  Copyright © 2021 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NECallStatusRecordModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallStatusRecordCell : UITableViewCell

- (void)configure:(NECallStatusRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
