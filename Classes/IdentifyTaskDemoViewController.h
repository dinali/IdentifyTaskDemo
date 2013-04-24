// Copyright 2012 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the use restrictions at http://help.arcgis.com/en/sdk/10.0/usageRestrictions.htm
//


#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "ResultsViewController.h"

@interface IdentifyTaskDemoViewController : UIViewController <AGSMapViewTouchDelegate, AGSIdentifyTaskDelegate, AGSCalloutDelegate> {

	AGSMapView *_mapView;
	AGSGraphicsLayer *_graphicsLayer;
	AGSIdentifyTask *_identifyTask;
	AGSIdentifyParameters *_identifyParams;
    AGSPoint* _mappoint;
}

@property (nonatomic, retain) IBOutlet AGSMapView *mapView;
@property (nonatomic, retain) AGSGraphicsLayer *graphicsLayer;
@property (nonatomic, retain) AGSIdentifyTask *identifyTask;
@property (nonatomic, retain) AGSIdentifyParameters *identifyParams;
@property (nonatomic, retain) AGSPoint* mappoint;

@end

