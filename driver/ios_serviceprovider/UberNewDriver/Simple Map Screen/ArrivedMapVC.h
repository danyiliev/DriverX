//
//  ArrivedMapVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import "CrumbPathView.h"
#import "CrumbPath.h"
#import "WAGLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>


@class PickMeUpMapVC,RatingBar;

@interface ArrivedMapVC : BaseVC <MKMapViewDelegate,MKAnnotation,CLLocationManagerDelegate>
{
    UIImageView* routeView;
	
	NSArray* routes;
	
	UIColor* lineColor;
    
    GMSMutablePath *pathUpdates;
    GMSMapView *mapView_;

}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView_;

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


- (IBAction)onClickArrived:(id)sender;
- (IBAction)onClickJobDone:(id)sender;
- (IBAction)onClickWalkStart:(id)sender;
- (IBAction)onClickWalkerStart:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnWalker;
@property (weak, nonatomic) IBOutlet UIButton *btnWalk;
@property (weak, nonatomic) IBOutlet UIButton *btnJob;
@property (weak, nonatomic) IBOutlet UIButton *btnArrived;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (weak, nonatomic) IBOutlet UIButton *btnDistance;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;

@property(nonatomic, strong) NSTimer *timeForUpdateWalkLoc;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *timerForDistance;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblUserRate;
- (IBAction)onClickCall:(id)sender;


@property (nonatomic,strong) MKPolyline *polyline;
@property(nonatomic,strong) CrumbPath *crumbs;
@property (nonatomic,strong) CrumbPathView *crumbView;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;

@property (nonatomic,strong) PickMeUpMapVC *pickMeUp;
@property (weak, nonatomic) IBOutlet RatingBar *ratingView;



@end
