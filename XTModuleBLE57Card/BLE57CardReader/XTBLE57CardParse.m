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
 1.卡标志：6A：计金额卡，66：FS型计量卡，剩余的6*：普通计量卡
 */
- (id)parse57CardWithUserSysNum:(long)userSysNum data:(NSData *)data error:(NSError **)error {
    ///<68811864 28b66964 00000000 00000d00 00000000 00000000 0000001d 16>
    NSData *subData = [data subdataWithRange:NSMakeRange(3, 24)];
    NSString *dataStr = [XTUtils hexStringWithData:subData];
    NSString *type = [[dataStr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
    if ([type isEqualToString:@"6A"]) {
        //一表一卡计金额
        //*验证校验和是否正确
        NSData *checkSumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[subData subdataWithRange:NSMakeRange(0, 23)]];
        if (![[subData subdataWithRange:NSMakeRange(23, 1)] isEqualToData:checkSumData]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"校验和校验失败"}];
            return nil;
        }
        
        XT57OneMeterOneCard *model = [[XT57OneMeterOneCard alloc] init];
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
        //卡标志
        model.cardFlag = [dataStr substringWithRange:NSMakeRange(0, 2)];
        //卡类型
        model.cardType = [self getCardTypeWithCardFlag:model.cardFlag];
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
        //是否已刷表
        if (model.thisRead == 0) {
            model.isBrushed = YES;
        } else {
            model.isBrushed = NO;
        }
        
        return model;
        
    } else if ([type hasPrefix:@"6"]) {
        //一表一卡计量
        //*验证校验和是否正确
        NSData *checkSumData = [XTUtils checkNegationGalOneSumDataWithOriginData:[subData subdataWithRange:NSMakeRange(0, 11)]];
        if (![[subData subdataWithRange:NSMakeRange(11, 1)] isEqualToData:checkSumData]) {
            *error = [NSError errorWithDomain:@"错误" code:-110 userInfo:@{NSLocalizedDescriptionKey: @"校验和校验失败"}];
            return nil;
        }
        
        XT57OneMeterOneCard *model = [[XT57OneMeterOneCard alloc] init];
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
        //卡标志
        model.cardFlag = [dataStr substringWithRange:NSMakeRange(0, 2)];
        //卡类型
        model.cardType = [self getCardTypeWithCardFlag:model.cardFlag];
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
        
        //是否已刷表
        if (model.thisRead == 0) {
            model.isBrushed = YES;
        } else {
            model.isBrushed = NO;
        }
        
        return model;
        
    } else if ([type isEqualToString:@"DA"]) {
        //一卡通(这里无法区分计金额或计量)
        //*没有校验和
        
        XT57OneCardMultipleMeter *model = [[XT57OneCardMultipleMeter alloc] init];
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
        //卡标志
        model.cardFlag = [dataStr substringWithRange:NSMakeRange(0, 2)];
        //系统
        model.systemNumber = [dataStr substringWithRange:NSMakeRange(2, 2)];
        
        //卡区1
        XT57CardSector *sector1 = [[XT57CardSector alloc] init];
        sector1.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(12, 4)]]]];
        sector1.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(8, 4)]]]];
        sector1.isBrushed = sector1.thisRead == 0;
        sector1.cardType = 1; //默认为1，通过表档案去矫正
        model.sector1 = sector1;
        
        //卡区2
        XT57CardSector *sector2 = [[XT57CardSector alloc] init];
        sector2.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(20, 4)]]]];
        sector2.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(16, 4)]]]];
        sector2.isBrushed = sector2.thisRead == 0;
        sector2.cardType = 1; //默认为1，通过表档案去矫正
        model.sector2 = sector2;
        
        //卡区3
        XT57CardSector *sector3 = [[XT57CardSector alloc] init];
        sector3.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(28, 4)]]]];
        sector3.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(24, 4)]]]];
        sector3.isBrushed = sector3.thisRead == 0;
        sector3.cardType = 1; //默认为1，通过表档案去矫正
        model.sector3 = sector3;
        
        //卡区4
        XT57CardSector *sector4 = [[XT57CardSector alloc] init];
        sector4.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(36, 4)]]]];
        sector4.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(32, 4)]]]];
        sector4.isBrushed = sector4.thisRead == 0;
        sector4.cardType = 1; //默认为1，通过表档案去矫正
        model.sector4 = sector4;
        
        //卡区5
        XT57CardSector *sector5 = [[XT57CardSector alloc] init];
        sector5.totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(44, 4)]]]];
        sector5.thisRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(40, 4)]]]];
        sector5.isBrushed = sector5.thisRead == 0;
        sector5.cardType = 1; //默认为1，通过表档案去矫正
        model.sector5 = sector5;
        
        return model;
        
    } else if ([type isEqualToString:@"00"]) {
        *error = [NSError errorWithDomain:@"错误" code:11111 userInfo:@{NSLocalizedDescriptionKey: @"卡为空卡"}];
        return nil;
    } else {
        *error = [NSError errorWithDomain:@"错误" code:11111 userInfo:@{NSLocalizedDescriptionKey: @"解析失败"}];
        return nil;
    }
    
}

#pragma -mark 写卡信息
/**
 写57卡一表一卡信息--requestData
 */
- (NSData *)write57OneMeterOneCardWithCardInfoData:(NSData *)cardInfoData writeInfo:(XT57WriteInfo *)writeInfo {
    
    NSString *readInfo = [XTUtils hexStringWithData:cardInfoData];
    NSString *dataStr = [readInfo substringWithRange:NSMakeRange(6, 48)];
    /**
     *  把要发送的帧数据分为三部分：帧头、卡数据、帧尾。即：start、mid、end
     *  mid部分为卡数据信息，以校验和为间隔，可以分为：midBegin、midCenter、midEnd
     *  帧头部分三个字节：0x68，控制码为0x04，数据长度0x18.
     */
    NSString *start = @"680418";
    NSMutableString *mid = [[NSMutableString alloc] init];
    NSString *end = @"";
    
    long nowT;
    
    NSString *type = [[dataStr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
    if ([type isEqualToString:@"6A"]) {
        //一表一卡计金额
        long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(32, 6)]]]];
        nowT = [writeInfo.rechargeMoney longLongValue] + totalRead;
        //[mid appendString:[dataStr substringWithRange:NSMakeRange(0, 32)]];
        //用户卡0-3
        [mid appendString:[dataStr substringWithRange:NSMakeRange(0, 8)]];
        //分界点1、2低字节
        NSString *hexDivid1 = [XTUtils hexStringWithData:[XTUtils dataWithLong:[writeInfo.divid1 longLongValue] length:2]];
        NSString *hexDivid2 = [XTUtils hexStringWithData:[XTUtils dataWithLong:[writeInfo.divid2 longLongValue] length:2]];
        [mid appendString:[hexDivid1 substringWithRange:NSMakeRange(2, 2)]];
        [mid appendString:[hexDivid2 substringWithRange:NSMakeRange(2, 2)]];
        //单价
        long price1 = [writeInfo.price1 longLongValue];
        [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:price1 length:2]]]];
        long price2 = [writeInfo.price2 longLongValue];
        [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:price2 length:2]]]];
        long price3 = [writeInfo.price3 longLongValue];
        [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:price3 length:2]]]];
        //报警值
        [mid appendString:[XTUtils hexStringWithData:[XTUtils dataWithLong:[writeInfo.warn longLongValue]/100 length:1]]];
        //分界点1、2高字节
        [mid appendString:[hexDivid1 substringWithRange:NSMakeRange(0, 2)]];
        [mid appendString:[hexDivid2 substringWithRange:NSMakeRange(0, 2)]];
        //用户卡13-15
        [mid appendString:[dataStr substringWithRange:NSMakeRange(30, 2)]];
        //总
        [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:3]]]];
        //透支
        [mid appendString:[dataStr substringWithRange:NSMakeRange(38, 2)]];
        //本次
        [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:[writeInfo.rechargeMoney longLongValue] length:3]]]];
        
        //校验和取反加1
        NSString *sum = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:mid]]];
        [mid appendString:sum];
        
    } else if ([type hasPrefix:@"6"]) {
        //一表一卡计量
        if ([type hasPrefix:@"66"]) {
            //FS型计量
            long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(8, 8)]]]];
            nowT = [writeInfo.rechargeCount longLongValue] + totalRead;
            //用户卡的 0-3
            [mid appendString:[dataStr substringWithRange:NSMakeRange(0, 8)]];
            //总
            [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:4]]]];
            //本次：DHH + DL + DH
            NSString *tempStr = [XTUtils hexStringWithData:[XTUtils dataWithLong:[writeInfo.rechargeCount longLongValue] length:3]];
            NSString *thisStr = [NSString stringWithFormat:@"%@%@%@",[tempStr substringWithRange:NSMakeRange(0, 2)],[tempStr substringWithRange:NSMakeRange(4, 2)],[tempStr substringWithRange:NSMakeRange(2, 2)]];
            [mid appendFormat:@"%@",thisStr];
            
            //校验和取反加1
            NSString *sum = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:mid]]];
            [mid appendString:sum];
            
            //用户卡12-22
            [mid appendString:[dataStr substringWithRange:NSMakeRange(24, 22)]];
    
            //第二个校验和
            NSString *sum2 = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:mid]]];
            [mid appendString:sum2];
            
        } else {
            //普通计量
            long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:NSMakeRange(8, 6)]]]];
            nowT = [writeInfo.rechargeCount longLongValue] + totalRead;
            //用户卡的 0-3
            [mid appendString:[dataStr substringWithRange:NSMakeRange(0, 8)]];
            //总量
            [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:3]]]];
            //用户卡7-8
            [mid appendString:[dataStr substringWithRange:NSMakeRange(14, 4)]];
            //本次
            [mid appendFormat:@"%@",[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:[writeInfo.rechargeCount longLongValue] length:2]]]];
            
            //校验和取反加1
            NSString *sum = [XTUtils hexStringWithData:[XTUtils checkNegationGalOneSumDataWithOriginData:[XTUtils dataWithHexString:mid]]];
            [mid appendString:sum];
            
            //校验和+用户卡12-23
            
            //报警量替换
            long newWarn = [writeInfo.warn longLongValue];
            [mid appendString:[XTUtils hexStringWithData:[XTUtils dataWithLong:newWarn length:1]]];
            
            [mid appendString:[dataStr substringWithRange:NSMakeRange(26, 22)]];
    
        }
        
    }
    
    end = [XTUtils hexStringWithData:[XTUtils checksumDataWithOriginData:[XTUtils dataWithHexString:[NSString stringWithFormat:@"%@%@",start,mid]]]];
    
    return [XTUtils dataWithHexString:[NSString stringWithFormat:@"%@%@%@16",start, mid, end]];
    
}

/**
 写57卡一卡通信息--requestData
 */
- (NSData *)write57OneCardMultipleMeterWithCardInfoData:(NSData *)cardInfoData rechargeMoney:(NSString *)rechargeMoney rechargeCount:(NSString *)rechargeCount cardSector:(int)cardSector cardType:(int)cardType {
    
    NSString *readInfo = [XTUtils hexStringWithData:cardInfoData];
    NSString *dataStr = [readInfo substringWithRange:NSMakeRange(6, 48)];
    /**
     *  把要发送的帧数据分为三部分：帧头、卡数据、帧尾。即：start、mid、end
     *  mid部分为卡数据信息，以校验和为间隔，可以分为：midBegin、midCenter、midEnd
     *  帧头部分三个字节：0x68，控制码为0x04，数据长度0x18.
     */
    NSString *start = @"680418";
    NSString *mid = @"";
    NSString *end = @"";
    
    long nowR;
    long nowT;
    
    NSString *type = [[dataStr substringWithRange:NSMakeRange(0, 2)] uppercaseString];
    if ([type isEqualToString:@"DA"]) {
        //一卡通
        mid = dataStr;
        
        NSRange totalRange;
        NSRange thisRange;
        
        if (cardSector == 1) {
            //卡区1
            thisRange = NSMakeRange(8, 4);
            totalRange = NSMakeRange(12, 4);
        } else if (cardSector == 2) {
            //卡区2
            thisRange = NSMakeRange(16, 4);
            totalRange = NSMakeRange(20, 4);
        } else if (cardSector == 3) {
            //卡区3
            thisRange = NSMakeRange(24, 4);
            totalRange = NSMakeRange(28, 4);
        } else if (cardSector == 4) {
            //卡区4
            thisRange = NSMakeRange(32, 4);
            totalRange = NSMakeRange(36, 4);
        } else {
            //卡区5
            thisRange = NSMakeRange(40, 4);
            totalRange = NSMakeRange(44, 4);
        }
        
        long totalRead = [XTUtils longWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithHexString:[dataStr substringWithRange:totalRange]]]];
        if (cardType == 1) {
            //计量
            nowT = [rechargeCount longLongValue] + totalRead;
            nowR = [rechargeCount longLongValue];
        } else {
            //计金额(传入值单位为分，这里直接转换单位为元)
            nowT = [rechargeMoney longLongValue]/100 + totalRead;
            nowR = [rechargeMoney longLongValue]/100;
        }
        
        mid = [mid stringByReplacingCharactersInRange:totalRange withString:[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowT length:2]]]];
        mid = [mid stringByReplacingCharactersInRange:thisRange withString:[XTUtils hexStringWithData:[XTUtils reverseDataWithOriginData:[XTUtils dataWithLong:nowR length:2]]]];
        
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

/**
 根据卡标志获取卡类型

 @param cardFlag 卡标志
 @return 卡类型
 */
- (int)getCardTypeWithCardFlag:(NSString *)cardFlag {
    
    NSString *upperCardFlag = [cardFlag uppercaseString];
    if ([upperCardFlag isEqualToString:@"6A"]) {
        //一表一卡阶梯
        return 5;
    } else if ([upperCardFlag hasPrefix:@"6"]) {
        //气表计量 || 水表计量
        return 2;
    } else if ([upperCardFlag isEqualToString:@"DA"]) {
        //一卡通
        return 1;
    } else if ([upperCardFlag isEqualToString:@""]) {
        //一卡通阶梯
        return 4;
    } else {
        //未知卡类型
        return 0;
    }
    
}

@end
