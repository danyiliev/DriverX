//
//  ProviderDetailsVC.h
//  UberNewUser
//
//  Created by Deep Gami on 29/10/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "BaseVC.h"
#import "MapView.h"
#import "Place.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <GoogleMaps/GoogleMaps.h>

@class RatingBar;

@interface ProviderDetailsVC : BaseVC<MKMapViewDelegate,CLLocationManagerDelegate,GMSMapViewDelegate>
{
    UIImageView* routeView;
    NSArray* routes;
    UIColor* lineColor;
   

    CLLocationManager *locationManager;
}
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (strong , nonatomic) NSTimer *timerForCheckReqStatuss;
@property (strong , nonatomic) NSTimer *timerForTimeAndDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *revealBtnItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *lblRateValue;
@property (weak, nonatomic) IBOutlet UIImageView *imgForDriverProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverName;
@property (weak, nonatomic) IBOutlet UILabel *lblDriverDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnMin;
@property (weak, nonatomic) IBOutlet UIButton *btnDistance;
@property (weak, nonatomic) NSMutableDictionary *dictProvider;

@property(strong,nonatomic)NSMutableArray *arrwalkers;




@property (nonatomic,strong) NSString *strForLatitude;
@property (nonatomic,strong) NSString *strForLongitude;
@property (nonatomic,strong) NSString *strForWalkStatedLatitude;
@property (nonatomic,strong) NSString *strForWalkStatedLongitude;
@property (nonatomic,strong) NSTimer *timerforpathDraw;
- (IBAction)contactProviderBtnPressed:(id)sender;
-(int)checkDriverStatus;


@property (weak, nonatomic) IBOutlet UIButton *btnStatus;


@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;

@property (nonatomic,strong) MKPolyline *polyline;
@property(nonatomic,strong) CrumbPath *crumbs;
@property (nonatomic,strong) CrumbPathView *crumbView;

////////// Notification View
- (IBAction)statusBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkerStarted;
@property (weak, nonatomic) IBOutlet UILabel *lblWalkerArrived;
@property (weak, nonatomic) IBOutlet UILabel *lblJobStart;
@property (weak, nonatomic) IBOutlet UILabel *lblJobDone;


@property (weak, nonatomic) IBOutlet UIButton *btnWalkerStart;
@property (weak, nonatomic) IBOutlet UIButton *btnWalkerArrived;
@property (weak, nonatomic) IBOutlet UIButton *btnJobStart;
@property (weak, nonatomic) IBOutlet UIButton *btnJobDone;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UILabel *lblAccept;

@property (weak, nonatomic) IBOutlet RatingBar *ratingView;

@property (strong, nonatomic) IBOutlet UIView *viewForMap;

@end
