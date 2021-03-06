//
//  XTUtils+Date.h
//  XTGeneralModule
//
//  Created by apple on 2018/11/8.
//  Copyright © 2018年 新天科技股份有限公司. All rights reserved.
//

#import "XTUtils.h"

NS_ASSUME_NONNULL_BEGIN

@interface XTUtils (Date)

/**
 根据时间字符串获取date
 
 @param timeString 时间字符串
 @param formatter 时间格式
 @return NSDate
 */
+ (NSDate *)dateFromTimeString:(NSString *)timeString formatter:(NSString *)formatter;

/**
 根据date获取时间字符串
 
 @param date NSDate
 @param formatter 时间格式
 @return 时间字符串
 */
+ (NSString *)timeStringFromDate:(NSDate *)date formatter:(NSString *)formatter;

/**
 计算两个日期时间间隔 <<秒>>
 
 @param sinceTime 开始时间字符串
 @param toTime 结束时间字符串
 @param formatter 时间格式
 @return 时间间隔<<秒>>
 */
+ (long long)timeIntervalSinceTime:(NSString *)sinceTime toTime:(NSString *)toTime formatter:(NSString *)formatter;

/**
 计算两个日期时间间隔 <<秒>>
 
 @param sinceDate 开始时间Date
 @param toDate 结束时间Date
 @return 时间间隔<<秒>>
 */
+ (long long)timeIntervalSinceDate:(NSDate *)sinceDate toDate:(NSDate *)toDate;

/**
 获取最新时间 = 时间间隔 + 开始时间
 
 @param timeInterval 时间间隔
 @param sinceTime 开始时间字符串
 @param formatter 时间格式
 @return 新时间字符串
 */
+ (NSString *)timeStringWithTimeInterval:(long long)timeInterval sinceTime:(NSString *)sinceTime formatter:(NSString *)formatter;

/**
 获取最新时间 = 时间间隔 + 1970年开始
 
 @param timeInterval 时间间隔
 @param formatter 时间格式
 @return 新时间字符串
 */
+ (NSString *)timeStringWithTimeIntervalSince1970:(long long)timeInterval formatter:(NSString *)formatter;

/**
 获取某月月初&月末
 
 @param monthBegin 月初
 @param monthEnd 月末
 @param date 某月date
 */
+ (void)monthBegin:(NSDate **)monthBegin monthEnd:(NSDate **)monthEnd forDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
