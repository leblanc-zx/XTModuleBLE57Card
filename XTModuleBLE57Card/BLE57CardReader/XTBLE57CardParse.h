//
//  XTBLE57CardParse.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XT57CardInfo.h"
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
 1.卡类型：6A：计金额卡，66：FS型计量卡，剩余的6*：普通计量卡  
 */
- (XT57CardInfo *)parse57CardWithUserSysNum:(long)userSysNum data:(NSData *)data;

#pragma -mark 写卡信息
/**
 写卡信息--requestData
 */
- (NSData *)write57CardWithCardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount;

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
