//
//  PickMeUpMapVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import "sbMapAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "LDProgressView.h"
#import "UIColor+RGBValues.h"
#import "ASStarRatingView.h"
#import <GoogleMaps/GoogleMaps.h>


@class ArrivedMapVC,RatingBar;


@interface PickMeUpMapVC : BaseVC <MKAnnotation,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,GMSMapViewDelegate>
{
    Reachability *internetReachableFoo;
    BOOL internet;
    UIImageView* routeView;
    
	NSArray* routes;
	
	UIColor* lineColor;
    
    LDProgressView *progressView;
    
    GMSMapView *mapView_;
    GMSMarker *marker;
}

@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIView *etaView;
@property (weak, nonatomic) IBOutlet UIView *datePicker;

- (IBAction)onClickSetEta:(id)sender;
- (IBAction)onClickReject:(id)sender;

- (IBAction)onClickAccept:(id)sender;

- (IBAction)onClickNoKey:(id)sender;
-(void)goToSetting:(NSString *)str;

@property (weak, nonatomic) IBOutlet UILabel *lblBlue;
@property (weak, nonatomic) IBOutlet UILabel *lblGrey;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDetails;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar;
@property (weak, nonatomic) IBOutlet UILabel *lblRate;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) IBOutlet UIButton *btnReject;
- (IBAction)pickMeBtnPressed:(id)sender;


@property (weak, nonatomic) IBOutlet UIView *ProfileView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserProfile;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIProgressView *progressTimer;


@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) NSTimer *time;
@property(nonatomic, strong) NSTimer *progtime;
@property (weak, nonatomic) IBOutlet UIImageView *imgTimeBg;

@property (weak, nonatomic) IBOutlet UILabel *lblWhite;
@property(nonatomic, strong) ArrivedMapVC *arrivedMap;
@property (weak, nonatomic) IBOutlet UILabel *lblforService;
@property (weak, nonatomic) IBOutlet ASStarRatingView *ratingV;

@property (weak, nonatomic) IBOutlet UIView *profileView2;
@property (weak, nonatomic) IBOutlet RatingBar *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *lblpriceofservice;
- (IBAction)onclickForInfo:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btninfo;
@property (weak, nonatomic) IBOutlet UIView *puPopupView;
@property (weak, nonatomic) IBOutlet UITableView *tblpopup;
@property (weak, nonatomic) IBOutlet UIView *viewForMap;


@end
