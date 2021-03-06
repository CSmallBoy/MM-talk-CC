//
//  HCAddressApi.m
//  Project
//
//  Created by 朱宗汉 on 15/12/24.
//  Copyright © 2015年 com.xxx. All rights reserved.
//收货地址

#import "HCAddressApi.h"
#import "HCAddressInfo.h"

@implementation HCAddressApi


- (void)startRequest:(HCAddressBlock)requestBlock
{
    [super startRequest:requestBlock];
}


//测试
- (NSString *)requestUrl
{
    return @"HelpCase/HelpCase.ashx";
}


- (id)requestArgument
{
    NSDictionary *head = @{@"Action" : @"GetList"};
    
    NSDictionary *result = @{@"Start" : @(1000), @"Count" : @(20)};
    NSDictionary *bodyDic = @{@"Head" : head, @"Result" : result};
    
    return @{@"json": [Utils stringWithObject:bodyDic]};
}

- (id)formatResponseObject:(id)responseObject
{
    HCAddressInfo *info = [[HCAddressInfo alloc] init];
    info.consigneeName = @"Tom";
    info.phoneNumb = @"12345678907 ";
    info.postcode = @"100000";
    info.receivingCity = @"江苏省南京市玄武区";
    info.receivingStreet = @"XX镇北京东路XXXX号XX楼XX室";
  
    
    return info;
}


@end
