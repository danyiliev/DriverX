//
//  SupportVC.h
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"

@interface HistoryVC : BaseVC<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewForBill;
- (IBAction)closeBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

//////////// Outlets Price Label

@property (strong, nonatomic) IBOutlet UITableView *tblPrize;


@property (weak, nonatomic) IBOutlet UILabel *lblTotal;

@property (weak, nonatomic) IBOutlet UIImageView *imgNoDisplay;

////////////


@end
