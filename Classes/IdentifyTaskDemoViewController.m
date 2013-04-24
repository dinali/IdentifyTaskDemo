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


#import "IdentifyTaskDemoViewController.h"
//#define kDynamicMapServiceURL @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer"

#define kDynamicMapServiceURL @"http://gis2.ers.usda.gov/ArcGIS/rest/services/snap_Benefits/MapServer"

@implementation IdentifyTaskDemoViewController
@synthesize mapView=_mapView;
@synthesize graphicsLayer=_graphicsLayer;
@synthesize identifyTask=_identifyTask,identifyParams=_identifyParams; 
@synthesize mappoint = _mappoint;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	_mapView.touchDelegate = self;
    _mapView.callout.delegate = self;

	// create a dynamic map service layer
	AGSDynamicMapServiceLayer *dynamicLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:kDynamicMapServiceURL]];
	
	// set the visible layers on the layer
	dynamicLayer.visibleLayers = [NSArray arrayWithObjects:[NSNumber numberWithInt:5], nil];
	
	// add the layer to the map
	[self.mapView addMapLayer:dynamicLayer withName:@"Dynamic Layer"];
	
	// since we alloc-init the layer, we must release it
	[dynamicLayer release];
	
	// create and add the graphics layer to the map
	self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
	[self.mapView addMapLayer:self.graphicsLayer withName:@"Graphics Layer"];
	
	//create identify task
	self.identifyTask = [AGSIdentifyTask identifyTaskWithURL:[NSURL URLWithString:kDynamicMapServiceURL]];
	self.identifyTask.delegate = self;
	
	//create identify parameters
	self.identifyParams = [[[AGSIdentifyParameters alloc] init] autorelease];
	
    [super viewDidLoad];
}

#pragma mark - AGSCalloutDelegate methods

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics {

    //store for later use
    self.mappoint = mappoint;
    
	//the layer we want is layer ‘5’ (from the map service doc)
	self.identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], nil];
	self.identifyParams.tolerance = 3;
	self.identifyParams.geometry = self.mappoint;
	self.identifyParams.size = self.mapView.bounds.size;
	self.identifyParams.mapEnvelope = self.mapView.visibleArea.envelope;
	self.identifyParams.returnGeometry = YES;
	self.identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
	self.identifyParams.spatialReference = self.mapView.spatialReference;
    
	//execute the task
	[self.identifyTask executeWithParameters:self.identifyParams];
}


#pragma mark - AGSIdentifyTaskDelegate methods
//results are returned
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didExecuteWithIdentifyResults:(NSArray *)results {
    
    //clear previous results
    [self.graphicsLayer removeAllGraphics];
    
    if ([results count] > 0) {
        
        //add new results
        AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        symbol.color = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5];
        
        AGSGraphic *passGraphic = [[AGSGraphic alloc]init];
        
        @try {
            
            // for each result, set the symbol and add it to the graphics layer
            for (AGSIdentifyResult* result in results) {
                result.feature.symbol = symbol;
                [self.graphicsLayer addGraphic:result.feature];
                passGraphic = result.feature;
                
                // this passes the layer instead of the graphic?
            }
        
        // obsolete methods
        //set the callout content for the first result
        //get the state name
       // NSString *stateName = [((AGSIdentifyResult*)[results objectAtIndex:0]).feature.attributes objectForKey:@"STATE_NAME"];
        
      //  NSString *geographyName = [((AGSIdentifyResult*)[results objectAtIndex:0]).feature.attributeForKey:@"FIPSTXT"];
       
    // IS THIS A BUG?? CAN'T ACCESS PROPERTY
        //[((AGSIdentifyResult*)[results objectAtIndex:0]).feature.attributeForKey:@"STATE_NAME"];
        
        // SNAP uses FIPSTXT, try 06 for CA
        NSString *stateName = @"Tract Information";
        
        self.mapView.callout.title = stateName; // this is just the title
        self.mapView.callout.detail = @"Click for more detail..";
        
        //show callout
        [self.mapView.callout showCalloutAt:self.mappoint pixelOffset:CGPointZero animated:YES];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        @finally {
            NSLog(@"finally");
        }
    }
    
    //call dataChanged on the graphics layer to redraw the graphics
   // [self.graphicsLayer dataChanged];
}

// NEW!
- (void) didClickAccessoryButtonForCallout:(AGSCallout *)callout{
    
    // callout.representedObject is CALayer - is that AGSMapViewLayer? does that still exist? Need the graphic instead cast it?
    
    if([callout.representedObject isKindOfClass:[AGSLayer class]]){
        NSLog(@"it's a layer!!"); // how to get the graphic?
    }
    
    if([callout.representedObject isKindOfClass: [AGSPoint class]]){
        AGSPoint* point = (AGSPoint*) callout.representedObject;
        //...
    }
    else if([callout.representedObject isKindOfClass: [AGSLocationDisplay class]]){
        AGSLocationDisplay* ld = (AGSLocationDisplay*) callout.representedObject;
        //...
    }
    else if([callout.representedObject isKindOfClass: [AGSGraphic class]]){
        AGSGraphic* graphic = (AGSGraphic*) callout.representedObject;
        //The user clicked the callout button, so display the complete set of results
    
        ResultsViewController *resultsVC = [[ResultsViewController alloc] initWithNibName:@"ResultsViewController" bundle:nil];
        
        //set our attributes/results into the results VC
        resultsVC.results = graphic.allAttributes; // NSDictionary
        
        //display the results vc modally
        [self presentViewController:resultsVC animated:YES completion:NULL];
        
        //cleanup
        //[resultsVC release];
    }
}

//if there's an error with the query display it to the user
- (void)identifyTask:(AGSIdentifyTask *)identifyTask operation:(NSOperation *)op didFailWithError:(NSError *)error {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	//[alert release];
}

#pragma mark 

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	self.graphicsLayer = nil;
	self.identifyTask = nil;
	self.identifyParams = nil;
	self.mapView = nil;
	
    [super dealloc];
}

@end
