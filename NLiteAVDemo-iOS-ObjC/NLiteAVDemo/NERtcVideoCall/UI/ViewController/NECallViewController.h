//
//  NECallViewController.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/21.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NEUser.h"
#import <NERtcCallKit/NERtcCallKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NECallViewController : UIViewController<NERtcCallKitDelegate>
@property(assign,nonatomic)NERtcCallStatus status;
@property(strong,nonatomic)NEUser *remoteUser;
@property(strong,nonatomic)NEUser *localUser;
@end

NS_ASSUME_NONNULL_END
