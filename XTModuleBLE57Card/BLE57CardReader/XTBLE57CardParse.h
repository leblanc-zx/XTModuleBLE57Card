//
//  XTBLE57CardParse.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XT57OneCardMultipleMeter.h"
#import "XT57OneMeterOneCard.h"
#import "XT57WriteInfo.h"
#import <UIKit/UIKit.h>

@interface XTBLE57CardParse : NSObject

+ (id)sharedData;

#pragma -mark 读卡信息
/**
 读卡信息--requestData
 */
- (NSData *)read57Card;


/**
 读卡信息--parseData
 注释：！！！
 1.卡标志：6A：计金额卡，66：FS型计量卡，剩余的6*：普通计量卡
 */
- (id)parse57CardWithUserSysNum:(long)userSysNum data:(NSData *)data error:(NSError **)error;

#pragma -mark 写卡信息
/**
 写57卡一表一卡信息--requestData
 */
- (NSData *)write57OneMeterOneCardWithCardInfoData:(NSData *)cardInfoData writeInfo:(XT57WriteInfo *)writeInfo;

/**
 写57卡一卡通信息--requestData
 */
- (NSData *)write57OneCardMultipleMeterWithCardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount cardSector:(int)cardSector cardType:(int)cardType;

#pragma -mark 读电池电压信息
/**
 读电池电压信息--requestData
 */
- (NSData *)requestReadVolgate;

/**
 读电池电压信息--parseData
 */
- (CGFloat)parseReadVolgate:(NSData *)data;

@end
