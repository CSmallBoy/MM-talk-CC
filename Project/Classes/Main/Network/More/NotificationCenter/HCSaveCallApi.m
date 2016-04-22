//
//  HCSaveCallApi.m
//  Project
//
//  Created by 朱宗汉 on 16/4/22.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

#import "HCSaveCallApi.h"

@implementation HCSaveCallApi

-(void)startRequest:(HCSaveCallBlock)requestBlock
{
    [super startRequest:requestBlock];
}

-(NSString *)requestUrl
{
    return @"CallReply/favor.do";
}

-(id)requestArgument
{
    NSDictionary *head = @{@"platForm":[readUserInfo GetPlatForm],
                           @"token":[HCAccountMgr manager].loginInfo.Token,
                           @"UUID":[HCAccountMgr manager].loginInfo.UUID};
    
    NSDictionary *para = @{@"callId":_callId};
    
    return @{@"Head":head,
             @"Para":para};
}

-(id)formatResponseObject:(id)responseObject
{
    return responseObject;
}


@end
