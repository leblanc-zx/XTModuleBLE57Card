//
//  XT57OneMeterOneCard.h
//  AFNetworking
//
//  Created by apple on 2019/6/27.
//

/** 57一表一卡信息*/
@interface XT57OneMeterOneCard : NSObject

@property (nonatomic, strong) NSData *originCardData;       //卡帧数据
@property (nonatomic, strong) NSString *cardNumber;         //卡号
@property (nonatomic, strong) NSString *cardFlag;           //卡标志(用户卡：6A:计金额、66:FS型计量、6*:普通计量、DA一卡通；A0检查卡；EA应急卡)
@property (nonatomic, strong) NSString *systemNumber;       //系统号
@property (nonatomic, assign) int cardType;                 //卡类型(1:一卡通、2:一表一卡、4:一卡通阶梯、5:一表一卡阶梯)
@property (nonatomic, assign) long totalRead;               //总量(或金额)
@property (nonatomic, assign) long thisRead;                //本次购量(或金额)
@property (nonatomic, assign) BOOL isBrushed;               //是否已刷表

@end

/** 57一表一卡计量卡信息*/
@interface XT57OneMeterOneCard (Amount)

@property (nonatomic, assign) long remainedCount;       //剩余量
@property (nonatomic, assign) long overCount;           //透支量
@property (nonatomic, assign) long warnCount;           //报警量

@end

/** 57一表一卡计金额卡信息*/
@interface XT57OneMeterOneCard (Money)

@property (nonatomic, assign) long remainedMoney;       //剩余金额
@property (nonatomic, assign) long overMoney;           //透支金额
@property (nonatomic, assign) long warnMoney;           //报警金额

@end

