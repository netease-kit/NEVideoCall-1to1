// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupUserController.h"
#import <YXAlog_iOS/YXAlog.h>
#import "NECallUIKitMacro.h"
#import "NEGroupUserViewCell.h"
#import "NESectionHeaderView.h"

@interface NEGroupUserController () <UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collection;

@property(nonatomic, strong) NSMutableArray<NEGroupUser *> *datas;

@property(nonatomic, strong) NESectionHeaderView *sectionHeader;

@property(nonatomic, assign) CGFloat space;

@property(nonatomic, assign) CGFloat bottomOffset;

@end

@implementation NEGroupUserController

- (instancetype)init {
  self = [super init];
  if (self) {
    self.datas = [[NSMutableArray alloc] init];
    //        [[[NIMSDK sharedSDK] chatManager] addDelegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.view.clipsToBounds = YES;
  self.space = 10.0;
  [self.collection addObserver:self
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
  self.view.backgroundColor = [UIColor clearColor];
  [self.view addSubview:self.sectionHeader];
  self.sectionHeader.hidden = YES;
  [self.view addSubview:self.collection];
  self.collection.frame = CGRectMake(20, NESectionHeaderView.height + self.space,
                                     self.view.frame.size.width - 40, self.view.frame.size.height);
  self.bottomOffset = 120;
}

- (void)addUsers:(NSArray<NEGroupUser *> *)users {
  YXAlogInfo(@"GroupUserController count : %lu", users.count);
  [self.datas addObjectsFromArray:users];
  [self.collection reloadData];
  if (self.datas.count > 0 && self.hideHeaderSection == NO) {
    self.sectionHeader.hidden = NO;
  }
}

- (void)removeUsers:(NSArray<NEGroupUser *> *)users {
  [self.datas removeObjectsInArray:users];
  [self.collection reloadData];
  if (self.datas.count < 0 && self.hideHeaderSection == NO) {
    self.sectionHeader.hidden = YES;
  }
}

- (NSMutableArray<NEGroupUser *> *)getAllUsers {
  return self.datas;
}

- (void)removeAllUsers {
  [self.datas removeAllObjects];
}

- (NSInteger)getCurrentCount {
  return self.datas.count;
}

- (UICollectionView *)collection {
  if (_collection == nil) {
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 10;
    flowlayout.minimumInteritemSpacing = 10;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero
                                     collectionViewLayout:flowlayout];
    _collection.delegate = self;
    _collection.dataSource = self;
    [_collection registerClass:[NEGroupUserViewCell class]
        forCellWithReuseIdentifier:NSStringFromClass(NEGroupUserViewCell.class)];
    _collection.backgroundColor = [UIColor clearColor];
  }
  return _collection;
}

- (NESectionHeaderView *)sectionHeader {
  if (nil == _sectionHeader) {
    _sectionHeader = [[NESectionHeaderView alloc] init];
    _sectionHeader.frame = CGRectMake(0, 0, self.view.frame.size.width, NESectionHeaderView.height);
    _sectionHeader.titleLabel.text = kNEWaittingCalledUser;
    _sectionHeader.dividerLine.hidden = NO;
  }
  return _sectionHeader;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if (object == self.collection) {
    if ([keyPath isEqualToString:@"contentSize"]) {
      if (self.view.frame.size.height == self.collection.contentSize.height +
                                             NESectionHeaderView.height + self.space +
                                             self.bottomOffset) {
        return;
      }
      if (self.disableCancelUser == YES) {
        self.view.frame =
            CGRectMake(0, self.view.frame.origin.y, self.view.frame.size.width,
                       self.collection.contentSize.height + NESectionHeaderView.height +
                           self.space + self.bottomOffset);
        self.collection.frame =
            CGRectMake(20, NESectionHeaderView.height + self.space, self.view.frame.size.width - 40,
                       self.view.frame.size.height - NESectionHeaderView.height);
      } else {
        self.view.frame =
            CGRectMake(0, 0, self.view.frame.size.width,
                       self.collection.contentSize.height + NESectionHeaderView.height +
                           self.space + self.bottomOffset);
        self.collection.frame =
            CGRectMake(20, NESectionHeaderView.height + self.space, self.view.frame.size.width - 40,
                       self.view.frame.size.height - NESectionHeaderView.height);
        self.weakTable.tableFooterView = self.view;
      }
    }
  }
}

- (void)dealloc {
  [self.collection removeObserver:self forKeyPath:@"contentSize"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-- collection

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (self.disableCancelUser == YES) {
    return;
  }
  NEGroupUser *user = [self.datas objectAtIndex:indexPath.row];
  [self.datas removeObjectAtIndex:indexPath.row];
  [collectionView reloadData];
  if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didRemoveWithUser:)]) {
    [self.delegate didRemoveWithUser:user];
  }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.datas.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView
                                   cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
  NEGroupUserViewCell *cell = [collectionView
      dequeueReusableCellWithReuseIdentifier:NSStringFromClass(NEGroupUserViewCell.class)
                                forIndexPath:indexPath];
  NEGroupUser *user = [self.datas objectAtIndex:indexPath.row];
  [cell configureWithUser:user];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(40, 40);
}

@end
