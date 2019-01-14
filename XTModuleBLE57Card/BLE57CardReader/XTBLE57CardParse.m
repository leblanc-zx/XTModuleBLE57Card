//
//  XTBLE57CardParse.m
//  SuntrontBlueTooth
//
//  Created by apple on 2017/7/28.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "XTBLE57CardParse.h"
#import "XTUtils.h"

@implementation XTBLE57CardParse

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

+ (id)sharedData
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    
    return _instace;
}

#pragma -mark 读卡信息
/**
 读卡信息--requestData
 */
- (NSData *)read57Card {
    return [XTUtils dataWithHexString:@"6801006916"];
}


/**
 读卡信息--parseData
 注释：！！！
 1.卡类型：6A：计金额卡，66：FS型计量卡，剩余的6*：普通计量卡
 */
- (XT57CardInfo *)parse57CardWithUserSysNum:(long)userSysNum data:(NSData *)data {
    ///<68811864 28b66964 00000000 00000d00 00000000 00000000 0000001d 16>
    NSData *subData = [data subdataWithRange:NSMakeRange(3, 24)];
    NSString *dataStr = [XTUtils hexStringWithData:subData];
    NSString *type = [[dataStr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
    if ([type isEqualToString:@"6A"]) {
        //计金额
        //*验证校验和是否正确
        NSData *checkSumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[subData subdataWithRange:NSMakeRange(0, 23)]];
        if (![[subData subdataWithRange:NSMakeRange(23, 1)] isEqualToData:checkSumData]) {
            return nil;
        }
        
        XT57CardInfo *model = [[XT57CardInfo alloc] init];
        model.originCardData = data;
        
        //卡号
        long card1 = [XTUtils longWithHexString:[dataStr substringWithRange:NSMakeRange(2, 2)]];
        long card2 = [XTUtils longWithHexString:[dataStr substringWithRange:NSMakeRange(4, 2)]];
        long card3 = [XTUtils longWithHexString:[dataStr substringWithRange:NSMakeRange(6, 2)]];
        long sysNum = userSysNum;
        if (card1 == sysNum) {
            model.cardNumber = [NSString stringWithFormat:@"%ld",card2 + card3 * 256];
        } else if (card1 < sysNum) {
            model.cardNumber = [NSString stringWithFormat:@"%ld",card2 + card3 * 256 + (256 + card1 - sysNum) * 65536];
        } else if (card1 > sysNum) {
            model.cardNumber = [NSString stringWithFormat:@"%ld",card2 + card3 * 256 + (card1 - sysNum) * 65536];
        }
        //卡类型
        model.cardType = [dataStr substringWithRange:NSMakeRange(0, 2)];
        //系统
        model.systemNumber = [dataStr substringWithRange:NSMakeRange(2, 2)];
        
        //总金额
        model.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(32, 6)]]]];
        //本次金额
        model.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(40, 6)]]]];
        //剩余金额
        model.remainedMoney = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(26, 6)]]]];
        //报警
        model.warnMoney = [XTUtils longWithData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(24, 2)]]];
        //透支
        model.overMoney = [XTUtils longWithData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(38, 2)]]];
        
        return model;
        
    } else if ([type hasPrefix:@"6"]) {
        //计量
        //*验证校验和是否正确
        NSData *checkSumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[subData subdataWithRange:NSMakeRange(0, 11)]];
        if (![[subData subdataWithRange:NSMakeRange(11, 1)] isEqualToData:checkSumData]) {
            return nil;
        }
        
        XT57CardInfo *model = [[XT57CardInfo alloc] init];
        model.originCardData = data;
        
        //卡号
        long card1 = [XTUtils longWithHexString:[dataStr substringWithRange:NSMakeRange(2, 2)]];
        long card2 = [XTUtils longWithHexString:[dataStr substringWithRange:NSMakeRange(4, 2)]];
        long card3 = [XTUtils longWithHexString:[dataStr substringWithRange:NSMakeRange(6, 2)]];
        long sysNum = userSysNum;
        if (card1 == sysNum) {
            model.cardNumber = [NSString stringWithFormat:@"%ld",card2 + card3 * 256];
        } else if (card1 < sysNum) {
            model.cardNumber = [NSString stringWithFormat:@"%ld",card2 + card3 * 256 + (256 + card1 - sysNum) * 65536];
        } else if (card1 > sysNum) {
            model.cardNumber = [NSString stringWithFormat:@"%ld",card2 + card3 * 256 + (card1 - sysNum) * 65536];
        }
        //卡类型
        model.cardType = [dataStr substringWithRange:NSMakeRange(0, 2)];
        //系统
        model.systemNumber = [dataStr substringWithRange:NSMakeRange(2, 2)];
        
        
        if ([type hasPrefix:@"66"]) {
            //FS型计量
            //总量
            model.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(8, 8)]]]];
            //本次
            NSString *thisRead = [NSString stringWithFormat:@"%@%@",[dataStr substringWithRange:NSMakeRange(18, 4)] ,[dataStr substringWithRange:NSMakeRange(16, 2)]];
            model.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:thisRead]]]&0x7FFFFF;
            //剩余
            NSString *remainedCount = [NSString stringWithFormat:@"%@%@%@",[dataStr substringWithRange:NSMakeRange(28, 4)], [dataStr substringWithRange:NSMakeRange(26, 2)], [dataStr substringWithRange:NSMakeRange(24, 2)]];
            model.remainedCount = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:remainedCount]]];
            //报警
            model.warnCount = 0;
            //透支
            model.overCount = 0;
        } else {
            //普通计量
            //总量
            model.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(8, 6)]]]];
            //本次
            model.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(18, 4)]]]]&0x7FFF;
            //剩余
            model.remainedCount = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(28, 4)]]]];
            //报警
            model.warnCount = [XTUtils longWithData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(24, 2)]]];
            //透支
            model.overCount = [XTUtils longWithData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(32, 2)]]];
        }
        
        return model;
        
    } else {
        return nil;
    }
    
}

#pragma -mark 写卡信息
/**
 写卡信息--requestData
 */
- (NSData *)write57CardWithCardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount {
    
    NSString *readInfo = [XTUtils hexStringWithData:cardInfoData];
    NSString *data = [readInfo substringWithRange:NSMakeRange(6, 48)];
    /**
     *  把要发送的帧数据分为三部分：帧头、卡数据、帧尾。即：start、mid、end
     *  mid部分为卡数据信息，以校验和为间隔，可以分为：midBegin、midCenter、midEnd
     *  帧头部分三个字节：0x68，控制码为0x04，数据长度0x18.
     */
    NSString *start = @"680418";
    NSMutableString *mid = [[NSMutableString alloc] init];
    NSMutableString *midBegin = [[NSMutableString alloc] init];
    NSString *midCenter = @"";
    NSString *midEnd = @"";
    NSString *end = @"";
    
    long nowT;
    
    NSString *type = [[data substringWithRange:NSMakeRange(0, 2)] uppercaseString];
    if ([type isEqualToString:@"6A"]) {
        //计金额
        long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[data substringWithRange:NSMakeRange(32, 6)]]]];
        nowT = [rechargeMoney longLongValue] + totalRead;
        [midBegin appendString:[data substringWithRange:NSMakeRange(0, 32)]];
        [midBegin appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:3]]]];
        [midBegin appendString:[data substringWithRange:NSMakeRange(38, 2)]];
        [midBegin appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:[rechargeMoney longLongValue] length:3]]]];
        
        //校验和取反加1
        midCenter = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:midBegin]]];
        
        midEnd = @"";
        
        [mid appendString:midBegin];
        [mid appendString:midCenter];
        [mid appendString:midEnd];
        
    } else if ([type hasPrefix:@"6"]) {
        //计量
        if ([type hasPrefix:@"66"]) {
            //FS型计量
            long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[data substringWithRange:NSMakeRange(8, 8)]]]];
            nowT = [rechargeCount longLongValue] + totalRead;
            //用户卡的 0-3 + 总量 + 本次
            [midBegin appendString:[data substringWithRange:NSMakeRange(0, 8)]];
            [midBegin appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:4]]]];
            
            //本次：DHH + DL + DH
            NSString *tempStr = [XTUtils hexStringWithData:[XTUtils dataWithLong:[rechargeCount longLongValue] length:3]];
            NSString *thisStr = [NSString stringWithFormat:@"%@%@%@",[tempStr substringWithRange:NSMakeRange(0, 2)],[tempStr substringWithRange:NSMakeRange(4, 2)],[tempStr substringWithRange:NSMakeRange(2, 2)]];
            [midBegin appendFormat:@"%@",thisStr];
            
            //校验和取反加1
            midCenter = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:midBegin]]];
            
            //校验和+用户卡12-22
            midEnd = [data substringWithRange:NSMakeRange(24, 22)];
            
            [mid appendString:midBegin];
            [mid appendString:midCenter];
            [mid appendString:midEnd];
            //第二个校验和
            NSString *check2 = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:mid]]];
            [mid appendString:check2];
        } else {
            //普通计量
            long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[data substringWithRange:NSMakeRange(8, 6)]]]];
            nowT = [rechargeCount longLongValue] + totalRead;
            //用户卡的 0-3 + 总量 + 用户卡7-8 + 本次
            [midBegin appendString:[data substringWithRange:NSMakeRange(0, 8)]];
            [midBegin appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:3]]]];
            [midBegin appendString:[data substringWithRange:NSMakeRange(14, 4)]];
            [midBegin appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:[rechargeCount longLongValue] length:2]]]];
            
            //校验和取反加1
            midCenter = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:midBegin]]];
            
            //校验和+用户卡12-23
            midEnd = [data substringWithRange:NSMakeRange(24, 24)];
            
            [mid appendString:midBegin];
            [mid appendString:midCenter];
            [mid appendString:midEnd];
        }
        
    } 
    end = [XTUtils hexStringWithData:[XTUtils checksumDataWithOriginData:[XTUtils dataWithHexString:[NSString stringWithFormat:@"%@%@",start,mid]]]];
    
    return [XTUtils dataWithHexString:[NSString stringWithFormat:@"%@%@%@16",start, mid, end]];
    
}

#pragma -mark 读电池电压信息
/**
 读电池电压信息--requestData
 */
- (NSData *)requestReadVolgate {
    return [XTUtils dataWithHexString:@"6805006d16"];
}

/**
 读电池电压信息--parseData
 */
- (CGFloat)parseReadVolgate:(NSData *)data {
    NSData *volgateData = [data subdataWithRange:NSMakeRange(3, 2)];
    long intVolgate = [[XTUtils hexStringWithData:[volgateData subdataWithRange:NSMakeRange(0, 1)]] longLongValue];
    long decimalVolgate = [[XTUtils hexStringWithData:[volgateData subdataWithRange:NSMakeRange(1, 1)]] longLongValue];
    CGFloat volgateValue = intVolgate + decimalVolgate*0.01;
    if (volgateValue > 5) {
        return 5;
    } else {
        return volgateValue;
    }
}

@end
