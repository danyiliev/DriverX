//
//  HomeVC.m
//  Wag
//
//  Created by Elluminati - macbook on 20/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "HomeVC.h"
#import "LoginVC.h"
#import "RegisterVC.h"
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"
#import "AFNHelper.h"

@interface HomeVC ()
{
    CLLocationManager *locationManager;
}

@end

@implementation HomeVC

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
    self.lblName.text=NSLocalizedString(APPLICATION_NAME, nil);
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    if([pref boolForKey:PREF_IS_LOGIN])
        [self performSegueWithIdentifier:SEGUE_TO_DIRECT_LOGIN sender:self];
    if(![pref boolForKey:PREF_IS_LOGIN])
        self.navigationController.navigationBarHidden=YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLocationManagerr];

    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    if([pref boolForKey:PREF_IS_LOGIN])
        [self performSegueWithIdentifier:SEGUE_TO_DIRECT_LOGIN sender:self];
    if(![pref boolForKey:PREF_IS_LOGIN])
        self.navigationController.navigationBarHidden=YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    
    if(![pref boolForKey:PREF_IS_LOGIN])
        self.navigationController.navigationBarHidden=NO;
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickSignIn:(id)sender
{
    //[self performSegueWithIdentifier:@"" sender:self];
}

-(IBAction)onClickRegister:(id)sender
{
    
}

#pragma mark -
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //segue.identifier
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
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
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
    // GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:newLocation.coordinate zoom:10];
    //[mapView_ animateWithCameraUpdate:updatedCamera];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
