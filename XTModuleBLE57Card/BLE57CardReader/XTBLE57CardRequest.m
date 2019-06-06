//
//  XTBLE57CardRequest.m
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTBLE57CardRequest.h"
#import "XTBLEManager.h"
#import "XTUtils.h"
#import "XTBLEManager+Log.h"

@interface XTBLE57CardRequest ()

@end

@implementation XTBLE57CardRequest

static id _instace;

- (id)init
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj = [super init])) {
            
        }
    });
    self = obj;
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}

+ (id)sharedRequest
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

/**
 读卡信息
 
 @param success 成功
 @param failure error
 */
- (void)read57CardWithUserSysNum:(long)userSysNum success:(void (^)(XT57CardInfo *cardInfo))success failure:(void (^)(NSError *error))failure {
    
    XTBLE57CardParse *dataManager = [XTBLE57CardParse sharedData];
    XTBLEManager *manager = [XTBLEManager sharedManager];
    
    //请求数据
    NSData *data = [dataManager read57Card];
    //log
    [[XTBLEManager sharedManager] log_method:@"读卡信息" startFilter:@"" endFilter:@"长度：29"];
    
    [manager sendSimpleData:data startFilter:nil endFilter:^BOOL(NSData *JointData) {
        return JointData.length == 29;
    } success:^(NSData *data) {
        //解析数据
        XT57CardInfo *model = [dataManager parse57CardWithUserSysNum:userSysNum data:data];
        
        if (model) {
            if (success) {
                success(model);
            }
        } else {
            if (failure) {
                if ([[XTUtils hexStringWithData:[data subdataWithRange:NSMakeRange(3, 1)]] isEqualToString:@"00"]) {
                    failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"卡为空卡"}]);
                } else {
                    failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"解析失败"}]);
                }
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 写卡信息
 
 @param success 成功
 @param failure error
 */
- (void)write57CardWithUserSysNum:(long)userSysNum cardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount success:(void (^)(XT57CardInfo *cardInfo))success failure:(void (^)(NSError *error))failure {
    
    XTBLE57CardParse *dataManager = [XTBLE57CardParse sharedData];
    XTBLEManager *manager = [XTBLEManager sharedManager];
    
    //判断是否已经写过卡
    XT57CardInfo *tempCardInfo = [dataManager parse57CardWithUserSysNum:userSysNum data:cardInfoData];
    if (tempCardInfo.thisRead > 0) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"上次充值金额未刷到表,请刷表!"}]);
        }
        return;
    }
    
    //请求数据
    NSData *sendData = [dataManager write57CardWithCardInfoData:cardInfoData rechargeMoney:rechargeMoney rechargeCount:rechargeCount];
    
    //判断请求数据是否正确
    XT57CardInfo *tempSendCardInfo = [dataManager parse57CardWithUserSysNum:userSysNum data:sendData];
    long recharge = 0;
    if ([[tempSendCardInfo.cardType uppercaseString] isEqualToString:@"6A"]) {
        //计金额
        recharge = [rechargeMoney longLongValue];
    } else {
        //计量
        recharge = [rechargeCount longLongValue];
    }
    if (tempSendCardInfo.thisRead != recharge) {
        if (failure) {
            failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"写卡数据错误,请重试"}]);
        }
        return;
    }
    
    //log
    [[XTBLEManager sharedManager] log_method:@"写卡信息" startFilter:@"" endFilter:@"长度：29"];
    
    [manager sendSimpleData:sendData startFilter:nil endFilter:^BOOL(NSData *JointData) {
        return JointData.length == 29;
    } success:^(NSData *data) {
        //解析数据
        XT57CardInfo *model = [dataManager parse57CardWithUserSysNum:userSysNum data:data];
        
        if (model) {
            if (success) {
                success(model);
            }
        } else {
            if (failure) {
                failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"解析失败"}]);
            }
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 读电池电压
 
 @param success 成功
 @param failure error
 */
- (void)readVoltageSuccess:(void (^)(CGFloat volgateValue))success failure:(void (^)(NSError *error))failure {
    
    XTBLE57CardParse *dataManager = [XTBLE57CardParse sharedData];
    XTBLEManager *manager = [XTBLEManager sharedManager];
    
    //请求数据
    NSData *data = [dataManager requestReadVolgate];//log
    [[XTBLEManager sharedManager] log_method:@"读电池电压" startFilter:@"" endFilter:@"长度：7"];
    
    [manager sendSimpleData:data startFilter:nil endFilter:^BOOL(NSData *JointData) {
        return JointData.length == 7;
    } success:^(NSData *data) {
        //解析数据
        CGFloat volgateValue = [dataManager parseReadVolgate:data];
        
        if (volgateValue > 0) {
            if (success) {
                success(volgateValue);
            }
        } else {
            if (failure) {
                failure([NSError errorWithDomain:@"错误" code:11111 userInfo:@{@"NSLocalizedDescription":@"解析失败"}]);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


@end
