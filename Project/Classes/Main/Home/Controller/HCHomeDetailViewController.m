//
//  HCHomeDetailViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/17.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCHomeDetailViewController.h"
#import "HCEditCommentViewController.h"
#import "HCHomeDetailTableViewCell.h"
#import "HCHomePictureDetailViewController.h"
#import "HCHomeDetailCommentTableViewCell.h"
#import "HCHomeDetailInfo.h"
#import "HCHomeDetailUserInfo.h"
#import "HCHomeInfo.h"
#import "HCHomeDetailApi.h"
//评论列表
#import "NHCHomeCommentListApi.h"
//下边功能按钮
#import "HCFunctionTagView.h"
#define HCHomeDetailCell @"HCHomeDetailTableViewCell"
#define HCHomeDetailComment @"HCHomeDetailCommentTableViewCell"

@interface HCHomeDetailViewController ()<HCHomeDetailCommentTableViewCellDelegate, HCHomeDetailTableViewCellDelegate>

@property (nonatomic, strong) HCHomeDetailInfo *detailInfo;
@property (nonatomic, assign) CGFloat praiseHeight;

@property (nonatomic, assign) CGFloat commentHeight;

@end

@implementation HCHomeDetailViewController
- (void)viewWillAppear:(BOOL)animated{
    //[self requestHomeDetail];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestHomeDetail) name:@"刷新数据" object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"时光详情";
    [self setupBackItem];
    [self requestHomeDetail];
    [self makefootView];
    self.tableView.tableHeaderView = HCTabelHeadView(0.1);
    [self.tableView registerClass:[HCHomeDetailCommentTableViewCell class] forCellReuseIdentifier:HCHomeDetailComment];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    [cell.contentView removeFromSuperview];
    if (indexPath.section == 0)
    {
        HCHomeDetailTableViewCell *detailCell = [[HCHomeDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HCHomeDetailCell];
        detailCell.praiseHeight = _praiseHeight;
        detailCell.delegates = self;
        detailCell.praiseArr = _detailInfo.praiseArr;  //这个是要传点赞人的信息的
        HCHomeInfo *info = self.data[@"data"];
        if ([_MySelf isEqualToString:@"我自己的时光"]) {
            detailCell.isDelete = YES;
        }
        detailCell.info = info;
        cell = detailCell;
    }else
    {
        //移除所有的
        [cell.contentView removeFromSuperview];
        
        //            HCHomeDetailCommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:HCHomeDetailComment];
        HCHomeDetailCommentTableViewCell *commentCell = [[HCHomeDetailCommentTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HCHomeDetailComment];
        commentCell.delegate = self;
        commentCell.info = _detailInfo.commentsArr[indexPath.row];
        commentCell.timeID = _timeID;
        HCHomeInfo *infooo = commentCell.info;
        commentCell.toUSer = infooo.TOUSER;
        cell = commentCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1 + _detailInfo.commentsArr.count;
    //评论
    if (_detailInfo.commentsArr.count==0) {
        return 1;
    }else{
        return 2;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (IsEmpty(_detailInfo))
    {
        return 0;
    }
    return (section) ? _detailInfo.commentsArr.count : 1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        CGFloat height = 30 + WIDTH(self.view)*0.15;
        HCHomeInfo *info = self.data[@"data"];
        height = height + [Utils detailTextHeight:info.FTContent lineSpage:4 width:WIDTH(self.view)-20 font:14];
        if (!IsEmpty(info.FTImages))
        {
            height = height + (WIDTH(self.view)-40)/3 + 13;
        }
        if (!IsEmpty(_detailInfo.praiseArr))
        {
            height = height + [self getPraiseHeight];
        }
        return height;
    }else
    {
        return _commentHeight + 70;
    }
    return 0;
}

- (CGFloat)getPraiseHeight
{
    CGRect previousFrame = CGRectMake(10, 0, WIDTH(self.view)-20, 0);
    CGFloat totalHeight = 0;
    NSMutableArray *array = [NSMutableArray array];
    array = [NSMutableArray arrayWithArray:_detailInfo.praiseArr];
    for (int  i = 0; i < array.count; i++)
    {
        //        HCHomeDetailUserInfo *info = _detailInfo.praiseArr[i];
        //        NSString *title = nil;
        //        if (i != _detailInfo.praiseArr.count - 1)
        //        {
        //            title = [NSString stringWithFormat:@"%@、", info.nickName];
        //        }else
        //        {
        //            title = info.nickName;
        //        }
        NSString *title = array[i];
        NSDictionary *attriDic = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
        CGSize size_value = [title sizeWithAttributes:attriDic];
        size_value.width ++;
        size_value.height ++;
        CGRect newRect = CGRectZero;
        if (previousFrame.origin.x+previousFrame.size.width+size_value.width > WIDTH(self.view)-20)
        {
            newRect.origin = CGPointMake(0, previousFrame.origin.y + size_value.height);
            totalHeight += size_value.height ;
        }
        else
        {
            newRect.origin = CGPointMake(previousFrame.origin.x+previousFrame.size.width, previousFrame.origin.y);
        }
        
        newRect.size = size_value;
        previousFrame = newRect;
        _praiseHeight = totalHeight;
    }
    return _praiseHeight;
}

#pragma mark -  HCHomeDetailTableViewCellDelegate
//第几张图片
- (void)hchomeDetailTableViewCellSelectedImage:(NSInteger)index
{
    HCHomeInfo *info = self.data[@"data"];
    HCHomePictureDetailViewController *pictureDetail = [[HCHomePictureDetailViewController alloc] init];
    pictureDetail.data = @{@"data": info, @"index": @(index)};
    pictureDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:pictureDetail animated:YES];
}

- (void)hchomeDetailTableViewCellSelectedTagWithUserid:(NSInteger)index
{
    [self showHUDText:[NSString stringWithFormat:@"点击了id为--%@--的用户", @(index)]];
}

#pragma mark - HCHomeDetailCommentTableViewCellDelegate 跳向评论的代理方法

- (void)hchomeDetailCommentTableViewCellCommentHeight:(CGFloat)commentHeight
{
    _commentHeight = commentHeight;
}
////这个方法暂时没有用到
- (void)hchomeDetailCommentTableViewCellCommentButton
{
    HCEditCommentViewController *editComment = [[HCEditCommentViewController alloc] init];
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
    //总的评论传的参数
    editComment.all_coment_to = @"评论时光的回复";
    //editComment.time_id ;
    HCHomeInfo *info = self.data[@"data"];
    //传一个timeid
    editComment.time_id = info.TimeID;
    //再传一个
    
    [rootController presentViewController:editComment animated:YES completion:nil];
}
- (void)makefootView{
    //    HCFunctionTagView *view = [[HCFunctionTagView alloc]init];
    //    view.frame = CGRectMake(0, SCREEN_HEIGHT - 49, SCREEN_WIDTH, 49);
    //    view.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:view];
}
#pragma mark - network
//获取评论
- (void)requestHomeDetail
{
    //[self showHUDView:nil];
    HCHomeInfo *info = self.data[@"data"];
    NHCHomeCommentListApi *api = [[NHCHomeCommentListApi alloc]init];
    api.TimeID = info.TimeID;
    api.arring = _islikeArr;
    [api startRequest:^(HCRequestStatus requestStatus, NSString *message, HCHomeDetailInfo *info) {
        if (requestStatus == HCRequestStatusSuccess)
        {
            [self hideHUDView];
            [self.dataSource removeAllObjects];
            _detailInfo = info;
            [self.tableView reloadData];
        }else
        {
            [self showHUDError:message];
        }
    }];
    
}

-(void)delete
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
