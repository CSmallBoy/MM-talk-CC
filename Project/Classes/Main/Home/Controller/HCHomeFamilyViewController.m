 //
//  HCHomeViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/15.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCHomeFamilyViewController.h"
#import "HCHomeDetailViewController.h"
#import "HCShareViewController.h"
#import "HCHomeUserTimeViewController.h"
#import "HCEditCommentViewController.h"
#import "HCHomePictureDetailViewController.h"
#import "MJRefresh.h"
#import "HCWelcomeJoinGradeViewController.h"
#import "HCHomeTableViewCell.h"
#import "HCHomeInfo.h"
#import "HCHomeApi.h"
#import "HCHomeLikeCountApi.h"
//下载 时光的图片
#import "NHCDownLoadManyApi.h"
#import "NHCListOfTimeAPi.h"

#import "HCCreateGradeViewController.h"

#define HCHomeCell @"HCHomeTableViewCell"

@interface HCHomeFamilyViewController ()<HCHomeTableViewCellDelegate>{
    NSMutableArray *arr_image_all;
}

@property (nonatomic, strong) NSString *start;

@property (nonatomic, strong) HCWelcomeJoinGradeViewController *welcomJoinGrade;

@end

@implementation HCHomeFamilyViewController

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    arr_image_all = [NSMutableArray array];
    [self readLocationData];
    
    self.tableView.tableHeaderView = HCTabelHeadView(0.1);
    [self.tableView registerClass:[HCHomeTableViewCell class] forCellReuseIdentifier:HCHomeCell];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestHomeData)];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(requestMoreHomeData)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HCHomeCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    cell.delegate = self;
    HCHomeInfo *info = self.dataSource[indexPath.section];
    cell.info = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCHomeInfo *info = self.dataSource[indexPath.section];
    HCHomeDetailViewController *detail = [[HCHomeDetailViewController alloc] init];
    detail.data = @{@"data": info};
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 60 + WIDTH(self.view)*0.15;
    
    HCHomeInfo *info = self.dataSource[indexPath.section];
    
    height = height + [Utils detailTextHeight:info.FTContent lineSpage:4 width:WIDTH(self.view)-20 font:14];
    //暂时行不通
//    if (!IsEmpty(arr_image_all[indexPath.section])) {
//        NSArray *Arr = arr_image_all[indexPath.section];
//        if (Arr.count < 5)
//        {
//            NSInteger row = ((int)Arr.count/3) + 1;
//            height += WIDTH(self.view) * 0.33 * row;
//        }else
//        {
//            NSInteger row = ((int)MIN(Arr.count, 9)/3.5) + 1;
//            height += WIDTH(self.view) * 0.33 * row;
//        }
//    }
    if (!IsEmpty(info.FTImages))
    {
        if (info.FTImages.count < 5)
        {
            NSInteger row = ((int)info.FTImages.count/3) + 1;
            height += WIDTH(self.view) * 0.33 * row;
        }else
        {
            NSInteger row = ((int)MIN(info.FTImages.count, 9)/3.5) + 1;
            height += WIDTH(self.view) * 0.33 * row;
        }
    }
    
    if (!IsEmpty(info.CreateAddrSmall))
    {
        height = height + 30;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - HCHomeTableViewCellDelegate

- (void)hcHomeTableViewCell:(HCHomeTableViewCell *)cell indexPath:(NSIndexPath *)indexPath functionIndex:(NSInteger)index
{
    HCHomeInfo *info = self.dataSource[indexPath.section];

    if (index == 2)
    {
        HCEditCommentViewController *editComment = [[HCEditCommentViewController alloc] init];
        editComment.data = @{@"data": info};
        UIViewController *rootController = self.view.window.rootViewController;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            editComment.modalPresentationStyle=
            UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
        }else
        {
            rootController.modalPresentationStyle=
            UIModalPresentationCurrentContext|UIModalPresentationFullScreen;
        }
        [rootController presentViewController:editComment animated:YES completion:nil];
    }else if (index == 1)
    {
        HCShareViewController  *shareVC = [[HCShareViewController alloc] init];
        [self presentViewController:shareVC animated:YES completion:nil];
    }else if (index == 0)
    {
        [self requestLikeCount:info indexPath:indexPath];
    }
}

- (void)hcHomeTableViewCell:(HCHomeTableViewCell *)cell indexPath:(NSIndexPath *)indexPath moreImgView:(NSInteger)index
{
    HCHomePictureDetailViewController *pictureDetail = [[HCHomePictureDetailViewController alloc] init];
    pictureDetail.data = @{@"data": self.dataSource[indexPath.section], @"index": @(index)};
    pictureDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pictureDetail animated:YES];
}

- (void)hcHomeTableViewCell:(HCHomeTableViewCell *)cell indexPath:(NSIndexPath *)indexPath seleteHead:(UIButton *)headBtn
{
    HCHomeInfo *info = self.dataSource[indexPath.section];
    HCHomeUserTimeViewController *userTime = [[HCHomeUserTimeViewController alloc] init];
    userTime.data = @{@"data": info};
    userTime.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userTime animated:YES];
}

#pragma mark - private methods

- (void)readLocationData
{
    NSString *path = [self getSaveLocationDataPath];
    NSArray *arrayData = [NSArray arrayWithContentsOfFile:path];

    [self.dataSource addObjectsFromArray:[HCHomeInfo mj_objectArrayWithKeyValuesArray:arrayData]];
    [self.tableView reloadData];
    [self requestHomeData];
}

- (NSString *)getSaveLocationDataPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"homedata.plist"];
}

- (void)writeLocationData:(NSArray *)array
{
    NSString *path = [self getSaveLocationDataPath];
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
    for (NSInteger i = 0; i < array.count; i++)
    {
        HCHomeInfo *info = array[i];
        NSDictionary *dic = [info mj_keyValues];
        [arrayM addObject:dic];
    }
    [arrayM writeToFile:path atomically:YES];
}

#pragma mark - setter or getter

- (void)setGradeId:(NSString *)gradeId
{
    if (!IsEmpty(gradeId))
    {
        _welcomJoinGrade = [[HCWelcomeJoinGradeViewController alloc] init];
        _welcomJoinGrade.gradeId = [NSString stringWithFormat:@"欢迎加入%@班级", gradeId];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIViewController *rootController = window.rootViewController;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
          _welcomJoinGrade.modalPresentationStyle=
          UIModalPresentationOverCurrentContext|UIModalPresentationFullScreen;
        }else
        {
          rootController.modalPresentationStyle=
          UIModalPresentationCurrentContext|UIModalPresentationFullScreen;
        }
      [_welcomJoinGrade setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
      [rootController presentViewController:_welcomJoinGrade animated:YES completion:nil];
    }
}

#pragma mark - network
- (void)getData{
    NHCListOfTimeAPi *api = [[NHCListOfTimeAPi alloc]init];
    
    [api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id data) {
        
    }];
}
- (void)requestHomeData
{
    NHCListOfTimeAPi *api = [[NHCListOfTimeAPi alloc]init];
    api.start_num = @"0";
    [api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id Data) {
                [self.tableView.mj_header endRefreshing];
        
                    [self.dataSource removeAllObjects];
                    [self.dataSource addObjectsFromArray:Data];
    
                    [self.tableView reloadData];
    }];
//    NHCListOfTimeAPi *api = [[NHCListOfTimeAPi alloc]init];
//    api.start_num = @"0";
//    [api startRequest:^(HCRequestStatus resquestStatus, NSString *message, id Data) {
//        [self.tableView.mj_header endRefreshing];
//        [self.dataSource removeAllObjects];
//   
//        NSArray *arr = Data[@"Data"][@"rows"];
//        NSMutableArray *arring = [NSMutableArray array];
//        for (int i = 0 ; i < arr.count; i ++) {
//            HCHomeInfo *info = [[HCHomeInfo alloc]init];
//            info.FTContent = arr[i][@"content"];
//            info.TimeID = arr[i][@"timesId"];
//            info.CreateAddrSmall = arr[i][@"createAddrSmall"];
//            info.NickName = arr[i][@"creatorName"];
//            info.CreateTime = arr[i][@"createTime"];
//            info.TimeID = arr[i][@"timesId"];
//            //这一步应该放到最后
//            //[arring addObject:info];
//           
//            NHCDownLoadManyApi *api = [[NHCDownLoadManyApi alloc]init];
//            
//            api.TimeID = info.TimeID;
//            NSMutableArray *arr_ftImages= [NSMutableArray array];
//            [api startRequest:^(HCRequestStatus requestStatus, NSString *message, NSArray *array) {
//                
//                for (int i = 0; i < array.count; i++) {
//                    if (i==0) {
//                        //出去没用图片
//                    }else{
//                        //这里是  图片 uiimage
//                        if (IsEmpty(array[i])) {
//                            
//                        }else{
//                            [arr_ftImages addObject:[readUserInfo image64:array[i]]];
//                        }
//                       
//                    }
//                }
//                //图片赋值因为  有空值 要进行判断   设置一个通知  下载完成后  添加到[self.dataSource addObjectsFromArray:arring];  然后再刷新
//                info.FTImages = arr_ftImages;
//                //不在这个地方写
//            }];
//
//            [arring addObject:info];
//            [self.dataSource addObjectsFromArray:arring];
//            [self.tableView reloadData];
//            
//        }

       // 在下载图片中执行这个操作 [self.dataSource addObjectsFromArray:array];
        //所有时光图片  arr_image_all
        
        //在此处获取到 时光的东西找到对用的timeId 然后在加载
//        for (int i = 0; i < array.count; i ++) {
//            NHCDownLoadManyApi *api = [[NHCDownLoadManyApi alloc]init];
//            HCHomeInfo *info = self.dataSource[i];
//            api.TimeID = info.TimeID;
//             NSMutableArray *arr_ftImages= [NSMutableArray array];
//            [api startRequest:^(HCRequestStatus requestStatus, NSString *message, NSArray *array) {
//               
//                for (int i = 0; i < array.count; i++) {
//                    if (i==0) {
//                        //出去没用图片
//                    }else{
//                        //这里是  图片 uiimage
//                        [arr_ftImages addObject:[readUserInfo image64:array[i]]];
//                    }
//                }
//                [self.tableView reloadData];
//                
//            }];
//            [arr_image_all addObject:arr_ftImages];
//            
//        }
//        
//       
        
        
        
//        HCHomeInfo *lastInfo = [array lastObject];
//        api.start_num = lastInfo.KeyId;
//        [self writeLocationData:array];
        
            
//    HCHomeApi *api = [[HCHomeApi alloc] init];
//    api.Start = @"0";
//    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, NSArray *array) {
//        [self.tableView.mj_header endRefreshing];
//
//            [self.dataSource removeAllObjects];
//            [self.dataSource addObjectsFromArray:array];
//            
//            HCHomeInfo *lastInfo = [array lastObject];
//            api.Start = lastInfo.KeyId;
//            
//            [self writeLocationData:array];
//            [self.tableView reloadData];
//    }];
    _baseRequest = api;
}

- (void)requestMoreHomeData
{
    HCHomeApi *api = [[HCHomeApi alloc] init];
    api.Start = _start;
    
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, NSArray *array) {
        [self.tableView.mj_footer endRefreshing];
        if (requestStatus == HCRequestStatusSuccess)
        {
            [self.dataSource addObjectsFromArray:array];
            
            HCHomeInfo *lastInfo = [array lastObject];
            api.Start = lastInfo.KeyId;
            
            [self writeLocationData:array];
            [self.tableView reloadData];
        }else
        {
            [self showHUDError:message];
        }
    }];
}

// 请求点赞
- (void)requestLikeCount:(HCHomeInfo *)info indexPath:(NSIndexPath *)indexPath
{
    HCHomeLikeCountApi *api = [[HCHomeLikeCountApi alloc] init];
    api.TimesId = info.KeyId;
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, id responseObject) {
        if (requestStatus == HCRequestStatusSuccess)
        {
            info.FTLikeCount = [NSString stringWithFormat:@"%@", @([info.FTLikeCount integerValue]+1)];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else
        {
            [self showHUDError:message];
        }
    }];
}



@end
