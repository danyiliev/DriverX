
//
//  GetProviderVC.m
//  Beautician
//
//  Created by My Mac on 3/23/15.
//  Copyright (c) 2015 Jigs. All rights reserved.
//

#import "GetProviderVC.h"
#import "ProviderListVCCell.h"
#import "RatingBar.h"
#import "ASStarRatingView.h"
#import "UIImageView+Download.h"
#import "ProviderDetailsVC.h"



@interface GetProviderVC ()
{
    NSString *strForUserId,*strForUserToken,*strReqId,*strForDriverLatitude,*strForDriverLongitude;
    NSMutableArray *arrWalker;
    
    BOOL animPop;
}
@end

@implementation GetProviderVC
@synthesize arrProviders,timerForCheckReqStatus,strForLatitude,strForLongitude,strForTypeid;

#pragma mark - Init



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setBackBarItem];
    
    timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
    
    // [APPDELEGATE hideLoadingView];
    
    
    NSLog(@" providers = %@",arrProviders);
    
    arrWalker=[[NSMutableArray alloc] init];
    
     self.btnCancel.hidden=YES;
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    // [self performSegueWithIdentifier:SEGUE_TO_GET_PROVIDERS sender:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [timerForCheckReqStatus invalidate];
    timerForCheckReqStatus=nil;
    
    self.btnCancel.hidden=YES;
    [APPDELEGATE.window addSubview:self.btnCancel];
    [APPDELEGATE.window sendSubviewToBack:self.btnCancel];
}


-(void)setBackBarItem
{
    self.navigationItem.hidesBackButton = YES;
    //self.navigationItem.backBarButtonItem = nil;
    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    btnLeft.frame=CGRectMake(0, 0, 25, 25);
    //btnLeft.frame=CGRectMake(0, 0, 18, 16);
    //[btnLeft setImage:[UIImage imageNamed:@"icon_header"] forState:UIControlStateNormal];
    //[btnLeft setTitle:@"Back" forState:UIControlStateNormal];
    //[btnLeft setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(onClickBackBarItem:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:btnLeft];
    [btnLeft setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
}
-(void)setBackBarItem:(BOOL)animated
{
    animPop=animated;
    [self setBackBarItem];
}
-(void)onClickBackBarItem:(id)sender
{
    [self.navigationController popViewControllerAnimated:animPop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrProviders.count;
}
-(ProviderListVCCell *)tableView:(UITableView *)tableView
           cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProviderListVCCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProviderList"];
    
    //create cell
    if(cell == nil)
    {
        cell = [[ProviderListVCCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProviderList"];
    }
    cell.lblName.text = [NSString stringWithFormat:@"%@ %@",[[arrProviders objectAtIndex:indexPath.row]valueForKey:@"first_name"],[[arrProviders objectAtIndex:indexPath.row]valueForKey:@"last_name"]];
    cell.lblPrize.text =[NSString stringWithFormat:@"$%@",[[arrProviders objectAtIndex:indexPath.row]valueForKey:@"base_price"]];
    [cell.imgProfile downloadFromURL:[[arrProviders objectAtIndex:indexPath.row]valueForKey:@"picture"] withPlaceholder:nil];
    
    // cell.imgProfile.layer.cornerRadius = cell.imgProfile.frame.size.height/2;
    //  cell.imgProfile.layer.cornerRadius = 5;
    // cell.imgProfile.clipsToBounds = YES;
    
    //CALayer *imageLayer = cell.imgProfile.layer;
    [cell.imgProfile.layer setCornerRadius:5];
    [cell.imgProfile.layer setBorderWidth:1];
    [cell.imgProfile.layer setMasksToBounds:YES];
    [cell.imgProfile.layer setCornerRadius:cell.imgProfile.frame.size.height/2];
    
    float value=[[[arrProviders objectAtIndex:indexPath.row]valueForKey:@"rating"] floatValue];
    
    cell.starView.canEdit=YES;
    cell.starView.maxRating=5;
    cell.starView.rating=value;
    cell.starView.userInteractionEnabled = NO;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSString *id = [[arrProviders objectAtIndex:indexPath.row] valueForKey:@"id"];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    
    NSDictionary *dict=[arrProviders objectAtIndex:indexPath.row];
    NSString *strProviderId=[dict valueForKey:@"id"];
    
    [pref setObject:strProviderId forKey:@"PID"];
    [pref synchronize];
    // strForLatitude=[dict valueForKey:@"latitude"];
    // strForLongitude=[dict valueForKey:@"longitude"];
    // strForTypeid=[dict valueForKey:PARAM_TYPE];
    
    
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
    [dictParam setValue:strProviderId  forKey:@"provider_id"];
    NSLog(@" half dict = %@",dictParam);
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CREATING_REQUEST", nil)];
    
    self.btnCancel.hidden=NO;
    [APPDELEGATE.window addSubview:self.btnCancel];
    [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
    

    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_CREATE_REQUEST_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         // [[AppDelegate sharedAppDelegate]hideLoadingView];
         if (response)
         {
             NSLog(@"res = %@",response);
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSUserDefaults *prefe = [NSUserDefaults standardUserDefaults];
                 NSString *strred=[response valueForKey:@"request_id"];
                 [prefe setObject:strred forKey:PREF_REQ_ID];
                 [prefe synchronize];
                 NSLog(@"req id :%@",strred);
                 
             }
             
         }
     }];
    
    
}
-(void)checkForRequestStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        strReqId=[pref objectForKey:PREF_REQ_ID];
        NSLog(@" q :%@",strReqId);
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSLog(@"GET REQ--->%@",response);
                     NSString *strCheck=[response valueForKey:@"walker"];
                     
                     /*if([[response valueForKey:@"confirmed_walker"] intValue]  != 0)
                      {
                      [timerForCheckReqStatus invalidate];
                      timerForCheckReqStatus=nil;
                      
                      
                      }else{
                      //[APPDELEGATE showToastMessage:NSLocalizedString(@"Beautician does not accepted Request", nil)];
                      [[AppDelegate sharedAppDelegate]hideLoadingView];
                      }*/
                     if(strCheck)
                     {
                         //  [self.btnCancel removeFromSuperview];
                         
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                         strForDriverLatitude=[dictWalker valueForKey:@"latitude"];
                         strForDriverLongitude=[dictWalker valueForKey:@"longitude"];
                         if ([[response valueForKey:@"is_walker_rated"]integerValue]==1)
                         {
                             [pref removeObjectForKey:PREF_REQ_ID];
                             [pref synchronize];
                         }
                         
                         ProviderDetailsVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[ProviderDetailsVC class]])
                             {
                                 vcFeed = (ProviderDetailsVC *)vc;
                             }
                             
                         }
                         
                         if (vcFeed==nil)
                         {
                             
                             
                             [timerForCheckReqStatus invalidate];
                             timerForCheckReqStatus=nil;
                             [[AppDelegate sharedAppDelegate]hideLoadingView];
                             
                             self.btnCancel.hidden=YES;
                             [self.btnCancel removeFromSuperview];
                             
                             [self performSegueWithIdentifier:SEGUE_TO_GET_PROVIDERS sender:self];
                         }
                         else
                         {
                             [timerForCheckReqStatus invalidate];
                             timerForCheckReqStatus=nil;
                             [[AppDelegate sharedAppDelegate]hideLoadingView];
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                         
                     }
                     if([[response valueForKey:@"confirmed_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]==1)
                     {
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref removeObjectForKey:PREF_REQ_ID];
                         
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                         // self.btnCancel.hidden=YES;
                         // [self showMapCurrentLocatinn];
                         [APPDELEGATE hideLoadingView];
                     }
                     
                 }
             }
             else
             {
                 
                 
             }
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:SEGUE_TO_GET_PROVIDERS])
    {
        
        ProviderDetailsVC *obj=[segue destinationViewController];
        obj.strForLatitude=strForLatitude;
        obj.strForLongitude=strForLongitude;
        obj.strForWalkStatedLatitude=strForDriverLatitude;
        obj.strForWalkStatedLongitude=strForDriverLongitude;
        
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (IBAction)onClickBtnCancel:(id)sender
{
    
    if([CLLocationManager locationServicesEnabled])
    {
        if([[AppDelegate sharedAppDelegate]connected])
        {
            [[AppDelegate sharedAppDelegate]hideLoadingView];
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CANCLEING", nil)];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            [dictParam setValue:strReqId forKey:PARAM_REQUEST_ID];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_CANCEL_REQUEST withParamData:dictParam withBlock:^(id response, NSError *error)
             {
                 if (response)
                 {
                     if([[response valueForKey:@"success"]boolValue])
                     {
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                        
                         self.btnCancel.hidden = YES;
                          [self.btnCancel removeFromSuperview];
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                         
                     }
                     else
                     {

                     }
                 }
                 
                 
             }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Food delivery -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
        
        
    }

}
@end
