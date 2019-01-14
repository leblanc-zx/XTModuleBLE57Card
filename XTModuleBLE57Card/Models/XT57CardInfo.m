//
//  XT57CardInfo.m
//  QuickTopUp
//
//  Created by apple on 2018/6/1.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "XT57CardInfo.h"
#import <objc/runtime.h>

@implementation XT57CardInfo

@end

@implementation XT57CardInfo (Amount)
@dynamic remainedCount;
@dynamic overCount;
@dynamic warnCount;

- (void)setRemainedCount:(long)remainedCount {
    objc_setAssociatedObject(self, @selector(remainedCount), @(remainedCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)remainedCount {
    return [objc_getAssociatedObject(self, @selector(remainedCount)) longLongValue];
}

- (void)setOverCount:(long)overCount {
    objc_setAssociatedObject(self, @selector(overCount), @(overCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)overCount {
    return [objc_getAssociatedObject(self, @selector(overCount)) longLongValue];
}

- (void)setWarnCount:(long)warnCount {
    objc_setAssociatedObject(self, @selector(warnCount), @(warnCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)warnCount {
    return [objc_getAssociatedObject(self, @selector(warnCount)) longLongValue];
}

@end

@implementation XT57CardInfo (Money)
@dynamic remainedMoney;
@dynamic overMoney;
@dynamic warnMoney;

- (void)setRemainedMoney:(long)remainedMoney {
    objc_setAssociatedObject(self, @selector(remainedMoney), @(remainedMoney), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)remainedMoney {
    return [objc_getAssociatedObject(self, @selector(remainedMoney)) longLongValue];
}

- (void)setOverMoney:(long)overMoney {
    objc_setAssociatedObject(self, @selector(overMoney), @(overMoney), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)overMoney {
    return [objc_getAssociatedObject(self, @selector(overMoney)) longLongValue];
}

- (void)setWarnMoney:(long)warnMoney {
    objc_setAssociatedObject(self, @selector(warnMoney), @(warnMoney), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (long)warnMoney {
    return [objc_getAssociatedObject(self, @selector(warnMoney)) longLongValue];
}

@end
