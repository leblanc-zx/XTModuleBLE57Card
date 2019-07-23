//
//  XTBLE57CardRequest.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTBLE57CardParse.h"
#import "XT57WriteInfo.h"

@interface XTBLE57CardRequest : NSObject

+ (id)sharedRequest;

/**
 读57卡信息
 
 @param success 成功
 @param failure error
 */
- (void)read57CardWithUserSysNum:(long)userSysNum success:(void (^)(id cardInfo))success failure:(void (^)(NSError *error))failure;

/**
 写57卡一表一卡信息
 
 @param success 成功
 @param failure error
 */
- (void)write57OneMeterOneCardWithUserSysNum:(long)userSysNum cardInfoData:(NSData *)cardInfoData writeInfo:(XT57WriteInfo *)writeInfo success:(void (^)(XT57OneMeterOneCard *cardInfo))success failure:(void (^)(NSError *error, NSData *sData))failure;

/**
 写57卡一一卡通信息
 
 @param success 成功
 @param failure error
 */
- (void)write57OneCardMultipleMeterWithUserSysNum:(long)userSysNum cardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount cardSector:(int)cardSector cardType:(int)cardType success:(void (^)(XT57OneCardMultipleMeter *cardInfo))success failure:(void (^)(NSError *error, NSData *sData))failure;

/**
 读电池电压
 
 @param success 成功
 @param failure error
 */
- (void)readVoltageSuccess:(void (^)(CGFloat volgateValue))success failure:(void (^)(NSError *error))failure;

@end
