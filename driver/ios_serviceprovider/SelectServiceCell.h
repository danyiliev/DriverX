//
//  SelectServiceCell.h
//  TaxiNow Driver
//
//  Created by My Mac on 3/23/15.
//  Copyright (c) 2015 Deep Gami. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectServiceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgCheck;
@property (weak, nonatomic) IBOutlet UILabel *lbltitle;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtprice;
@property (weak, nonatomic) IBOutlet UILabel *txtdoller;

@property (weak, nonatomic) IBOutlet UIImageView *imgs;
@end