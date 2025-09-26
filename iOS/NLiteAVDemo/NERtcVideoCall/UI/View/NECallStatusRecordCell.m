// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallStatusRecordCell.h"
#import <NIMSDK/NIMSDK.h>

@interface NECallStatusRecordCell ()

@property(nonatomic, strong) UIImageView *callTypeImage;

@property(nonatomic, strong) UILabel *phoneLabel;

@property(nonatomic, strong) UILabel *timeLabel;

@end

@implementation NECallStatusRecordCell

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  [self setupUI];
  self.backgroundColor = [UIColor clearColor];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  return self;
}

- (void)setupUI {
  [self.contentView addSubview:self.callTypeImage];
  [self.callTypeImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(20);
    make.centerY.equalTo(self.contentView);
  }];
  [self.contentView addSubview:self.phoneLabel];
  [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.contentView);
    make.left.equalTo(self.callTypeImage.mas_right).offset(10);
  }];

  [self.contentView addSubview:self.timeLabel];
  [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.contentView);
    make.right.equalTo(self.contentView).offset(-20);
  }];
}

- (UIImageView *)callTypeImage {
  if (nil == _callTypeImage) {
    _callTypeImage = [[UIImageView alloc] init];
  }
  return _callTypeImage;
}

- (UILabel *)phoneLabel {
  if (nil == _phoneLabel) {
    _phoneLabel = [[UILabel alloc] init];
    _phoneLabel.textAlignment = NSTextAlignmentLeft;
    _phoneLabel.font = [UIFont systemFontOfSize:14.0];
  }
  return _phoneLabel;
}

- (UILabel *)timeLabel {
  if (_timeLabel == nil) {
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
  }
  return _timeLabel;
}

- (void)configure:(NECallStatusRecordModel *)model {
  NSMutableDictionary *dataDic = [self getShowData:model];
  self.callTypeImage.image = [UIImage imageNamed:[dataDic objectForKey:@"imageName"]];
  self.phoneLabel.text = model.mobile;
  self.phoneLabel.textColor = [dataDic objectForKey:@"phoneColor"];
  self.timeLabel.text = [dataDic objectForKey:@"time"];
  self.timeLabel.textColor = [dataDic objectForKey:@"timeColor"];
}

- (NSMutableDictionary *)getShowData:(NECallStatusRecordModel *)model {
  NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];

  UIColor *opacityColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
  UIColor *whiteColor = [UIColor whiteColor];
  switch (model.status) {
    case NIMRtcCallStatusComplete: {
      [dataDic setValue:whiteColor forKey:@"phoneColor"];
      [dataDic setValue:opacityColor forKey:@"timeColor"];
      NSString *imageName;
      if (model.isCaller == YES) {
        imageName = model.isVideoCall ? @"caller_video" : @"caller_audio";
      } else {
        imageName = model.isVideoCall ? @"called_video" : @"called_audio";
      }
      [dataDic setValue:imageName forKey:@"imageName"];
      NSString *time = [NSString stringWithFormat:@"%@ %@", [self getCallTime:model.startTime],
                                                  [self getCallDurationString:model.duration]];
      [dataDic setValue:time forKey:@"time"];
    } break;
    case NIMRtcCallStatusCanceled: {
      [self getUnCompleteStatus:dataDic withModel:model];
    } break;
    case NIMRtcCallStatusRejected: {
      [self getUnCompleteStatus:dataDic withModel:model];
    } break;
    case NIMRtcCallStatusTimeout: {
      [self getUnCompleteStatus:dataDic withModel:model];
    } break;
    case NIMRtcCallStatusBusy: {
      [self getUnCompleteStatus:dataDic withModel:model];
    } break;
    default:
      [self getUnCompleteStatus:dataDic withModel:model];
      break;
  }

  return dataDic;
}

- (void)getUnCompleteStatus:(NSMutableDictionary *)dataDic
                  withModel:(NECallStatusRecordModel *)model {
  UIColor *redColor = [UIColor colorWithRed:1.0 green:93.0 / 255 blue:84.0 / 255 alpha:1.0];
  [dataDic setValue:redColor forKey:@"phoneColor"];
  [dataDic setValue:redColor forKey:@"timeColor"];
  NSString *imageName;
  if (model.isCaller == YES) {
    imageName = model.isVideoCall ? @"caller_video_red" : @"caller_audio_red";
  } else {
    imageName = model.isVideoCall ? @"called_video_red" : @"called_audio_red";
  }
  [dataDic setValue:imageName forKey:@"imageName"];
  [dataDic setValue:[self getCallTime:model.startTime] forKey:@"time"];
  NSString *time = [self getCallTime:model.startTime];
  [dataDic setValue:time forKey:@"time"];
}

- (NSString *)getCallTime:(NSDate *)date {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"HH:mm"];
  NSString *dateTime = [formatter stringFromDate:date];
  return dateTime;
}

- (NSString *)getCallDurationString:(NSInteger)duration {
  NSString *time = @"0秒";
  int seconds = duration % 60;
  int minutes = (duration / 60) % 60;
  int hours = (int)(duration / 3600);
  if (hours > 0) {
    return [NSString stringWithFormat:@"%d小时%d分", hours, minutes];
  }
  if (minutes > 0) {
    return [NSString stringWithFormat:@"%d分%d秒", minutes, seconds];
  }
  if (seconds > 0) {
    return [NSString stringWithFormat:@"%d秒", seconds];
  }
  return time;
}

@end
