//
//  FeedBackVC.m
//  UberNewUser
//
//  Created by Deep Gami on 01/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "FeedBackVC.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import "PickUpVC.h"
#import "HistoryCellPrize.h"

@interface FeedBackVC ()
{
    NSArray *arrTypes;
}

@end

@implementation FeedBackVC

#pragma mark - ViewLife Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
   // [super setBackBarItem];
     arrTypes=[dictBillInfo valueForKey:@"type"];
    
    [self customFont];
   
    
    NSArray *arrName=[self.strFirstName componentsSeparatedByString:@" "];
    
    self.lblFirstName.text=[arrName objectAtIndex:0];
    self.lblLastName.text=[arrName objectAtIndex:1];
    
    self.lblDistance.textColor=[UberStyleGuide colorDefault];
    self.lblTIme.textColor=[UberStyleGuide colorDefault];
    
    self.lblDistance.text=[self.dictWalkInfo valueForKey:@"distance"];
    self.lblTIme.text=[self.dictWalkInfo valueForKey:@"time"];
    [self.imgUser applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self.imgUser downloadFromURL:self.strUserImg withPlaceholder:nil];
    self.viewForBill.hidden=NO;
    
    [self customSetup];
    [self setPriceValue];
   
}

#pragma mark- 
#pragma mark- Set Invoice Details

-(void)setPriceValue
{
        
   // self.lblBasePrice.text=[NSString stringWithFormat:@"$ %@",[dictBillInfo valueForKey:@"base_price"]];
   // self.lblDistCost.text=[NSString stringWithFormat:@"$ %@",[dictBillInfo valueForKey:@"distance_cost"]];
   // self.lblTimeCost.text=[NSString stringWithFormat:@"$ %@",[dictBillInfo valueForKey:@"time_cost"]];
    self.lblTotal.text=[NSString stringWithFormat:@"$ %@",[dictBillInfo valueForKey:@"total"]];
    
    float totalDist=[[dictBillInfo valueForKey:@"distance_cost"] floatValue];
    float Dist=[[dictBillInfo valueForKey:@"distance"]floatValue];
    
    if ([[dictBillInfo valueForKey:@"unit"]isEqualToString:@"kms"])
    {
        totalDist=totalDist*0.621317;
        Dist=Dist*0.621371;
    }
    if(Dist!=0)
    {
      //  self.lblPerDist.text=[NSString stringWithFormat:@"%.2f$ per Miles",(totalDist/Dist)];
    }
    else
    {
       // self.lblPerDist.text=@"0$ per Miles";
    }
    
    float totalTime=[[dictBillInfo valueForKey:@"time_cost"] floatValue];
    float Time=[[dictBillInfo valueForKey:@"time"]floatValue];
    if(Time!=0)
    {
       // self.lblPerTime.text=[NSString stringWithFormat:@"%.2f$ per Mins",(totalTime/Time)];
    }
    else
    {
       // self.lblPerTime.text=@"0$ per Mins";
    }
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.barButton addTarget:self.revealViewController action:@selector( revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
        
    }
}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.lblDistance.font=[UberStyleGuide fontRegular];
    //self.lblDistCost.font=[UberStyleGuide fontRegular];
   // self.lblBasePrice.font=[UberStyleGuide fontRegular];
   // self.lblDistance.font=[UberStyleGuide fontRegular];
   // self.lblPerDist.font=[UberStyleGuide fontRegular];
   // self.lblPerTime.font=[UberStyleGuide fontRegular];
    self.lblTIme.font=[UberStyleGuide fontRegular];
   // self.lblTimeCost.font=[UberStyleGuide fontRegular];
    self.lblTotal.font=[UberStyleGuide fontRegular:30.0f];
    self.lblFirstName.font=[UberStyleGuide fontRegular];
    self.lblLastName.font=[UberStyleGuide fontRegular];
    self.btnFeedBack.titleLabel.font=[UberStyleGuide fontRegular];
    
    self.btnConfirm.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.btnSubmit.titleLabel.font=[UberStyleGuide fontRegularBold];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-
#pragma makr- Btn Click Events

- (IBAction)submitBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"REVIEWING", nil)];
        RBRatings rating=[ratingView getcurrentRatings];
        int rate=rating/2.0;
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:strForUserId forKey:PARAM_ID];
        [dictParam setObject:strForUserToken forKey:PARAM_TOKEN];
        [dictParam setObject:strReqId forKey:PARAM_REQUEST_ID];
        [dictParam setObject:[NSString stringWithFormat:@"%d",rate] forKey:PARAM_RATING];
        [dictParam setObject:self.txtComments.text forKey:PARAM_COMMENT];

        
        
//        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_RATE_DRIVER withParamData:dictParam withBlock:^(id response, NSError *error)
         {
             NSLog(@"%@",response);
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"RATING", nil)];
                     [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_REQ_ID];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     [self.navigationController popToRootViewControllerAnimated:YES];
                     
                     /*for (UIViewController *vc in self.navigationController.viewControllers)
                      {
                      if ([vc isKindOfClass:[PickUpVC class]])
                      {
                      [self.navigationController popToViewController:vc animated:YES];
                      return ;
                      }
                      }*/
                 }
             }
             
             [[AppDelegate sharedAppDelegate]hideLoadingView];

         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }

}
#pragma mark -
#pragma mark - UITextField Delegate


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, -150, self.view.frame.size.width, self.view.frame.size.height);
        
        
    } completion:^(BOOL finished)
     {
     }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        
    } completion:^(BOOL finished)
     {
     }];
  
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)confirmBtnPressed:(id)sender
{
    self.viewForBill.hidden=YES;
    ratingView=[[RatingBar alloc] initWithSize:CGSizeMake(120, 20) AndPosition:CGPointMake(135, 152)];
    ratingView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:ratingView];

}

#pragma mark-
#pragma mark- Text Field Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtComments resignFirstResponder];
}



- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    self.txtComments.text=@"";
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComments)
            {
                UITextPosition *beginning = [self.txtComments beginningOfDocument];
                [self.txtComments setSelectedTextRange:[self.txtComments textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComments)
            {
                UITextPosition *beginning = [self.txtComments beginningOfDocument];
                [self.txtComments setSelectedTextRange:[self.txtComments textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
        }
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComments)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComments)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
        }
    }
    if ([self.txtComments.text isEqualToString:@""])
    {
        self.txtComments.text=@"Comments";
    }
    
}
#pragma mark- TableView Delegate Method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  arrTypes.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    HistoryCellPrize *cell = [self.tblPrizeValue dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *dict=[arrTypes objectAtIndex:indexPath.row];
    
    if (cell==nil)
    {
        cell=[[HistoryCellPrize alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    cell.lblName.text=[dict valueForKey:@"name"];
    cell.lblPrize.text=[NSString stringWithFormat:@"$%@",[dict valueForKey:@"price"]];
    
    return cell;
}


#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
