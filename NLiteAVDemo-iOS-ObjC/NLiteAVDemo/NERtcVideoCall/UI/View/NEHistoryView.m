//
//  NEHistoryView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NEHistoryView.h"
#import "NEHistoryCell.h"

static NSString *cellID = @"historyCellID";

@implementation NEHistoryView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.right.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        [self.collectionView registerClass:[NEHistoryCell class] forCellWithReuseIdentifier:cellID];
    }
    return self;
}

- (void)updateTitle:(NSString *)title dataArray:(NSArray <NEUser *>*)dataArray {
    self.titleLabel.text = title;
    self.dataArray = dataArray;
    [self.collectionView reloadData];
    if (dataArray.count > 0) {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30);
        }];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            NSInteger numPerRow = (self.bounds.size.width - 40)/(40 + 12);
            NSInteger row =  dataArray.count/numPerRow;
            CGFloat contentH = 40 + row * (40 + 12);
            make.height.mas_equalTo(30 + contentH + 12);
        }];
    }else {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NEUser *user = [self.dataArray objectAtIndex:indexPath.row];
    NEHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    [cell.avator sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@""]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NEUser *user = [self.dataArray objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectUser:)]) {
        [self.delegate didSelectUser:user];
    }
}

#pragma mark - property
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(40, 40);
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 12;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}
@end
