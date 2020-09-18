//
//  NESearchResultView.m
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/8/20.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NESearchResultView.h"
#import "NESearchResultCell.h"
static NSString *searchCellID = @"searchCellID";
@implementation NESearchResultView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.right.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    return self;
}
- (void)updateTitle:(NSString *)title dataArray:(NSArray <NEUser *>*)dataArray {
    self.titleLabel.text = title;
    self.dataArray = dataArray;
    [self.tableView reloadData];
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NEUser *user = [self.dataArray objectAtIndex:indexPath.row];
    NESearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellID forIndexPath:indexPath];
    cell.titleLabel.text = user.mobile;
    [cell.iconView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"avator"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NEUser *user = [self.dataArray objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didSelectUser:)]) {
        [self.delegate didSelectUser:user];
    }
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
        _tableView.rowHeight = 44;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[NESearchResultCell class] forCellReuseIdentifier:searchCellID];
    }
    return _tableView;
}

@end
