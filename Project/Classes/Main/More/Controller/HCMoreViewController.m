//
//  HCMoreViewController.m
//  Project
//
//  Created by 陈福杰 on 15/12/15.
//  Copyright © 2015年 com.xxx. All rights reserved.
//

#import "HCMoreViewController.h"
#import "HCTagManagerViewController.h"
#import "HCAddItemViewController.h"
#import "HClassCalendarViewController.h"
#import "HCNotificationViewController.h"
#import "HCProductionCenterController.h"
#import "HCPromisedViewController.h" // 一呼百应
#import "HCRescueCenterViewController.h" // 救助中心
#import "HCTimeViewController.h"
#import "HCMoreCollectionViewCell.h"
#import "HCMoreInfo.h"

@interface HCMoreViewController()

@property (nonatomic, strong) NSMutableArray *TagArr;
@property (nonatomic, strong) NSArray *vClassNameArr;

@end

@interface HCMoreViewController ()

@end

@implementation HCMoreViewController

static NSString * const reuseIdentifier = @"moreCollectionCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[HCMoreCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

-(void)viewWillAppear:(BOOL)animated
{
    UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    
    statusBarView.backgroundColor=kHCNavBarColor;
    
    [self.view addSubview:statusBarView];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
}

#pragma mark UICollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.info = self.TagArr[indexPath.section*3+indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld,%ld", indexPath.section, indexPath.row);
    NSString *vCName = self.vClassNameArr[indexPath.section*3+indexPath.row];
    HCViewController *vc = [[NSClassFromString(vCName) alloc] init];
    if ([vc isKindOfClass:[HCPromisedViewController class]])
    {
        self.tabBarController.selectedIndex = 2;
    }else
    {
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return ((int)self.TagArr.count/3+1);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ((self.TagArr.count/3) == section)
    {
        return (self.TagArr.count % 3);
    }
    return 3;
}

#pragma mark - setter or getter

- (NSMutableArray *)TagArr
{
    if (!_TagArr)
    {
        NSArray *titleArr = @[@"一呼百应",
                              @"产品中心",
                              @"救助中心",
                              @"标签管理",
                              ];
        NSArray *imageNameArr = @[@"hopne",
                                  @"Products",
                                  @"Salve",
                                  @"label",
                                  ];
        _TagArr = [NSMutableArray arrayWithCapacity:8];
        for (NSInteger i = 0; i < 4; i++)
        {
            HCMoreInfo *info = [[HCMoreInfo alloc] init];
            info.title = titleArr[i];
            info.imageName = imageNameArr[i];
            info.isShow = YES;
            [_TagArr addObject:info];
        }
    }
    return _TagArr;
}

- (NSArray *)vClassNameArr
{
    if (!_vClassNameArr)
    {
        _vClassNameArr = @[@"HCPromisedViewController",@"HCProductionCenterController",
                           @"HCRescueCenterViewController",@"HCTagManagerViewController"];
    }
    return _vClassNameArr;
}

@end
