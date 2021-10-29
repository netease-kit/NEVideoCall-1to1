//
//  AppKey.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/9/3.
//  Copyright © 2020 Netease. All rights reserved.
//

#ifndef AppKey_h
#define AppKey_h

//static NSString * const kAppKey = @"<#请输入网易云信控制台获取的App Key#>";
/////p12文件,推送证书导出方式需同时包含私钥和公钥
//static NSString * const kAPNSCerName = @"<#请输入远程推送证书名字#>";
//static NSString * const VoIPCerName = @"<#请输入您的VoIP推送证书#>";
//static NSString * const kApiHost = @"<#App服务器域名#>";
//线上：

static NSString * const kApiHost = @"https://yiyong.netease.im";
static NSString * const kAppKey = @"9ee2101a195b4044c4002d1972156396";
///p12文件,推送证书导出方式需同时包含私钥和公钥
static NSString * const kAPNSCerName = @"NELiteAVDemo";
static NSString * const VoIPCerName = @"请输入您的VoIP推送证书";

//测试：
//static NSString * const kApiHost = @"https://yiyong-qa.netease.im";
//static NSString * const kAppKey = @"56813bdfbaa1c2a29bbea391ffbbe27a";
/////p12文件,推送证书导出方式需同时包含私钥和公钥
//static NSString * const kAPNSCerName = @"LiteAVAPNSAll";
//static NSString * const VoIPCerName = @"请输入您的VoIP推送证书";
#endif /* AppKey_h */
