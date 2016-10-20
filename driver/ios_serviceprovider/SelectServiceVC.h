//
//  SelectServiceVC.h
//  TaxiNow Driver
//
//  Created by My Mac on 3/23/15.
//  Copyright (c) 2015 Deep Gami. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@interface SelectServiceVC : BaseVC<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(strong,nonatomic)NSMutableDictionary *dictparam;

@property(strong,nonatomic)UIImage *imgP;

@property (weak, nonatomic) IBOutlet UITableView *tblselectService;
- (IBAction)onClickforRegister:(id)sender;
@end
