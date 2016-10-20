//
//  ProviderListVCCell.h
//  Beautician
//
//  Created by My Mac on 3/23/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASStarRatingView.h"


@interface ProviderListVCCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblPrize;
@property (strong, nonatomic) IBOutlet ASStarRatingView *starView;


@end
