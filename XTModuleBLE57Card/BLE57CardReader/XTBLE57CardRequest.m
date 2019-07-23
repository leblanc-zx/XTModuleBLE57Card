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
- (void)read57CardWithUserSysNum:(long)userSysNum success:(void (^)(id cardInfo))success failure:(void (^)(NSError *error))failure {
    
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
        NSError *error;
        id model = [dataManager parse57CardWithUserSysNum:userSysNum data:data error:&error];
        
        if ([[data subdataWithRange:NSMakeRange(1, 1)] isEqualToData:[XTUtils dataWithHexString:@"C1"]]) {
            error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"读卡异常"}];
        } else if ([[data subdataWithRange:NSMakeRange(1, 1)] isEqualToData:[XTUtils dataWithHexString:@"8F"]]) {
            error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"无卡"}];
        }
        
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if (success) {
                success(model);
            }
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 写57卡一表一卡信息
 
 @param success 成功
 @param failure error
 */
- (void)write57OneMeterOneCardWithUserSysNum:(long)userSysNum cardInfoData:(NSData *)cardInfoData writeInfo:(XT57WriteInfo *)writeInfo success:(void (^)(XT57OneMeterOneCard *cardInfo))success failure:(void (^)(NSError *error, NSData *sData))failure {
    
    XTBLE57CardParse *dataManager = [XTBLE57CardParse sharedData];
    XTBLEManager *manager = [XTBLEManager sharedManager];
    
    //请求数据
    NSData *sendData = [dataManager write57OneMeterOneCardWithCardInfoData:cardInfoData writeInfo:writeInfo];
    NSError *error1;
    [dataManager parse57CardWithUserSysNum:userSysNum data:sendData error:&error1];
    if (error1) {
        if (failure) {
            failure(error1, sendData);
        }
        return;
    }
    
    //log
    [[XTBLEManager sharedManager] log_method:@"写卡信息" startFilter:@"" endFilter:@"长度：29"];
    
    [manager sendSimpleData:sendData startFilter:nil endFilter:^BOOL(NSData *JointData) {
        return JointData.length == 29;
    } success:^(NSData *data) {
        //解析数据
        NSError *error;
        id model = [dataManager parse57CardWithUserSysNum:userSysNum data:data error:&error];
        
        if ([[data subdataWithRange:NSMakeRange(1, 1)] isEqualToData:[XTUtils dataWithHexString:@"C4"]]) {
            error = [NSError errorWithDomain:@"错误" code:-20190716 userInfo:@{NSLocalizedDescriptionKey: @"写卡异常"}];
        }
        
        if (error) {
            if (failure) {
                failure(error, sendData);
            }
        } else {
            if (success) {
                success(model);
            }
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error, sendData);
        }
    }];
}

/**
 写57卡一一卡通信息
 
 @param success 成功
 @param failure error
 */
- (void)write57OneCardMultipleMeterWithUserSysNum:(long)userSysNum cardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount cardSector:(int)cardSector cardType:(int)cardType success:(void (^)(XT57OneCardMultipleMeter *cardInfo))success failure:(void (^)(NSError *error, NSData *sData))failure {
    
    XTBLE57CardParse *dataManager = [XTBLE57CardParse sharedData];
    XTBLEManager *manager = [XTBLEManager sharedManager];
    
    //请求数据
    NSData *sendData = [dataManager write57OneCardMultipleMeterWithCardInfoData:cardInfoData rechargeMoney:rechargeMoney rechargeCount:rechargeCount cardSector:cardSector cardType:cardType];
    
    NSError *error1;
    [dataManager parse57CardWithUserSysNum:userSysNum data:sendData error:&error1];
    if (error1) {
        if (failure) {
            failure(error1, sendData);
        }
        return;
    }
    
    //log
    [[XTBLEManager sharedManager] log_method:@"写卡信息" startFilter:@"" endFilter:@"长度：29"];
    
    [manager sendSimpleData:sendData startFilter:nil endFilter:^BOOL(NSData *JointData) {
        return JointData.length == 29;
    } success:^(NSData *data) {
        //解析数据
        NSError *error;
        id model = [dataManager parse57CardWithUserSysNum:userSysNum data:data error:&error];
        
        if ([[data subdataWithRange:NSMakeRange(1, 1)] isEqualToData:[XTUtils dataWithHexString:@"C4"]]) {
            error = [NSError errorWithDomain:@"错误" code:-20190716 userInfo:@{NSLocalizedDescriptionKey: @"写卡异常"}];
        }
        
        if (error) {
            if (failure) {
                failure(error, sendData);
            }
        } else {
            if (success) {
                success(model);
            }
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error, sendData);
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
