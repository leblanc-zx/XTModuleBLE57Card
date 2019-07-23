//
//  XT57OneCardMultipleMeter.h
//  AFNetworking
//
//  Created by apple on 2019/6/27.
//

@interface XT57CardSector : NSObject

@property (nonatomic, assign) long totalRead;   //卡区总量
@property (nonatomic, assign) long thisRead;    //卡区本次购量
@property (nonatomic, assign) int cardType;     //卡区卡类型
@property (nonatomic, assign) BOOL isBrushed;   //卡区是否已刷表

@end

@interface XT57OneCardMultipleMeter : NSObject

@property (nonatomic, strong) NSData *originCardData;       //卡帧数据
@property (nonatomic, strong) NSString *cardNumber;         //卡号
@property (nonatomic, strong) NSString *cardFlag;           //卡标志(用户卡：6A:计金额、66:FS型计量、6*:普通计量、DA一卡通；A0检查卡；EA应急卡)
@property (nonatomic, strong) NSString *systemNumber;       //系统号
@property (nonatomic, strong) XT57CardSector *sector1;      //卡区1
@property (nonatomic, strong) XT57CardSector *sector2;      //卡区2
@property (nonatomic, strong) XT57CardSector *sector3;      //卡区3
@property (nonatomic, strong) XT57CardSector *sector4;      //卡区4
@property (nonatomic, strong) XT57CardSector *sector5;      //卡区5

@end

