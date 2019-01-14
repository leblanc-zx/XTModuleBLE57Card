//
//  XT57CardInfo.h
//  QuickTopUp
//
//  Created by apple on 2018/6/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XT57CardInfo : NSObject

@property (nonatomic, strong) NSData *originCardData;       //卡帧数据
@property (nonatomic, strong) NSString *cardNumber;         //卡号
@property (nonatomic, strong) NSString *cardType;           //卡类型:(6A:计金额、66:FS型计量、6*:普通计量)
@property (nonatomic, strong) NSString *systemNumber;       //系统号
@property (nonatomic, assign) long totalRead;               //总量(或金额)
@property (nonatomic, assign) long thisRead;                //本次购量(或金额)

@end

//计量卡信息
@interface XT57CardInfo (Amount)

@property (nonatomic, assign) long remainedCount;       //剩余量
@property (nonatomic, assign) long overCount;           //透支量
@property (nonatomic, assign) long warnCount;           //报警量

@end

//计金额卡信息
@interface XT57CardInfo (Money)

@property (nonatomic, assign) long remainedMoney;       //剩余金额
@property (nonatomic, assign) long overMoney;           //透支金额
@property (nonatomic, assign) long warnMoney;           //报警金额

@end
