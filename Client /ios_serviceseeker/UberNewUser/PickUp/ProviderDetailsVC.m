//
//  ProviderDetailsVC.m
//  UberNewUser
//
//  Created by Deep Gami on 29/10/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProviderDetailsVC.h"
#import "SWRevealViewController.h"
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "FeedBackVC.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "Constants.h"
#import "RateView.h"
#import "UIView+Utils.h"

@interface ProviderDetailsVC ()
{
   
    
    NSDate *dateForwalkStartedTime;
    //float distance;
    BOOL isTimerStaredForMin,isWalkInStarted,pathDraw;
   // NSMutableDictionary *dictBillInfo;
    NSMutableArray *arrPath;
    NSString *strUSerImage,*strLastName;
    NSString *strProviderPhone,*strTime,*strDistance,*strForUserId,*strForUserToken,*strForTypeid,*strProviderId;
    GMSMutablePath *pathUpdates;
    GMSMapView *mapView_;
    GMSMarker *client_marker,*driver_marker;
}

@end

@implementation ProviderDetailsVC
@synthesize strForLongitude,strForLatitude,strForWalkStatedLatitude,strForWalkStatedLongitude,timerForTimeAndDistance,timerForCheckReqStatuss;
@synthesize dictProvider,arrwalkers;
#pragma mark -
#pragma mark - View DidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@" walk = %@",arrwalkers);
    APPDELEGATE.vcProvider=self;
    [super setNavBarTitle:TITLE_PICKUP];
    [self customSetup];
    [self updateLocationManager];
    //[self checkDriverStatus];
    //[self CreateRequest];
    arrPath=[[NSMutableArray alloc]init];
    pathUpdates = [GMSMutablePath path];
    pathUpdates = [[GMSMutablePath alloc]init];
    isTimerStaredForMin=NO;
    pathDraw=YES;
    
    NSUserDefaults *pref2=[NSUserDefaults standardUserDefaults];
    strForLatitude=[pref2 objectForKey:PARAM_LATITUDE];
    strForLongitude = [pref2 objectForKey:PARAM_LONGITUDE];
    strForTypeid=[pref2 objectForKey:PARAM_TYPE];
    strProviderId =[pref2 objectForKey:@"PID"];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForLatitude doubleValue] longitude:[strForLongitude doubleValue]
                                                                 zoom:10];
    mapView_=[GMSMapView mapWithFrame:CGRectMake(0, 0,320,355) camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.viewForMap addSubview:mapView_];
    [APPDELEGATE.window bringSubviewToFront:self.statusView];
    mapView_.delegate=self;
    
    
    // Creates a marker in the client Location of the map.
    
    client_marker = [[GMSMarker alloc] init];
    client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
    client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
    client_marker.map = mapView_;
    
    // Creates a marker in the client Location of the map.
    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
    driver_marker.map = mapView_;
    

    
    
    
    
    //strForLatitude = [dictProvider valueForKey:PARAM_LATITUDE];
    //strForLongitude = [dictProvider valueForKey:PARAM_LONGITUDE];
    
    //strForTypeid =  [dictProvider valueForKey:PARAM_TYPE];
    //strProviderId = [dictProvider valueForKey:@"id"];
    NSLog(@" lat n ling = %@ ,%@ \n type :%@\nprovider :%@",strForLatitude,strForLongitude,strForTypeid,strProviderId);
    
    NSLog(@" driver lt lng = %@,%@",strForWalkStatedLongitude,strForWalkStatedLongitude);
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
    /*
    if([timerForCheckReqStatuss isValid])
    {
        [timerForCheckReqStatuss invalidate];
    }
    timerForCheckReqStatuss =nil;
    */
    [self checkForTripStatus];

   
    
     // [self showMapCurrentLocatin];
    //[self showDriverLocatinOnMap];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    isWalkInStarted=[pref boolForKey:PREF_IS_WALK_STARTED];
    if(isWalkInStarted)
    {
        [self requestPath];
    }
    self.acceptView.hidden=NO;
    self.lblStatus.text=@"Status :  Accepted the Job";
    
    [self customFont];
    }
/*-(void)jobCompleted
{
    is_walker_started = 0;
    is_walker_arrived = 0;
    is_started = 0;
    is_completed = 0;
}*/
-(void)viewDidAppear:(BOOL)animated
{
    timerForCheckReqStatuss = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkForTripStatus) userInfo:nil repeats:YES];
    [self.ratingView initRateBar];
    [self.ratingView setUserInteractionEnabled:NO];
    self.statusView.hidden=YES;
    [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
    [self.imgForDriverProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
   
    //[self checkForTripStatus];
    [self checkDriverStatus];
    //[self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];

}
-(void)viewDidDisappear:(BOOL)animated
{
    is_walker_started = 0;
    is_walker_arrived = 0;
    is_started = 0;
    is_completed = 0;
    
    [self.btnWalkerStart setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    [self.btnWalkerArrived setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.btnJobStart setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.btnJobDone setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    
    
    if(timerForCheckReqStatuss && [timerForCheckReqStatuss isValid])
    {
    [timerForCheckReqStatuss invalidate];
    [timerForTimeAndDistance invalidate];
    timerForTimeAndDistance=nil;
    timerForCheckReqStatuss=nil;
    }
}
/*
-(void)CreateRequest
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strForUserId=[pref objectForKey:PREF_USER_ID];
    strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setValue:strForLatitude forKey:PARAM_LATITUDE];
    [dictParam setValue:strForLongitude  forKey:PARAM_LONGITUDE];
    //[dictParam setValue:@"22.3023117"  forKey:PARAM_LATITUDE];
    //[dictParam setValue:@"70.7969645"  forKey:PARAM_LONGITUDE];
    //[dictParam setValue:@"1" forKey:PARAM_DISTANCE];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
   [dictParam setValue:strForTypeid forKey:PARAM_TYPE];
    [dictParam setValue:strProviderId  forKey:@"provider_id"];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_CREATE_REQUEST_PROVIDERS withParamData:dictParam withBlock:^(id response, NSError *error)
     {
         [[AppDelegate sharedAppDelegate]hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"]boolValue])
             {
                 NSLog(@"res = %@",response);
             }
         }
     }];

}
 */
/*#pragma mark-
#pragma mark- timer for oath draw

-(void)setTimerToCheckDriverStatus
{
    self.timerforpathDraw = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(setPathDrawBool) userInfo:nil repeats:YES];
}

-(void)setPathDrawBool
{
    pathDraw=YES;
}*/

#pragma mark-
#pragma mark- customFont

-(void)customFont
{
   /* self.lblDriverDetail.font=[UberStyleGuide fontRegular:13.0f];
    self.lblDriverName.font=[UberStyleGuide fontRegular:13.0f];
    self.lblJobDone.font=[UberStyleGuide fontRegular:13.0f];
    self.lblJobStart.font=[UberStyleGuide fontRegular:13.0f];
    self.lblWalkerArrived.font=[UberStyleGuide fontRegular:13.0f];
    self.lblWalkerStarted.font=[UberStyleGuide fontRegular:13.0f];*/
    
    self.lblAccept.font=[UberStyleGuide fontRegular];
    self.lblAccept.textColor=[UberStyleGuide colorDefault];
    
    self.btnCall=[APPDELEGATE setBoldFontDiscriptor:self.btnCall];
    self.btnDistance=[APPDELEGATE setBoldFontDiscriptor:self.btnDistance];
    self.btnMin=[APPDELEGATE setBoldFontDiscriptor:self.btnMin];
    
}
#pragma mark -
#pragma mark - Location Delegate


-(void)updateLocationManager
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
    strForLatitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    strForLongitude=[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    isWalkInStarted=[pref boolForKey:PREF_IS_WALK_STARTED];
    
    if(isWalkInStarted)
    {
        if (newLocation != nil) {
            if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
                
            }else{
                //Code for
                //CLLocationDistance meters = [oldLocation distanceFromLocation:newLocation];
                //distance += (meters/1609);
                //[self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f Miles",distance] forState:UIControlStateNormal];
              //  [self checkTimeAndDistance];
                /*if (pathDraw)
                {
                    pathDraw=NO;
                    [self updateMapLocation:newLocation];
                }*/
               // [self updateMapLocation:newLocation];

                [pathUpdates addCoordinate:newLocation.coordinate];
                
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathUpdates];
                polyline.strokeColor = [UIColor blueColor];
                polyline.strokeWidth = 5.f;
                polyline.geodesic = YES;
                
                polyline.map = mapView_;

            }
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    /*UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertLocation.tag=100;
    [alertLocation show];
*/
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.revealBtnItem addTarget:self.revealViewController action:@selector( revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
        
        /*
         [self.revealButtonItem setTarget: self.revealViewController];
         [self.revealButtonItem setAction: @selector( revealToggle: )];
         */
        //[self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark -
#pragma mark - Mapview Delegate

-(void)showDriverLocatinOnMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForWalkStatedLatitude doubleValue] longitude:[strForWalkStatedLongitude doubleValue]
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
    //self.view = mapView_;
    [self.viewForMap addSubview:mapView_];
    // mapView_.delegate=self;
    
    driver_marker = [[GMSMarker alloc] init];
    driver_marker.position = CLLocationCoordinate2DMake([strForWalkStatedLatitude doubleValue], [strForWalkStatedLongitude doubleValue]);
    driver_marker.icon=[UIImage imageNamed:@"pin_driver"];
    driver_marker.map = mapView_;
    //    CLLocationCoordinate2D l;
    //    l.latitude=[strForWalkStatedLatitude doubleValue];
    //    l.longitude=[strForWalkStatedLongitude doubleValue];
    //    SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
    //    annotation.yTag=1002;
    //    [self.mapView addAnnotation:annotation];
    //    [self.mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.5, .5)) animated:YES];
}


-(void)showMapCurrentLocatin
{
    if([CLLocationManager locationServicesEnabled])
    {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[strForLatitude doubleValue] longitude:[strForLongitude doubleValue]
                                                                     zoom:6];
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
        mapView_.myLocationEnabled = NO;
        //self.view = mapView_;
        [self.viewForMap addSubview:mapView_];
        //mapView_.delegate=self;
        // Creates a marker in the client Location of the map.
        client_marker = [[GMSMarker alloc] init];
        client_marker.position = CLLocationCoordinate2DMake([strForLatitude doubleValue], [strForLongitude doubleValue]);
        client_marker.icon=[UIImage imageNamed:@"pin_client_org"];
        client_marker.map = mapView_;
        
        //        CLLocationCoordinate2D l;
        //        l.latitude=[strForLatitude doubleValue];
        //        l.longitude=[strForLongitude doubleValue];
        //        SBMapAnnotation *annotation= [[SBMapAnnotation alloc]initWithCoordinate:l];
        //        annotation.yTag=1001;
        //        [self.mapView addAnnotation:annotation];
        //        [self.mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.5, .5)) animated:YES];
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
   
}
/*
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    //Annotations
    MKPinAnnotationView *pinAnnotation = nil;
    if(annotation != self.mapView.userLocation)
    {
        // Dequeue the pin
        static NSString *defaultPinID = @"myPin";
        pinAnnotation = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinAnnotation == nil )
            pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        SBMapAnnotation *sbanno=(SBMapAnnotation *)annotation;
        
        if(sbanno.yTag==1001)
            pinAnnotation.image = [UIImage imageNamed:@"pin_client_org"];
        else
            pinAnnotation.image = [UIImage imageNamed:@"pin_driver"];
        
        pinAnnotation.centerOffset = CGPointMake(0, -20);
        pinAnnotation.rightCalloutAccessoryView=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinAnnotation.canShowCallout=YES;
        pinAnnotation.draggable=YES;
    }
    return pinAnnotation;
}
- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
    
    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(1, 1, 1, 1) animated:YES];
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if (!self.crumbView)
    {
        _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
    }
    return self.crumbView;
}
*/
#pragma mark -
#pragma mark - Custom Methods

-(float)calculateDistanceFrom:(CLLocation *)locA To:(CLLocation *)locB
{
    CLLocationDistance distance;
    distance=[locA distanceFromLocation:locB];
    float Range=distance;
    return Range;
}
#pragma mark-
#pragma mark- Calculate Time & Distance

-(void)updateTime:(NSString *)starTime
{/*
    NSString *currentTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]*1000];
    
    double start = [starTime doubleValue];
    double end=[currentTime doubleValue];
    
    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
    
    NSLog(@"difference: %f", difference);
    
    int time=(difference/(1000*60));
    
    if(time==0)
    {
        time=1;
    }
    
    [self.btnMin setTitle:[NSString stringWithFormat:@"%d min",time] forState:UIControlStateNormal];
    */
    
    
    
    NSString *gmtDateString = starTime;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *datee = [df dateFromString:gmtDateString];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    
    
    
    
     double dateTimeDiff=  [[NSDate date] timeIntervalSince1970] - [datee timeIntervalSince1970];
     int Diff=dateTimeDiff/60;
    strTime=[NSString stringWithFormat:@"%d Min",Diff];
     [self.btnMin setTitle:[NSString stringWithFormat:@"%d Min",Diff] forState:UIControlStateNormal];
     NSLog(@"Min %d",Diff);
    
}
-(void)checkForTripStatus
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        NSString *strReqId=[pref objectForKey:PREF_REQ_ID];
        
        
        NSString *strForUrl=[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_GET_REQUEST,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:strForUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             NSLog(@"GET REQ--->%@",response);
             if (response) {
                 
                 if([[response valueForKey:@"success"]boolValue])
                 {
                     
                     NSMutableDictionary *dictWalker=[response valueForKey:@"walker"];
                     self.lblRateValue.text=[NSString stringWithFormat:@"%.1f",[[dictWalker valueForKey:@"rating"] floatValue]];
                     
                     RBRatings rate=([[dictWalker valueForKey:@"rating"]floatValue]*2);
                     [ self.ratingView setRatings:rate];
                     
                     strLastName=[dictWalker valueForKey:@"last_name"];
                     self.lblDriverName.text=[NSString stringWithFormat:@"%@ %@",[dictWalker valueForKey:@"first_name"],strLastName];
                     
                     self.lblDriverDetail.text=[dictWalker valueForKey:@"phone"];
                     strProviderPhone=[NSString stringWithFormat:@"%@",[dictWalker valueForKey:@"phone"]];
                     [self.imgForDriverProfile downloadFromURL:[dictWalker valueForKey:@"picture"] withPlaceholder:nil];
                     strUSerImage=[dictWalker valueForKey:@"picture"];
                     
                     is_walker_started=[[response valueForKey:@"is_walker_started"] intValue];
                     is_walker_arrived=[[response valueForKey:@"is_walker_arrived"] intValue];
                     is_started=[[response valueForKey:@"is_walk_started"] intValue];
                     is_completed=[[response valueForKey:@"is_completed"] intValue];
                     is_dog_rated=[[response valueForKey:@"is_walker_rated"] intValue];
                     
                     strDistance=[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]];
                     [self checkDriverStatus];
                     
                     if(is_completed==1)
                     {
                         [self updateTime:[response valueForKey:@"start_time"]];
                         isWalkInStarted=NO;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
                         
                         
                         
                         dictBillInfo=[response valueForKey:@"bill"];
                        
                         
                         FeedBackVC *vcFeed = nil;
                         for (int i=0; i<self.navigationController.viewControllers.count; i++)
                         {
                             UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
                             if ([vc isKindOfClass:[FeedBackVC class]])
                             {
                                 
                                 vcFeed = (FeedBackVC *)vc;
                             }
                             
                         }
                         if (vcFeed==nil)
                         {
                            
                             
                             [self.timerforpathDraw invalidate];
                             
                             [self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];
                         }
                         else{
                             [self.navigationController popToViewController:vcFeed animated:NO];
                         }
                         
                     }
                     
                     else if(is_started==1)
                     {
                         //[self setTimerToCheckDriverStatus];
                         [locationManager startUpdatingLocation];
                         [self updateTime:[response valueForKey:@"start_time"]];
                         [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]] forState:UIControlStateNormal];
                         
                         isWalkInStarted=YES;
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
                         
                         if(isTimerStaredForMin==NO)
                         {
                             isTimerStaredForMin=YES;
                             // [self checkTimeAndDistance];
                             dateForwalkStartedTime=[NSDate date];
                             // timerForTimeAndDistance= [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkTimeAndDistance) userInfo:nil repeats:YES];
                         }
                         strForWalkStatedLatitude=[dictWalker valueForKey:@"latitude"];
                         strForWalkStatedLongitude=[dictWalker valueForKey:@"longitude"];
                     }
                     strForWalkStatedLatitude=[dictWalker valueForKey:@"latitude"];
                     strForWalkStatedLongitude=[dictWalker valueForKey:@"longitude"];
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
-(void)requestPath
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSString *strForUserId=[pref objectForKey:PREF_USER_ID];
    NSString *strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
    NSString *strReqId=[pref objectForKey:PREF_REQ_ID];

    
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_REQUEST_PATH,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken,PARAM_REQUEST_ID,strReqId];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         
         NSLog(@"Page Data= %@",response);
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [arrPath removeAllObjects];
                 arrPath=[response valueForKey:@"locationdata"];
                 [self drawPath];
             }
         }
         
     }];
}
-(int)checkDriverStatus
{
    

    if(is_walker_started==1)
    {
        [self.btnWalkerStart setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Driver is on the way";
        self.lblAccept.text=@"DRIVER IS ON THE WAY";
        

        self.lblWalkerStarted.textColor=[UberStyleGuide colorDefault];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;

    }
  
    
    if(is_walker_arrived==1)
    {
        
        [self.btnWalkerArrived setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Driver has arrived at your location.";
        self.lblWalkerArrived.textColor=[UberStyleGuide colorDefault];
        self.lblAccept.text=@"DRIVER HAS ARRIVED AT YOUR LOCATION";
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;
    }
  
    
    if(is_started==1)
    {
        
        [self.btnJobStart setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        self.lblStatus.text=@"Status : Delivery in progress";
        self.lblJobStart.textColor=[UberStyleGuide colorDefault];
        self.lblAccept.text=@"DELIVERY IN PROGRESS";
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        self.acceptView.hidden=NO;
        self.statusView.hidden=YES;
    }

    
    if(is_dog_rated==1)
    {
        
    }
    
    if(is_completed==1)
    {
        
        [self.btnJobDone setBackgroundImage:[UIImage imageNamed:@"check_box"] forState:UIControlStateNormal];
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        self.lblJobDone.textColor=[UberStyleGuide colorDefault];
        
        isWalkInStarted=NO;
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        [pref setBool:isWalkInStarted forKey:PREF_IS_WALK_STARTED];
        [pref synchronize];
        
       /* FeedBackVC *vcFeed = nil;
        for (int i=0; i<self.navigationController.viewControllers.count; i++)
        {
            UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:i];
            if ([vc isKindOfClass:[FeedBackVC class]])
            {
                vcFeed = (FeedBackVC *)vc;
            }
            
        }
        if (vcFeed==nil)
        {
            [timerForCheckReqStatuss invalidate];
            [timerForTimeAndDistance invalidate];
            timerForTimeAndDistance=nil;
            timerForCheckReqStatuss=nil;
            [self.timerforpathDraw invalidate];
            [self performSegueWithIdentifier:SEGUE_TO_FEEDBACK sender:self];
        }else{
            [self.navigationController popToViewController:vcFeed animated:NO];
        }*/

    }

    if (self.statusView.hidden==NO)
    {
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box_arived"] forState:UIControlStateNormal];
    }
    return 5;
}

#pragma mark -
#pragma mark - Draw Route Methods

-(void)drawPath
{
    NSMutableDictionary *dictPath=[[NSMutableDictionary alloc]init];
    NSString *templati,*templongi;
    
    //NSMutableArray *paths=[[NSMutableArray alloc]init];
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<arrPath.count; i++)
    {
        dictPath=[arrPath objectAtIndex:i];
        templati=[dictPath valueForKey:@"latitude"];
        templongi=[dictPath valueForKey:@"longitude"];
        
        CLLocationCoordinate2D current;
        current.latitude=[templati doubleValue];
        current.longitude=[templongi doubleValue];
        CLLocation *curLoc=[[CLLocation alloc]initWithLatitude:current.latitude longitude:current.longitude];
        
        //[paths addObject:curLoc];
        [path addCoordinate:current];
        
        //[self updateMapLocation:curLoc];
    }
    
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor blueColor];
    polyline.strokeWidth = 5.f;
    polyline.geodesic = YES;
    
    polyline.map = mapView_;
}
/*
- (void)updateMapLocation:(CLLocation *)newLocation
{
    
    self.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
    self.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
    for (MKAnnotationView *annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[SBMapAnnotation class]])
        {
            SBMapAnnotation *sbAnno = (SBMapAnnotation *)annotation;
            if(sbAnno.yTag==1001)
                [sbAnno setCoordinate:newLocation.coordinate];
            if (!self.crumbs)
            {
                _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.mapView addOverlay:self.crumbs];
                
                MKCoordinateRegion region =
                MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
                [self.mapView setRegion:region animated:YES];
            }
            else{
                MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
                
                if (!MKMapRectIsNull(updateRect))
                {
                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
                    // Find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    // Ask the overlay view to update just the changed area.
                    [self.crumbView setNeedsDisplayInMapRect:updateRect];
                    
                    [self.mapView setVisibleMapRect:updateRect edgePadding:UIEdgeInsetsMake(1, 1, 1, 1) animated:YES];
                }
            }
        }
        
    }
}*/
- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
    for(int idx = 0; idx < routes.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    //[self.mapView setRegion:region animated:YES];
    
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 416) camera:camera];
}
/*
-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t
{
    if(routes)
    {
        [self.mapView removeAnnotations:[self.mapView annotations]];
    }
    
    [self.mapView addAnnotation:f];
    [self.mapView addAnnotation:t];
    
    routes = [self calculateRoutesFrom:f.coordinate to:t.coordinate];
    NSInteger numberOfSteps = routes.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        CLLocation *location = [routes objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
    }
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [self.mapView addOverlay:polyLine];
    [self centerMap];
}
*/
#pragma mark -
#pragma mark - MKPolyline delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation


 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSMutableDictionary *dictWalkInfo=[[NSMutableDictionary alloc]init];
    NSString *distance= strDistance;
    
    NSArray *arrDistace=[distance componentsSeparatedByString:@" "];
    float dist;
    dist=[[arrDistace objectAtIndex:0]floatValue];
    if (arrDistace.count>1)
    {
       
        if ([[arrDistace objectAtIndex:1] isEqualToString:@"kms"])
        {
            dist=dist*0.621371;
            
        }
        
    }
    [dictWalkInfo setObject:[NSString stringWithFormat:@"%f",dist] forKey:@"distance"];
    [dictWalkInfo setObject:strTime forKey:@"time"];
    
    if([segue.identifier isEqualToString:SEGUE_TO_FEEDBACK])
    {
        FeedBackVC *obj=[segue destinationViewController];
       // obj.delegate = self;
        obj.dictWalkInfo=dictWalkInfo;
       // obj.dictBillInfo=dictBillInfo;
        obj.strUserImg=strUSerImage;
        obj.strFirstName=self.lblDriverName.text;
        
    }
}
 
- (IBAction)contactProviderBtnPressed:(id)sender
{
    NSString *call=[NSString stringWithFormat:@"tel://%@",strProviderPhone];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
}


- (IBAction)statusBtnPressed:(id)sender
{
    self.acceptView.hidden=YES;
    if (self.statusView.hidden==YES)
    {
        self.statusView.hidden=NO;
        [APPDELEGATE.window addSubview:self.statusView];
        [APPDELEGATE.window bringSubviewToFront:self.statusView];
        
    }
    else
    {
        self.statusView.hidden=YES;
        [self.btnStatus setBackgroundImage:[UIImage imageNamed:@"notification_box"] forState:UIControlStateNormal];
        [APPDELEGATE.window bringSubviewToFront:self.statusView];

    }
}
@end
