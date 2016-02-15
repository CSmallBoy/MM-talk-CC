//
//  HCPromisedAddCell.h
//  Project
//
//  Created by 朱宗汉 on 16/1/5.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HCPromisedListInfo;
typedef void (^block)(NSString *title,HCPromisedListInfo *info);


@interface HCPromisedAddCell : UITableViewCell


@property(nonatomic,assign) CGFloat  buttonH;
@property(nonatomic,copy)NSString  *title;
@property(nonatomic,strong) HCPromisedListInfo *info;
@property(nonatomic,strong)block  block;

+(instancetype)customCellWithTable:(UITableView *)tableView;


@end