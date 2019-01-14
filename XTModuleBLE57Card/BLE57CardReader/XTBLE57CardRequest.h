//
//  XTBLE57CardRequest.h
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XTBLE57CardParse.h"

@interface XTBLE57CardRequest : NSObject

+ (id)sharedRequest;

/**
 读57卡信息
 
 @param success 成功
 @param failure error
 */
- (void)read57CardWithUserSysNum:(long)userSysNum success:(void (^)(XT57CardInfo *cardInfo))success failure:(void (^)(NSError *error))failure;

/**
 写57卡信息
 
 @param success 成功
 @param failure error
 */
- (void)write57CardWithUserSysNum:(long)userSysNum cardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount success:(void (^)(XT57CardInfo *cardInfo))success failure:(void (^)(NSError *error))failure;

/**
 读电池电压
 
 @param success 成功
 @param failure error
 */
- (void)readVoltageSuccess:(void (^)(CGFloat volgateValue))success failure:(void (^)(NSError *error))failure;

@end
