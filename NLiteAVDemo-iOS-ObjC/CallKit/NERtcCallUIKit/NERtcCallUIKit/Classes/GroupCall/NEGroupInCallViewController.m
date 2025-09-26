// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupInCallViewController.h"
#import <YXAlog_iOS/YXAlog.h>
#import "NEGroupCallFlowLayout.h"
#import "NEGroupUser+Private.h"
#import "NEUserInCallCell.h"

@interface NEGroupInCallViewController () <UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collection;

@property(nonatomic, strong) NSMutableArray<NEGroupUser *> *datas;

@property(nonatomic, strong) NEGroupCallFlowLayout *layout;

@end

@implementation NEGroupInCallViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.datas = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self setupUI];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
}

- (void)setupUI {
  [self.view addSubview:self.collection];
  self.collection.frame =
      CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40);
  [self.collection registerClass:[NEUserInCallCell class]
      forCellWithReuseIdentifier:NSStringFromClass(NEUserInCallCell.class)];
  self.collection.backgroundColor = [UIColor blackColor];
  self.view.backgroundColor = [UIColor blackColor];
}

- (void)changeUsers:(NSArray<NSArray<NEGroupUser *> *> *)users {
  YXAlogInfo(@"[GroupCallLayout] 🔄 changeUsers 被调用，输入数据: %@", users);

  // 记录之前的人数
  NSInteger previousCount = self.datas.count;

  [self.datas removeAllObjects];

  // 将二维数组转换为一维数组，并设置原始位置
  NSInteger currentIndex = 0;
  for (NSArray<NEGroupUser *> *userGroup in users) {
    YXAlogInfo(@"[GroupCallLayout] 📦 处理用户组: %@", userGroup);
    for (NEGroupUser *user in userGroup) {
      // 设置用户的原始位置索引
      user.originalIndex = currentIndex;
      YXAlogInfo(@"[GroupCallLayout] 👤 用户详情 - imAccid: %@, mobile: %@, isOpenVideo: %@, "
                 @"isShowLocalVideo: %@, state: %ld, uid: %llu, originalIndex: %ld",
                 user.imAccid, user.mobile, user.isOpenVideo ? @"YES" : @"NO",
                 user.isShowLocalVideo ? @"YES" : @"NO", (long)user.state, user.uid,
                 (long)user.originalIndex);
      currentIndex++;
    }
    [self.datas addObjectsFromArray:userGroup];
  }

  YXAlogInfo(@"[GroupCallLayout] 📊 转换后数据数量: %ld (之前: %ld)", (long)self.datas.count,
             (long)previousCount);

  // 更新FlowLayout的participantCount
  self.layout.participantCount = self.datas.count;

  YXAlogInfo(@"[GroupCallLayout] 🔧 设置布局参数 - participantCount: %ld",
             (long)self.layout.participantCount);

  // 判断是否需要重新布局
  if (previousCount != self.datas.count) {
    // 人数变化，需要重新布局
    YXAlogInfo(@"[GroupCallLayout] 🔄 人数变化，重新布局 - 从 %ld 变为 %ld", (long)previousCount,
               (long)self.datas.count);
    [self.collection reloadData];
  } else {
    // 人数不变，只刷新可见的 cell 内容
    YXAlogInfo(@"[GroupCallLayout] 🔄 人数不变，只刷新 cell 内容");
    [self refreshAllVisibleCells];
    YXAlogInfo(@"[GroupCallLayout] ✅ cell 内容刷新完成");
  }
}

#pragma mark - lazy init

- (UICollectionView *)collection {
  if (!_collection) {
    NEGroupCallFlowLayout *flowlayout = self.layout;
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowlayout.participantCount = self.datas.count;

    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero
                                     collectionViewLayout:flowlayout];
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.pagingEnabled = NO;
    _collection.bounces = NO;
    _collection.showsVerticalScrollIndicator = NO;
    _collection.scrollEnabled = NO;           // 禁用滚动
    _collection.alwaysBounceVertical = NO;    // 禁用垂直弹跳
    _collection.alwaysBounceHorizontal = NO;  // 禁用水平弹跳

    YXAlogInfo(@"[GroupCallLayout] 🔧 CollectionView 初始化 - scrollEnabled: %@, bounces: %@, "
               @"alwaysBounceVertical: %@",
               _collection.scrollEnabled ? @"YES" : @"NO", _collection.bounces ? @"YES" : @"NO",
               _collection.alwaysBounceVertical ? @"YES" : @"NO");
  }
  return _collection;
}

- (NEGroupCallFlowLayout *)layout {
  if (!_layout) {
    _layout = [[NEGroupCallFlowLayout alloc] init];
  }
  _layout.minimumLineSpacing = 0;
  _layout.minimumInteritemSpacing = 0;
  _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  _layout.participantCount = self.datas.count;
  return _layout;
}

#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  YXAlogInfo(@"[GroupCallLayout] 🔄 collectionView numberOfItemsInSection section: %ld "
             @"self.datas.count: %ld",
             (long)section, (long)self.datas.count);
  return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NEUserInCallCell *cell = [collectionView
      dequeueReusableCellWithReuseIdentifier:NSStringFromClass(NEUserInCallCell.class)
                                forIndexPath:indexPath];
  NEGroupUser *user = [self.datas objectAtIndex:indexPath.row];
  [cell configure:user];  // 直接配置单个用户

  YXAlogInfo(@"[GroupCallLayout] 🔄 collectionView cellForItemAtIndexPath indexPath: %ld",
             (long)indexPath.row);

  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  // 使用自定义布局，不需要在这里设置size
  YXAlogInfo(@"[GroupCallLayout] 🔄 sizeForItemAtIndexPath indexPath: %ld", (long)indexPath.row);
  return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  YXAlogInfo(@"[GroupCallLayout] 🔄 用户点击了第 %ld 个用户", (long)indexPath.row);

  if (indexPath.row < self.datas.count) {
    [self updateCollectionViewWithIndexPath:indexPath];
  }
}

#pragma mark - Cell Refresh Management

- (void)refreshAllVisibleCells {
  // 获取所有可见的 cell 并重新配置
  NSArray<NSIndexPath *> *visibleIndexPaths = [self.collection indexPathsForVisibleItems];

  for (NSIndexPath *indexPath in visibleIndexPaths) {
    if (indexPath.row < self.datas.count) {
      NEUserInCallCell *cell =
          (NEUserInCallCell *)[self.collection cellForItemAtIndexPath:indexPath];
      if (cell) {
        NEGroupUser *user = [self.datas objectAtIndex:indexPath.row];
        [cell configure:user];
      }
    }
  }
}

#pragma mark - Large View Management

- (void)updateCollectionViewWithIndexPath:(NSIndexPath *)indexPath {
  NSInteger count = self.datas.count;
  NSArray *remoteUpdates = [self getRemoteUpdatesWithIndexPath:indexPath];

  YXAlogInfo(@"[GroupCallLayout] 🔄 updateCollectionView - count: %ld, row: %ld, "
             @"currentLargeViewIndex: %ld",
             (long)count, (long)indexPath.row, (long)self.layout.largeViewIndex);

  // 检查是否需要设置第一个用户为大画面（2-4人情况）
  BOOL firstBigFlag = NO;
  if (count >= 2 && count <= 4 && indexPath.row != self.layout.largeViewIndex) {
    firstBigFlag = YES;
    YXAlogInfo(@"[GroupCallLayout] 🔄 设置 firstBigFlag = YES");
  }

  // 切换大画面用户 - 完全按照 Swift 版本
  self.layout.largeViewIndex = (self.layout.largeViewIndex == indexPath.row) ? -1 : indexPath.row;
  if (firstBigFlag) {
    self.layout.largeViewIndex = 0;
    YXAlogInfo(@"[GroupCallLayout] 🔄 firstBigFlag 生效，设置第一个用户为大画面");
  }

  // 设置显示大画面的用户ID
  NSString *showLargeViewUserId =
      (self.layout.largeViewIndex >= 0)
          ? ((NEGroupUser *)[self.datas objectAtIndex:indexPath.row]).imAccid
          : @"";
  [self setShowLargeViewUserId:showLargeViewUserId];

  YXAlogInfo(@"[GroupCallLayout] 🔄 设置大画面 - largeViewIndex: %ld, showLargeViewUserId: %@",
             (long)self.layout.largeViewIndex, showLargeViewUserId);

  // 取消交互式移动
  [self.collection cancelInteractiveMovement];

  // 执行批量更新 - 完全按照 Swift 版本
  [self.collection
      performBatchUpdates:^{
        NSMutableArray<NSNumber *> *deletes = [NSMutableArray array];
        NSMutableArray<NSDictionary *> *inserts = [NSMutableArray array];

        YXAlogInfo(@"[GroupCallLayout] 🔄 处理 remoteUpdates，数量: %ld",
                   (long)remoteUpdates.count);

        // 完全按照 Swift 版本处理所有操作
        for (NSDictionary *update in remoteUpdates) {
          NSString *updateType = update[@"type"];
          if ([updateType isEqualToString:@"delete"]) {
            NSInteger index = [update[@"index"] integerValue];
            [self.collection deleteItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index
                                                                            inSection:0] ]];
            [deletes addObject:@(index)];
            YXAlogInfo(@"[GroupCallLayout] 🔄 删除项目: %ld", (long)index);

          } else if ([updateType isEqualToString:@"insert"]) {
            NEGroupUser *user = update[@"user"];
            NSInteger index = [update[@"index"] integerValue];
            [self.collection insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForItem:index
                                                                            inSection:0] ]];
            [inserts addObject:@{@"user" : user, @"index" : @(index)}];
            YXAlogInfo(@"[GroupCallLayout] 🔄 插入项目: %@ at %ld", user.imAccid, (long)index);

          } else if ([updateType isEqualToString:@"move"]) {
            NSInteger fromIndex = [update[@"fromIndex"] integerValue];
            NSInteger toIndex = [update[@"toIndex"] integerValue];
            [self.collection
                moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]
                        toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
            [deletes addObject:@(fromIndex)];
            [inserts addObject:@{
              @"user" : [self.datas objectAtIndex:fromIndex],
              @"index" : @(toIndex)
            }];
            YXAlogInfo(@"[GroupCallLayout] 🔄 移动项目: %ld -> %ld", (long)fromIndex,
                       (long)toIndex);
          }
        }

        // 删除用户 - 按照索引从大到小排序
        NSArray *sortedDeletes = [deletes
            sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
              return [obj2 compare:obj1];  // 降序
            }];

        for (NSNumber *deletedIndex in sortedDeletes) {
          NSInteger index = [deletedIndex integerValue];
          if (index >= 0 && index < self.datas.count) {
            [self.datas removeObjectAtIndex:index];
            YXAlogInfo(@"[GroupCallLayout] 🔄 从数据源删除用户: %ld", (long)index);
          }
        }

        // 插入用户 - 按照索引从小到大排序
        NSArray *sortedInserts = [inserts
            sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
              NSNumber *index1 = obj1[@"index"];
              NSNumber *index2 = obj2[@"index"];
              return [index1 compare:index2];  // 升序
            }];

        for (NSDictionary *insertion in sortedInserts) {
          NEGroupUser *user = insertion[@"user"];
          NSInteger index = [insertion[@"index"] integerValue];
          if (index >= 0 && index <= self.datas.count) {
            [self.datas insertObject:user atIndex:index];
            YXAlogInfo(@"[GroupCallLayout] 🔄 向数据源插入用户: %@ at %ld", user.imAccid,
                       (long)index);
          }
        }
      }
      completion:^(BOOL finished) {
        YXAlogInfo(
            @"[GroupCallLayout] ✅ 批量更新完成 - largeViewIndex: %ld, showLargeViewUserId: %@",
            (long)self.layout.largeViewIndex, self.layout.showLargeViewUserId);
        [self.collection endInteractiveMovement];
      }];
}

- (void)setShowLargeViewUserId:(NSString *)userId {
  self.layout.showLargeViewUserId = userId;
  YXAlogInfo(@"[GroupCallLayout] 🔄 setShowLargeViewUserId: %@", userId);
}

- (NSArray *)getRemoteUpdatesWithIndexPath:(NSIndexPath *)indexPath {
  NSInteger count = self.datas.count;
  NSInteger row = indexPath.row;

  YXAlogInfo(@"[GroupCallLayout] 🔄 getRemoteUpdates - count: %ld, row: %ld, largeViewIndex: %ld",
             (long)count, (long)row, (long)self.layout.largeViewIndex);

  // 完全按照 Swift 版本的逻辑
  if (count < 2 || count > 4 || row >= count) {
    YXAlogInfo(@"[GroupCallLayout] 🔄 getRemoteUpdates - 条件不满足，返回空数组");
    return @[];
  }

  if (row == self.layout.largeViewIndex) {
    // 如果点击的是当前大画面用户，移动第一个用户到其原始位置
    // 在 Swift 版本中，这里使用 userList[indexPath.row].multiCallCellViewIndex
    // 我们需要找到被点击用户的原始位置
    NEGroupUser *clickedUser = [self.datas objectAtIndex:row];
    NSInteger originalIndex = [self getOriginalIndexForUser:clickedUser];

    NSDictionary *moveUpdate =
        @{@"type" : @"move", @"fromIndex" : @(0), @"toIndex" : @(originalIndex)};
    YXAlogInfo(@"[GroupCallLayout] 🔄 getRemoteUpdates - 移动第一个用户到原始位置: 0 -> %ld",
               (long)originalIndex);
    return @[ moveUpdate ];
  }

  if (count == 2 || [self isFirstUserAtOriginalPosition]) {
    // 2人情况或第一个用户已在原始位置，移动点击的用户到第一个位置
    NSDictionary *moveUpdate = @{@"type" : @"move", @"fromIndex" : @(row), @"toIndex" : @(0)};
    YXAlogInfo(@"[GroupCallLayout] 🔄 getRemoteUpdates - 移动用户到第一个位置: %ld -> 0",
               (long)row);
    return @[ moveUpdate ];
  }

  // 其他情况：先移动第一个用户到其原始位置，再移动点击的用户到第一个位置
  NEGroupUser *firstUser = [self.datas objectAtIndex:0];
  NSInteger firstUserOriginalIndex = [self getOriginalIndexForUser:firstUser];

  NSDictionary *moveFirstUpdate =
      @{@"type" : @"move", @"fromIndex" : @(0), @"toIndex" : @(firstUserOriginalIndex)};
  NSDictionary *moveClickUpdate = @{@"type" : @"move", @"fromIndex" : @(row), @"toIndex" : @(0)};
  YXAlogInfo(
      @"[GroupCallLayout] 🔄 getRemoteUpdates - 复杂移动: 第一个用户 %ld -> %ld, 点击用户 %ld -> 0",
      (long)0, (long)firstUserOriginalIndex, (long)row);
  return @[ moveFirstUpdate, moveClickUpdate ];
}

- (BOOL)isFirstUserAtOriginalPosition {
  // 检查第一个用户是否在原始位置（索引0）
  // 在 Swift 版本中，这相当于 userList[0].multiCallCellViewIndex == 0
  if (self.datas.count > 0) {
    NEGroupUser *firstUser = [self.datas objectAtIndex:0];
    BOOL isAtOriginalPosition = (firstUser.originalIndex == 0);
    YXAlogInfo(@"[GroupCallLayout] 🔄 isFirstUserAtOriginalPosition: %@ (originalIndex: %ld)",
               isAtOriginalPosition ? @"YES" : @"NO", (long)firstUser.originalIndex);
    return isAtOriginalPosition;
  }
  return YES;
}

- (NSInteger)getOriginalIndexForUser:(NEGroupUser *)user {
  // 获取用户的原始位置
  // 在 Swift 版本中，这相当于 user.multiCallCellViewIndex
  NSInteger originalIndex = user.originalIndex;
  YXAlogInfo(@"[GroupCallLayout] 🔄 getOriginalIndexForUser: %@, originalIndex: %ld", user.imAccid,
             (long)originalIndex);
  return originalIndex;
}

- (void)switchToLargeViewUser:(NEGroupUser *)user atIndex:(NSInteger)index {
  YXAlogInfo(@"[GroupCallLayout] 🔄 切换大画面用户: %@, 索引: %ld", user.imAccid, (long)index);

  // 如果点击的是当前大画面用户，则取消大画面
  if (self.layout.largeViewIndex == index) {
    [self clearLargeView];
    return;
  }

  // 设置大画面用户
  [self.layout setLargeViewUser:user.imAccid atIndex:index];

  // 执行布局切换动画
  [self.collection
      performBatchUpdates:^{
        // 这里可以添加更多的动画逻辑
      }
      completion:^(BOOL finished) {
        YXAlogInfo(@"[GroupCallLayout] ✅ 大画面切换完成");
      }];
}

- (void)clearLargeView {
  YXAlogInfo(@"[GroupCallLayout] 🔄 取消大画面模式");

  [self.layout clearLargeView];

  // 执行布局切换动画
  [self.collection
      performBatchUpdates:^{
        // 这里可以添加更多的动画逻辑
      }
      completion:^(BOOL finished) {
        YXAlogInfo(@"[GroupCallLayout] ✅ 取消大画面完成");
      }];
}

@end
