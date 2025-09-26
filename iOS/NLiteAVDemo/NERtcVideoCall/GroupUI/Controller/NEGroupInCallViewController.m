// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEGroupInCallViewController.h"
#import "GroupInCallViewCell.h"

@interface NEGroupInCallViewController () <UICollectionViewDelegate,
                                           UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collection;

@property(nonatomic, strong) NSMutableArray<NSArray<NEUser *> *> *datas;

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

- (void)setupUI {
  [self.view addSubview:self.collection];
  self.collection.frame =
      CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height + 40);
  [self.collection registerClass:[GroupInCallViewCell class]
      forCellWithReuseIdentifier:NSStringFromClass(GroupInCallViewCell.class)];
  self.collection.backgroundColor = [UIColor blackColor];
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

- (void)changeUsers:(NSArray<NSArray<NEUser *> *> *)users {
  [self.datas removeAllObjects];
  [self.datas addObjectsFromArray:users];
  [self.collection reloadData];
}

#pragma mark - lazy init

- (UICollectionView *)collection {
  if (!_collection) {
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collection = [[UICollectionView alloc] initWithFrame:CGRectZero
                                     collectionViewLayout:flowlayout];
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.pagingEnabled = YES;
    _collection.bounces = NO;
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
  GroupInCallViewCell *cell = [collectionView
      dequeueReusableCellWithReuseIdentifier:NSStringFromClass(GroupInCallViewCell.class)
                                forIndexPath:indexPath];
  NSArray<NEUser *> *users = [self.datas objectAtIndex:indexPath.row];
  [cell configure:users];
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return self.view.frame.size;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.datas.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath
//*)indexPath {
//
//    GroupInCallViewCell *cell = (GroupInCallViewCell*)[tableView
//    dequeueReusableCellWithIdentifier:NSStringFromClass(GroupInCallViewCell.class)
//    forIndexPath:indexPath]; NSArray<NEUser *> *users = [self.datas objectAtIndex:indexPath.row];
//    [cell configure:users];
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.view.frame.size.width;
//}
@end
