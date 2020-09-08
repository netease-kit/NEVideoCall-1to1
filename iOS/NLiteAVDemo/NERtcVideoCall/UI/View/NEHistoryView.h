//
//  NEHistoryView.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEBaseUserListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEHistoryView : NEBaseUserListView<UICollectionViewDelegate,UICollectionViewDataSource>
@property(strong,nonatomic)UICollectionView *collectionView;
@end

NS_ASSUME_NONNULL_END
