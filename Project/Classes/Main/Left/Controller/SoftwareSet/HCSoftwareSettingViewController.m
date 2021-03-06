//
//  HCSoftwareSettingViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/19.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCSoftwareSettingViewController.h"
#import "HCJurisdictionViewController.h"
#import "HCFeedbackViewController.h"
#import "HCFeedbackView.h"
#import "HCAboutMTalkViewController.h"

@interface HCSoftwareSettingViewController ()

@property (nonatomic, strong) NSDictionary *imageNameDic;
@property (nonatomic, strong) NSDictionary *titleDic;
@property (nonatomic, strong) UISwitch *switchs;
@property (nonatomic,strong) UIButton * blackView;// 黑色蒙层
@property (nonatomic,strong)  UIView * whiteView;
@end

@implementation HCSoftwareSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"软件设置";
    [self setupBackItem];
    
    self.tableView.tableHeaderView = HCTabelHeadView(0.1);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"sofeware"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sofeware"];
    
    NSArray *imageNameArr = self.imageNameDic[[NSString stringWithFormat:@"%@", @(indexPath.section+1)]];
    cell.imageView.image = OrigIMG(imageNameArr[indexPath.row]);
    
    NSArray *titleArr = self.titleDic[[NSString stringWithFormat:@"%@", @(indexPath.section+1)]];
    cell.textLabel.text = titleArr[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 )
        {
            UISwitch *switchs = self.switchs;
            [cell.contentView addSubview:switchs];
            switchs.tag = indexPath.row;
        }else if (indexPath.row == 3)
        {
            cell.detailTextLabel.text = @"仅好友可见";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 3)
    {
        [self handleLogoutButton];
    }
    
    HCViewController *vc = nil;
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        vc = [[HCJurisdictionViewController alloc] init];
    }else if (indexPath.section == 1 && indexPath.row == 0)
    {
        vc = [[HCFeedbackViewController alloc] init];
    }else if (indexPath.section == 1 && indexPath.row == 2)
    {
        vc = [[HCAboutMTalkViewController alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1)
    {
        _blackView = [[UIButton alloc]initWithFrame:self.view.frame];
        _blackView.backgroundColor = [UIColor blackColor];
        _blackView.alpha = 0.3;
        [_blackView addTarget:self action:@selector(removeBlackAndWhite) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_blackView];
        
        _whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44*7, SCREEN_WIDTH, 44 * 7)];
        _whiteView.backgroundColor = [UIColor whiteColor];
        NSArray *arr =@[@"短信",@"朋友圈",@"微信好友",@"QQ好友",@"QQ空间",@"腾讯微博",@"新浪微博"];
        for (int i = 0; i<7; i++) {
            
            UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, i * 44, SCREEN_WIDTH, 44)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:arr[i] forState:UIControlStateNormal];
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 43, SCREEN_WIDTH, 1)];
            view.backgroundColor = [UIColor lightGrayColor];
            [button addSubview:view];
            [_whiteView addSubview:button];
        }
        [self.view addSubview:_whiteView];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.imageNameDic[[NSString stringWithFormat:@"%@", @(section+1)]];
    return array.count;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self showHUDView:@"正在退出"];
        [[HCAppMgr manager] logout];
    }
}

#pragma private methods

-(void)removeBlackAndWhite
{
    [_blackView removeFromSuperview];
    [_whiteView removeFromSuperview];
}

- (void)handleLogoutButton
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您确定要退出当前账号吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.delegate = self;
    [alertView show];
}

#pragma mark - setter or getter

- (NSDictionary *)imageNameDic
{
    if (!_imageNameDic)
    {
        _imageNameDic = @{@"1":@[@"airplane",  @"permission", @"delete"], @"2": @[@"Feedback", @"Recommend", @"about_mtalk", @"Exit"]};
    }
    return _imageNameDic;
}

- (NSDictionary *)titleDic
{
    if (!_titleDic)
    {
        _titleDic = @{@"1": @[@"消息推送提醒",  @"默认权限设置", @"清除缓存"], @"2": @[@"反馈建议", @"推荐给好友", @"关于M-Talk", @"退出登录"]};
    }
    return _titleDic;
}

- (UISwitch *)switchs
{
    _switchs = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH(self.view)-60, 10, 30, 30)];
    return _switchs;
}


@end
