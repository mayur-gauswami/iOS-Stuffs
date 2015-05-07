//
//  ViewController.m
//  GmsMapViewDemo
//
//  Created by Mayur on 01/05/15.
//  Copyright (c) 2015 Mayur. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "INTULocationManager.h"


#define GOOGLE_MAP_API_KEY @"AIzaSyDA_gIs6ab_DqNQUM7oLrUNMVYx58VLMlA"
#define kCustomAlertWithParamAndTarget(title,msg,target) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:target cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]


@interface ViewController () <GMSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSArray *providers;

@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIButton *zoomLvlBtn;
@property (nonatomic) float worldWidth;

@end

@implementation ViewController

#pragma mark -
#pragma mark Properties

- (NSArray *)providers
{
    if (_providers == nil) {
        
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:19.583384 longitude:-155.854111];
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:19.249226 longitude:-155.593185];
        CLLocation *loc3 = [[CLLocation alloc] initWithLatitude:19.545858 longitude:-155.462723];
        CLLocation *loc4 = [[CLLocation alloc] initWithLatitude:19.138985 longitude:-155.720901];
        _providers = [[NSArray alloc] initWithObjects:loc1, loc2, loc3, loc4, nil];
        
    }
    
    return _providers;
}

- (GMSMapView *)mapView
{
    if (_mapView == nil) {
        [GMSServices provideAPIKey:GOOGLE_MAP_API_KEY];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:19.599486
                                                                longitude:155.481156
                                                                     zoom:6];
        self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        self.mapView.delegate = self;
        
        self.view = self.mapView;
    }
    
    return _mapView;
}

#pragma mark -
#pragma mark View Controller methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.worldWidth = (float) self.view.bounds.size.width;
    [self getCurrentLocation];
    [self addCustomButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark View methods

- (void) addCustomButtons
{
    [self.locationBtn removeFromSuperview];
    self.locationBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.locationBtn setFrame:CGRectMake(8, 25, 100, 25)];
    [self.locationBtn setTitle:@"location" forState:UIControlStateNormal];
    [self.locationBtn addTarget:self action:@selector(getCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn sizeToFit];
    [self.view addSubview:self.locationBtn];
    [self.view bringSubviewToFront:self.locationBtn];
    
    [self.zoomLvlBtn removeFromSuperview];
    self.zoomLvlBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.zoomLvlBtn setFrame:CGRectMake(250, 25, 100, 25)];
    [self.zoomLvlBtn setTitle:@"zlevel" forState:UIControlStateNormal];
    [self.zoomLvlBtn addTarget:self action:@selector(getCurrentZoom) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomLvlBtn sizeToFit];
    [self.view addSubview:self.zoomLvlBtn];
    [self.view bringSubviewToFront:self.zoomLvlBtn];
}

- (void) getCurrentZoom
{
    NSString *zoomLevel = [NSString stringWithFormat:@"%f", self.mapView.camera.zoom];
    kCustomAlertWithParamAndTarget(@"Zoom Level", zoomLevel, nil);
}

- (void) getCurrentLocation
{
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:10.0
                          delayUntilAuthorized:YES
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 [self addMarkersWithCurrentLocation:currentLocation];
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 kCustomAlertWithParamAndTarget(@"Opps!", @"Timeout occured in fetching current location", nil);
                                             }
                                             else {
                                                 kCustomAlertWithParamAndTarget(@"Opps!", @"Getting error in fetching current location", nil);
                                             }
                                         }];
}

#pragma mark -
#pragma mark MapView Methods

- (void)addMarkerToMap: (CLLocationCoordinate2D)location markerImageNamed:(NSString *)markerImageName {
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = location;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = self.mapView;
    marker.icon = [UIImage imageNamed:markerImageName];
}

- (void) addMarkersWithCurrentLocation:(CLLocation *) curLocation
{
    [self.mapView clear];
    [self addMarkerToMap:curLocation.coordinate markerImageNamed:@"pin1"];
   
    [self setZoomLevel:curLocation];
    
    for (CLLocation *loc in self.providers) {
        [self addMarkerToMap:loc.coordinate markerImageNamed:@"pin2"];
    }
    
}


#pragma mark -
#pragma mark Get Mapview center at current location with zoom level

/*
 * Solution 1
 * - First center the current location at maximum zoom level
 * - Zoom out the map untill all the marker covers in map bounds
 */


/*
- (void) setZoomLevel:(CLLocation *)curLocation
{
    [self.mapView moveCamera:[GMSCameraUpdate setTarget:curLocation.coordinate zoom:kGMSMaxZoomLevel]];
    
    GMSVisibleRegion visibleRegion = [self.mapView.projection visibleRegion];
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    
    for (CLLocation *loc in self.providers) {
        [self zoomOutToBounds:bounds marker:loc.coordinate currentZoom:self.mapView.camera.zoom];
    }
    
    [self addCustomButtons];
}

- (void) zoomOutToBounds:(GMSCoordinateBounds *) bounds marker:(CLLocationCoordinate2D)marker currentZoom:(float)zoom
{
    if (zoom <= kGMSMinZoomLevel) {
        return;
    }
    
    CGPoint point = self.mapView.center;
    CLLocationCoordinate2D curLocation = [self.mapView.projection coordinateForPoint:point];
    
    if (![bounds containsCoordinate:marker]) {
        zoom = zoom - 0.3;
        [self.mapView moveCamera:[GMSCameraUpdate setTarget:curLocation zoom:zoom]];
        
        GMSVisibleRegion visibleRegion = [self.mapView.projection visibleRegion];
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
        
        [self zoomOutToBounds:bounds marker:marker currentZoom:zoom];
    }
}
*/



/* 
 * Solution 2
 * - Locate the marker which is far away from current location horizontaly
 * - Locate the marker which is far away from current location vertically
 * - convert both coordinates to points
 * - find antipodes for both points
 * - convert new points to coordinates
 * - Create new bound which include both new points
 */


- (void) setZoomLevel:(CLLocation *)curLocation
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:curLocation.coordinate coordinate:curLocation.coordinate];
    
    CLLocationDistance distanceH = 0.0;
    CLLocationDistance distanceV = 0.0;
    CLLocation *farthestLocationH;
    CLLocation *farthestLocationV;
    
    // Find farthest points
    for (CLLocation *provider in self.providers)
    {
        bounds = [bounds includingCoordinate:provider.coordinate];
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:provider.coordinate.latitude longitude:provider.coordinate.longitude];
        CLLocationDistance diffH = fabs(curLocation.coordinate.longitude - loc.coordinate.longitude);
        CLLocationDistance diffV = fabs(curLocation.coordinate.latitude - loc.coordinate.latitude);
        
        // Horizontaly
        if(diffH > distanceH)
        {
            distanceH = diffH;
            farthestLocationH = loc;
        }
        
        // Vertically
        if (diffV > distanceV) {
            distanceV = diffV;
            farthestLocationV = loc;
        }
        
    }
    
    CGPoint curMarker = [self coordinateToPoint:curLocation.coordinate];
    
    if (farthestLocationH != nil) {
        CGPoint marker = [self coordinateToPoint:farthestLocationH.coordinate];
        
        float xval = 2*curMarker.x - marker.x;
        CLLocationCoordinate2D newMarkH = [self pointToCoordinate:(CGPoint){xval, marker.y}];
        
        bounds = [bounds includingCoordinate:newMarkH];
        
        [self addMarkerToMap:newMarkH markerImageNamed:@"1"];
    }
    
    if (farthestLocationV != nil) {
        CGPoint marker = [self coordinateToPoint:farthestLocationV.coordinate];
        
        float yval = 2*curMarker.y - marker.y;
        CLLocationCoordinate2D newMarkV = [self pointToCoordinate:(CGPoint){marker.x, yval}];
        
        bounds = [bounds includingCoordinate:newMarkV];
        
        [self addMarkerToMap:newMarkV markerImageNamed:@"2"];
    }
    
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0]];
    [self addCustomButtons];
}

- (CLLocationCoordinate2D)pointToCoordinate:(CGPoint)point {
    double x = point.x / _worldWidth - 0.5;
    double lng = x * 360;
    
    double y = .5 - (point.y / _worldWidth);
    double lat = 90 - ((atan(exp(-y * 2 * M_PI)) * 2) * (180.0 / M_PI));
    
    return CLLocationCoordinate2DMake(lat, lng);
}

- (CGPoint)coordinateToPoint:(CLLocationCoordinate2D)coordinate {
    double x = coordinate.longitude / 360 + .5;
    double siny = sin(coordinate.latitude / 180.0 * M_PI);
    double y = 0.5 * log((1 + siny) / (1 - siny)) / -(2 * M_PI) + .5;
    
    return (CGPoint){x * _worldWidth, y * _worldWidth};
}

@end
