//
//  PickUpVC.m
//  UberNewUser
//
//  Created by Elluminati - macbook on 27/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "PickUpVC.h"
#import "SWRevealViewController.h"
#import "AFNHelper.h"
#import "AboutVC.h"
#import "ContactUsVC.h"
#import "ProviderDetailsVC.h"
#import "CarTypeCell.h"
#import "UIImageView+Download.h"
#import "CarTypeDataModal.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GetProviderVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AFHTTPRequestOperationManager.h"
@interface PickUpVC ()
{
    NSString *strForUserId,*strForUserToken,*strForLatitude,*strForLongitude,*strForRequestID,*strForDriverLatitude,*strForDriverLongitude,*strForTypeid,*strForCurLatitude,*strForCurLongitude;
    NSMutableArray *arrForInformation,*arrForApplicationType,*arrForAddress,*arrTypeID;
    GMSMapView *mapView_;
    NSMutableArray *arrProvider;
}

@end

@implementation PickUpVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrProvider=[[NSMutableArray alloc] init];
    
    
    
    
    strForTypeid=@"0";
    self.btnCancel.hidden=YES;
    arrForAddress=[[NSMutableArray alloc]init];
    self.tableView.hidden=YES;
    // [self setTimerToCheckDriverStatus];
    //[self checkDriverStatus];
    arrTypeID=[[NSMutableArray alloc]init];
    [[AppDelegate sharedAppDelegate]hideLoadingView];
    [self updateLocationManagerr];
    [self customFont];
    CLLocationCoordinate2D coordinate = [self getLocation];
    strForCurLatitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    strForCurLongitude= [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForCurLatitude doubleValue] longitude:[strForCurLongitude doubleValue] zoom:10];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.viewGoogleMap.frame.size.width, self.viewGoogleMap.frame.size.height) camera:camera];
    mapView_.myLocationEnabled = NO;
    mapView_.delegate=self;
    [self.viewGoogleMap addSubview:mapView_];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_REQ_ID];
    [super viewWillAppear:animated];
    
    arrForApplicationType=[[NSMutableArray alloc]init];
    self.navigationController.navigationBarHidden=NO;
    
    self.viewForMarker.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2-40);
    [self getAllApplicationType];
    [super setNavBarTitle:TITLE_PICKUP];
    [self customSetup];
    [self checkForAppStatus];
    [self getPagesData];
    [self performSelector:@selector(showMapCurrentLocatinn) withObject:nil afterDelay:2.5];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    //[self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.btnCancel.hidden=YES;
    [APPDELEGATE.window addSubview:self.btnCancel];
    [APPDELEGATE.window sendSubviewToBack:self.btnCancel];
}
- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}

#pragma mark-
#pragma mark-

-(void)customFont
{
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.btnCancel=[APPDELEGATE setBoldFontDiscriptor:self.btnCancel];
    self.btnPickMeUp=[APPDELEGATE setBoldFontDiscriptor:self.btnPickMeUp];
    self.btnSelService=[APPDELEGATE setBoldFontDiscriptor:self.btnSelService];
}
#pragma mark- Google Map Delegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    strForLatitude=[NSString stringWithFormat:@"%f",position.target.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",position.target.longitude];
}

- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    [self getAddress];
}
-(void)getAddress
{
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[strForLatitude floatValue], [strForLongitude floatValue], [strForLatitude floatValue], [strForLongitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    if (getAddress.count!=0)
    {
        self.txtAddress.text=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
    
}

#pragma mark -
#pragma mark - Location Delegate

-(CLLocationCoordinate2D) getLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    return coordinate;
}

-(void)updateLocationManagerr
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    
    [locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    strForCurLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    strForCurLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    // GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:newLocation.coordinate zoom:10];
    //[mapView_ animateWithCameraUpdate:updatedCamera];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    
}


#pragma mark-
#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }
    }
    
    
}

#pragma mark -
#pragma mark - Mapview Delegate

-(void)showMapCurrentLocatinn
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:10];
    [mapView_ animateWithCameraUpdate:updatedCamera];
    
    [self getAddress];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:SEGUE_ABOUT])
    {
        AboutVC *obj=[segue destinationViewController];
        obj.arrInformation=arrForInformation;
    }
    else if([segue.identifier isEqualToString:SEGUE_TO_ACCEPT])
    {
        /* ProviderDetailsVC *obj=[segue destinationViewController];
         obj.strForLatitude=strForLatitude;
         obj.strForLongitude=strForLongitude;
         obj.strForWalkStatedLatitude=strForDriverLatitude;
         obj.strForWalkStatedLongitude=strForDriverLongitude;
         */
        GetProviderVC *obj = [segue destinationViewController];
        obj.strForLatitude = strForLatitude;
        obj.strForLongitude = strForLongitude;
        obj.strForTypeid = strForTypeid;
        obj.arrProviders = arrProvider;
    }
    else if([segue.identifier isEqualToString:@"contactus"])
    {
        ContactUsVC *obj=[segue destinationViewController];
        obj.dictContent=sender;
    }
    else if ([segue.identifier isEqualToString:@"segueToProvide"])
    {
        ProviderDetailsVC *obj=[segue destinationViewController];
        // obj.strForLatitude=strForLatitude;
        // obj.strForLongitude=strForLongitude;
        obj.strForWalkStatedLatitude=strForDriverLatitude;
        obj.strForWalkStatedLongitude=strForDriverLongitude;
    }
}

-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}

#pragma mark -
#pragma mark - UIButton Action

- (IBAction)pickMeUpBtnPressed:(id)sender
{
    if([CLLocationManager locationServicesEnabled])
    {
        if ([strForTypeid isEqualToString:@"0"]||strForTypeid==nil)
        {
            strForTypeid=@"1";
        }
        if(![strForTypeid isEqualToString:@"0"])
        {
            if(((strForLatitude==nil)&&(strForLongitude==nil))
               ||(([strForLongitude doubleValue]==0.00)&&([strForLatitude doubleValue]==0)))
            {
                [APPDELEGATE showToastMessage:NSLocalizedString(@"NOT_VALID_LOCATION", nil)];
            }
            else
            {
                if([[AppDelegate sharedAppDelegate]connected])
                {
                    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CONTACTING_NEAR_BY_BEAUTICIANS", nil)];
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    strForUserId=[pref objectForKey:PREF_USER_ID];
                    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
                    
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
                    
                    [pref setObject:strForLatitude forKey:PARAM_LATITUDE];
                    [pref setObject:strForLongitude  forKey:PARAM_LONGITUDE];
                    [pref setObject:@"1" forKey:PARAM_TYPE];
                    
                    
                    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
                    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
                    //[dictParam setValue:@"22.3023117"  forKey:PARAM_LATITUDE];
                    //[dictParam setValue:@"70.7969645"  forKey:PARAM_LONGITUDE];
                    
                    if (arrTypeID.count!=0)
                    {
                        strForTypeid=[arrTypeID objectAtIndex:0];
                        for (int i=1; i<arrTypeID.count; i++) {
                            strForTypeid=[strForTypeid stringByAppendingString:[NSString stringWithFormat:@",%@",[arrTypeID objectAtIndex:i]]];
                        }
                        
                    }
                    else
                    {
                        strForTypeid=@"1";
                    }
                    
                    [dictParam setValue:@"1" forKey:PARAM_DISTANCE];
                    [dictParam setValue:strForUserId forKey:PARAM_ID];
                    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
                    [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
                    NSLog(@" dict = %@",dictParam);
                    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                    [afn getDataFromPath:FILE_GET_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
                     {
                         // [[AppDelegate sharedAppDelegate]hideLoadingView];
                         if (response)
                         {
                             if([[response valueForKey:@"success"]boolValue])
                             {
                                 NSLog(@"res beauty:%@",response);
                                 arrProvider=[response valueForKey:@"provider"];

                                 if([[response valueForKey:@"success"]boolValue])
                                 {
                                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                                     
                                     strForRequestID=[response valueForKey:@"request_id"];
                                     [pref setObject:strForRequestID forKey:PREF_REQ_ID];
                                     [self setTimerToCheckDriverStatus];
                                     
                                     // [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"CONTACTING_NEAR_BY_BEAUTICIANS", nil)];
                                     
                                     
                                     self.btnCancel.hidden=YES;
                                     [APPDELEGATE.window addSubview:self.btnCancel];
                                     [APPDELEGATE.window bringSubviewToFront:self.btnCancel];
                                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                                     [self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
                                 }
                             }
                             else
                             {
                                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                                 
                                 [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER_FOUND", nil)];
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
            
        }
        else
            [APPDELEGATE showToastMessage:NSLocalizedString(@"SELECT_TYPE", nil)];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
        
    }
    
    
}

- (IBAction)cancelReqBtnPressed:(id)sender
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
                         [self.btnCancel removeFromSuperview];
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_CANCEL", nil)];
                         
                     }
                     else
                     {}
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
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
        
        
    }
}

- (IBAction)myLocationPressed:(id)sender
{
    if ([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D coor;
        coor.latitude=[strForCurLatitude doubleValue];
        coor.longitude=[strForCurLongitude doubleValue];
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:10];
        [mapView_ animateWithCameraUpdate:updatedCamera];
        
        
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
}

- (IBAction)selectServiceBtnPressed:(id)sender
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        float closeY=(iOSDeviceScreenSize.height-self.btnSelService.frame.size.height);
        
        float openY=closeY-(self.bottomView.frame.size.height-self.btnSelService.frame.size.height);
        if (self.bottomView.frame.origin.y==closeY)
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, openY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, closeY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        
    }
    
    
}

#pragma mark -
#pragma mark - Custom WS Methods

-(void)getAllApplicationType
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_APPLICATION_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     NSMutableArray *arr=[[NSMutableArray alloc]init];
                     [arr addObjectsFromArray:[response valueForKey:@"types"]];
                     
                     //  arrType=[response valueForKey:@"types"];
                     
                     for(NSMutableDictionary *dict in arr)
                     {
                         
                         CarTypeDataModal *obj=[[CarTypeDataModal alloc]init];
                         obj.id_=[dict valueForKey:@"id"];
                         obj.name=[dict valueForKey:@"name"];
                         obj.icon=[dict valueForKey:@"icon"];
                         obj.is_default=[dict valueForKey:@"is_default"];
                         obj.price_per_unit_time=[dict valueForKey:@"price_per_unit_time"];
                         obj.price_per_unit_distance=[dict valueForKey:@"price_per_unit_distance"];
                         obj.base_price=[dict valueForKey:@"base_price"];
                         obj.isSelected=NO;
                         [arrForApplicationType addObject:obj];
                     }
                     [self.collectionView reloadData];
                 }
                 //  [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 
                 else
                 {}
             }
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
}
-(void)setTimerToCheckDriverStatus
{
    if (timerForCheckReqStatus) {
        [timerForCheckReqStatus invalidate];
        timerForCheckReqStatus = nil;
    }
    
    timerForCheckReqStatus = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForRequestStatus) userInfo:nil repeats:YES];
}
-(void)checkForAppStatus
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
    
    if(strReqId!=nil)
    {
        [self checkForRequestStatus];
    }
    else
    {
        [self checkRequestInProgress];
    }
}
-(void)checkForRequestStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
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
                     
                     if(strCheck)
                     {
                         [self.btnCancel removeFromSuperview];
                         
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                         strForDriverLatitude=[dictWalker valueForKey:@"latitude"];
                         strForDriverLongitude=[dictWalker valueForKey:@"longitude"];
                         if ([[response valueForKey:@"is_walker_rated"]integerValue]==1)
                         {
                             [pref removeObjectForKey:PREF_REQ_ID];
                             return ;
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
                             AFHTTPRequestOperationManager *afTerminate = [AFHTTPRequestOperationManager manager];
                             [afTerminate.operationQueue cancelAllOperations];
                             [self performSegueWithIdentifier:@"segueToProvide" sender:self];
                             //[self performSegueWithIdentifier:SEGUE_TO_GET_PROVIDERS sender:self];
                             
                         }else
                         {
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                         
                         
                         
                         
                     }
                     if([[response valueForKey:@"confirmed_walker"] intValue]==0 && [[response valueForKey:@"status"] intValue]!=0)
                     {
                         [[AppDelegate sharedAppDelegate]hideLoadingView];
                         [timerForCheckReqStatus invalidate];
                         timerForCheckReqStatus=nil;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref removeObjectForKey:PREF_REQ_ID];
                         
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"NO_WALKER", nil)];
                         self.btnCancel.hidden=YES;
                         [self showMapCurrentLocatinn];
                         [APPDELEGATE hideLoadingView];
                     }
                     
                 }
             }
             
             else
             {}
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void)checkDriverStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        // [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"COTACCTING_SERVICE_PROVIDER", nil)];
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSLog(@"GET REQ--->%@",response);
                 NSString *strCheck=[response valueForKey:@"walker"];
                 
                 if(strCheck)
                 {
                     [timerForCheckReqStatus invalidate];
                     timerForCheckReqStatus=nil;
                     [[AppDelegate sharedAppDelegate]hideLoadingView];
                     
                     // [self performSegueWithIdentifier:SEGUE_TO_ACCEPT sender:self];
                     //[self performSegueWithIdentifier:@"segueToProvide" sender:self];
                     
                 }
                 [[AppDelegate sharedAppDelegate]hideLoadingView];
                 
                 
             }
             else
             {}
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}
-(void)checkRequestInProgress
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strForUserId=[pref objectForKey:PREF_USER_ID];
        strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_REQUEST_PROGRESS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             [[AppDelegate sharedAppDelegate]hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     if ([[response valueForKey:@"request_id"]intValue]>0)
                     {
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQ_ID];
                         [pref synchronize];
                         [self checkForRequestStatus];
                     }
                     
                 }
                 else
                 {}
             }
             
             
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}
-(void)getPagesData
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGE,PARAM_ID,strForUserId];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"Respond to Request= %@",response);
             [APPDELEGATE hideLoadingView];
             
             if (response)
             {
                 arrPage=[response valueForKey:@"informations"];
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     //   [APPDELEGATE showToastMessage:@"Requset Accepted"];
                 }
             }
             
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrForApplicationType.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{/*    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
  
  NSDictionary *dictType=[arrForApplicationType objectAtIndex:indexPath.row];
  if (strForTypeid==nil || [strForTypeid isEqualToString:@"0"])
  {
  if ([[dictType valueForKey:@"is_default"]intValue]==1)
  {
  for(CarTypeDataModal *obj in arrForApplicationType)
  {
  obj.isSelected = NO;
  }
  CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
  obj.isSelected = YES;
  strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
  }
  }
  
  [cell setCellData:[arrForApplicationType objectAtIndex:indexPath.row]];
  
  //  cell.imgType.layer.masksToBounds = YES;
  //   cell.imgType.layer.opaque = NO;
  //    cell.imgType.layer.cornerRadius=18;
  
  return cell;
  */
    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
    
    CarTypeDataModal *cellData= [arrForApplicationType objectAtIndex:indexPath.row];
    if (cellData.icon==nil || [cellData.icon isKindOfClass:[NSNull class]]){
        cell.imgType.image=[UIImage imageNamed:@"button_limo.png"];
    }
    else{
        if ([cellData.icon isEqualToString:@""]) {
            cell.imgType.image=[UIImage imageNamed:@"button_limo.png"];
        }
        else{
            [cell.imgType downloadFromURL:cellData.icon withPlaceholder:nil];
        }
    }
    cell.lblTitle.text=cellData.name;
    cell.imgCheck.hidden=YES;
    
    
    
    for (int i=0; i<arrTypeID.count; i++)
    {
        if ([[arrTypeID objectAtIndex:i]intValue]==[cellData.id_ intValue])
        {
            cell.imgCheck.hidden=NO;
        }
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    //  NSDictionary *dict1=[arrType objectAtIndex:indexPath.row];
    //  NSString *Str=[dict1 valueForKey:@"id"];
    //  [arrselect addObject:Str];
    // NSLog(@"")
    
    for(CarTypeDataModal *obj in arrForApplicationType) {
        obj.isSelected = NO;
        
    }
    //NSLog(@"array :%@",arrForApplicationType);
    
    CarTypeDataModal *obj=[arrForApplicationType objectAtIndex:indexPath.row];
    obj.isSelected = YES;
    strForTypeid=[NSString stringWithFormat:@"%@",obj.id_];
    
    for (int i=0; i<arrTypeID.count; i++)
    {
        if ([[arrTypeID objectAtIndex:i]intValue]==[strForTypeid intValue])
        {
            [arrTypeID removeObjectAtIndex:i];
            [self.collectionView reloadData];
            return;
        }
    }
    [arrTypeID addObject:strForTypeid];   // NSDictionary *dict=[arrForApplicationType objectAtIndex:indexPath.row];
    // NSLog(@"dict :%@",dict);
    
    [self.collectionView reloadData];
}



#pragma mark
#pragma mark - UITextfield Delegate


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSString *strFullText=[NSString stringWithFormat:@"%@%@",textField.text,string];
    
    if(self.txtAddress==textField)
    {
        /*
         if([string isEqualToString:@""])
         {
         isSearching=NO;
         self.tableForCountry.frame=tempCountryRect;
         
         [self.tableForCountry reloadData];
         }
         else
         {
         isSearching=YES;
         self.tableForCountry.hidden=NO;
         [arrForFilteredCountry removeAllObjects];
         for (NSMutableDictionary *dict in self.arrForCountry) {
         NSString *tempStr=[dict valueForKey:@"country_name"];
         NSComparisonResult result = [tempStr compare:strFullText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [strFullText length])];
         if (result == NSOrderedSame) {
         [arrForFilteredCountry addObject:dict];
         }
         }*/
        
        
        //[self getLocationFromString:strFullText];
        
        if(arrForAddress.count==1)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x,86+134, self.tableView.frame.size.width, 44);
        else if(arrForAddress.count==2)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x, 86+78, self.tableView.frame.size.width, 88);
        else if(arrForAddress.count==3)
            self.tableView.frame=CGRectMake(self.tableView.frame.origin.x, 86+34, self.tableView.frame.size.width, 132);
        else if(arrForAddress.count==0)
            self.tableView.hidden=YES;
        
        [self.tableView reloadData];
        
    }
    
    
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.txtAddress.text=@"";
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self getLocationFromString:self.txtAddress.text];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.tableView.hidden=YES;
    
    // self.tableForCountry.frame=tempCountryRect;
    //  self.tblFilterArtist.frame=tempArtistRect;
    
    
    [textField resignFirstResponder];
    return YES;
}


-(void)getLocationFromString:(NSString *)str
{
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc] init];
    [dictParam setObject:str forKey:PARAM_ADDRESS];
    [dictParam setObject:GOOGLE_KEY forKey:PARAM_KEY];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getAddressFromGooglewithParamData:dictParam withBlock:^(id response, NSError *error)
     {
         if(response)
         {
             NSArray *arrAddress=[response valueForKey:@"results"];
             
             if ([arrAddress count] > 0)
             {
                 self.txtAddress.text=[[arrAddress objectAtIndex:0] valueForKey:@"formatted_address"];
                 
                 NSDictionary *dictLocation=[[[arrAddress objectAtIndex:0] valueForKey:@"geometry"] valueForKey:@"location"];
                 
                 strForLatitude=[dictLocation valueForKey:@"lat"];
                 strForLongitude=[dictLocation valueForKey:@"lng"];
                 CLLocationCoordinate2D coor;
                 coor.latitude=[strForLatitude doubleValue];
                 coor.longitude=[strForLongitude doubleValue];
                 
                 
                 GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coor zoom:10];
                 [mapView_ animateWithCameraUpdate:updatedCamera];
                 
                 
             }
             
         }
         
     }];
}

@end

