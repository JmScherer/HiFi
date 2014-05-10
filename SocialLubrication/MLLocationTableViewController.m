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

@end

@implementation MLLocationTableViewController


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
    
    CLController = [[MLCoreLocation alloc] init];
    CLController.delegate = self;
    [CLController.locMgr startUpdatingLocation];
    
    
    [self configureRestKit];
    [self loadVenues];
    
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

-(NSString*)getCoordinates{
    
    NSString *coordinates = [[NSString alloc] init];
    
    return coordinates;
}

-(void)locationUpdate:(CLLocation *)location{
    
    
}

-(void)locationError:(NSError *)error{
    
}

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

-(void)loadVenues{
    NSString *latLon = @"40.728848,-73.988991"; // approximate latLon of The Mothership (a.k.a Apple headquarters)
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
    
    NSLog(@"this happened");
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
        //[self performSegueWithIdentifier:@"locationToPatronsSegue" sender:self];
        }
        else{
            NSLog(@"Error: %@", error);
        }
    }];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    NSLog(@"this happened");
//    
//    NSIndexPath *indexPath = sender;
//    MLVenue *venue = _venues[indexPath.row];
//    PFQuery *updateLocation = [PFQuery queryWithClassName:@"Location"];
//    [updateLocation whereKey:@"user" equalTo:[PFUser currentUser]];
//    
//    [updateLocation getFirstObjectInBackgroundWithBlock:^(PFObject *userLocation, NSError *error) {
//        
//        if(!error){
//            [userLocation setValue:venue.name forKey:@"location"];
//            [userLocation saveInBackground];
//            MLUser *user = [MLUser sharedInstance];
//            user.userLocation = venue.name;
//            [self performSegueWithIdentifier:@"" sender:self];
//        }
//        else{
//            NSLog(@"Error: %@", error);
//        }
//    }];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
