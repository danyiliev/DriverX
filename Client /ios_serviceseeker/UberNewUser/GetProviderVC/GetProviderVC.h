//
//  GetProviderVC.h
//  Beautician
//
//  Created by My Mac on 3/23/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetProviderVC : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tblProviderList;
@property(strong,nonatomic)NSMutableArray *arrProviders;
@property (strong , nonatomic) NSTimer *timerForCheckReqStatus;

@property (strong,nonatomic)NSString *strForLatitude;
@property (strong,nonatomic)NSString *strForLongitude;
@property (strong,nonatomic)NSString *strForTypeid;
@property (strong, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)onClickBtnCancel:(id)sender;


@end
