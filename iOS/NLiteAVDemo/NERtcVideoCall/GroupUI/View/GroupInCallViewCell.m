// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "GroupInCallViewCell.h"
#import "NSMacro.h"
#import "UserInCallCell.h"

@interface GroupInCallViewCell () <UICollectionViewDelegate,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) NSArray<NEUser *> *datas;
@property(nonatomic, strong) UICollectionView *collection;
@property(nonatomic, assign) CGFloat ratio;
@property(nonatomic, assign) CGFloat itemWidth;
@property(nonatomic, assign) CGFloat itemHeight;

@end

@implementation GroupInCallViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupUI];
  }
  return self;
}

- (void)setupUI {
  self.ratio = 1.776;
  self.itemWidth = self.contentView.frame.size.width / 2.0;
  self.itemHeight = self.itemWidth * self.ratio;
  if (self.itemHeight * 2 > self.frame.size.height - 1) {
    self.itemHeight = (self.frame.size.height - 1) / 2.0;
  }
  self.transform = CGAffineTransformMakeRotation(M_PI / 2);
  self.contentView.backgroundColor = HEXCOLOR(0x000000);
  [self.contentView addSubview:self.collection];
  self.collection.frame =
      CGRectMake(0, 0, self.contentView.frame.size.width, self.itemHeight * 2.0);
  self.collection.center = self.contentView.center;
}

- (void)configure:(NSArray<NEUser *> *)users {
  self.datas = users;
  [self.collection reloadData];
}

- (UICollectionView *)collection {
  if (!_collection) {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 1;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero
                                     collectionViewLayout:flowLayout];
    [_collection registerClass:[UserInCallCell class]
        forCellWithReuseIdentifier:NSStringFromClass([UserInCallCell class])];
    _collection.dataSource = self;
    _collection.delegate = self;
    _collection.bounces = NO;
    _collection.backgroundColor = [UIColor clearColor];
  }
  return _collection;
}

#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.datas.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UserInCallCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UserInCallCell.class)
                                                forIndexPath:indexPath];
  NEUser *user = [self.datas objectAtIndex:indexPath.row];
  [cell configure:user];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger remainder = indexPath.row % 2;
  if (remainder == 0) {
    return CGSizeMake(self.itemWidth, self.itemHeight);
  } else {
    return CGSizeMake(self.itemWidth - 1, self.itemHeight);
  }
}
@end
