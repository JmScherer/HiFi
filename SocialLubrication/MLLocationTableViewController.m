//
//  MLLocationTableViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 4/14/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLLocationTableViewController.h"
#import "MLVenue.h"
#import "MLUser.h"

@interface MLLocationTableViewController () 

@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) NSArray *tempUser;
@property (nonatomic, strong) NSString *latLong;

@end

@implementation MLLocationTableViewController {
    CLLocationManager *locationManager;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    /* NavBar Bottom Border */
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0] CGColor];
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
    
    locationManager = [[CLLocationManager alloc] init];

    [self getCurrentLocation];
    [self configureRestKit];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Starting up the GPS */

-(void)getCurrentLocation{
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

#pragma mark - Location Methods

/* Grabbing the long lat of the user and starts looking for venues nearby */

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.latLong = [NSString stringWithFormat:@"%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        NSLog(@"Latitude & Longitude: %@", self.latLong);
        [self loadVenues];
        
    }
}

/* Error checking with the GPS */

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

/* Configuring and compiling the string for the Foursquare API call */

-(void)configureRestKit{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[MLVenue class]];
    [venueMapping addAttributeMappingsFromArray:@[@"name"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:venueMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/v2/venues/search"
                                                keyPath:@"response.venues"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

/* Requests the venues near the user  */

-(void)loadVenues{

    [locationManager stopUpdatingLocation];
    
    NSString *latLon = self.latLong;
    //NSString *latLon = @"40.728848,-73.988991"; // approximate latLon of The Mothership (a.k.a Apple headquarters)
    NSString *clientID = kCLIENTID;
    NSString *clientSecret = kCLIENTSECRET;
    
    NSDictionary *queryParams = @{@"ll" : latLon,
                                  @"client_id" : clientID,
                                  @"client_secret" : clientSecret,
                                  @"intent" : @"browse",
                                  /*@"categoryId" : @"4bf58dd8d48988d1dc931735",*/
                                  /*@"limit" : @"50",*/
                                  @"radius" : @"50",
                                  @"v" : @"20140118"};
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/search"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _venues = mappingResult.array;
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _venues.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
    
    MLVenue *venue = _venues[indexPath.row];
    cell.textLabel.text = venue.name;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MLVenue *venue = _venues[indexPath.row];
    PFQuery *updateLocation = [PFQuery queryWithClassName:@"Location"];
    [updateLocation whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [updateLocation getFirstObjectInBackgroundWithBlock:^(PFObject *userLocation, NSError *error) {
        
        if(!error){
        [userLocation setValue:venue.name forKey:@"location"];
        [userLocation saveInBackground];
        MLUser *user = [MLUser sharedInstance];
        user.userLocation = venue.name;
            self.tabBarController.selectedIndex = 2;
        }
        else{
            NSLog(@"Error: %@", error);
        }
    }];

}

/* Refreshes the user's location and all the venues nearby */

- (IBAction)updateCurrentLocation:(UIBarButtonItem *)sender {
    
    [self getCurrentLocation];
}

@end
