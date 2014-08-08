//
//  MLChatTableViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/27/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLPatronsTableViewController.h"
#import "MLProfileViewController.h"
#import "MLUserListTableViewCell.h"
#import "MLChatRoomViewController.h"
#import "MLUser.h"


@interface MLPatronsTableViewController ()

@property (strong, nonatomic) NSMutableArray *availableUsers;
@property (strong, nonatomic) NSMutableArray *invitedUsers;
@property (strong, nonatomic) NSTimer *userTimer;
@property (strong, nonatomic) NSMutableArray *checkChat;

@property (strong, nonatomic) PFUser *selectedUser;

@end

@implementation MLPatronsTableViewController

-(NSMutableArray *)availableUsers{
    if(!_availableUsers){
        _availableUsers = [[NSMutableArray alloc] init];
    }
    return _availableUsers;
}

-(NSMutableArray *)invitedUsers{
    if(!_invitedUsers){
        _invitedUsers = [[NSMutableArray alloc] init];
    }
    return _invitedUsers;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    /* NavBar Bottom Border */
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0] CGColor];
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
}

-(void)viewWillAppear:(BOOL)animated{
    
    MLUser *tempUser = [MLUser sharedInstance];
    
    self.navigationItem.title = tempUser.userLocation;
    
    /* Starts updating users who checked into the venue on a timed basis */
    
    [self updateUsers];
    
    self.userTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUsers) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.userTimer invalidate];
    self.userTimer = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUsers{
    [self checkInvite];
    [self updateAvailableUsers];
}


#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    /* Segues to the user's profile */
    
    if([segue.destinationViewController isKindOfClass:[MLProfileViewController class]]){
    
    MLProfileViewController *usrProfile = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
        
    if(indexPath.section == 0){
        
        PFObject *userInfo = [self.invitedUsers objectAtIndex:indexPath.row];
        PFUser *user = [userInfo objectForKey:@"toUser"];
        
        usrProfile.userProfile = user;
        
    }
    else {
        
        PFObject *userInfo = [self.availableUsers objectAtIndex:indexPath.row];
        PFUser *user = [userInfo objectForKey:@"user"];
        usrProfile.userProfile = user;
        }
    }
    
    /* Segues to the chat invite page */
    
    if([segue.destinationViewController isKindOfClass:[MLPeopleViewController class]]){
        
        MLPeopleViewController *imageArrayVC = segue.destinationViewController;
        imageArrayVC.delegate = self;
        
        imageArrayVC.selectedUser = self.selectedUser;
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [self.invitedUsers count];
    else return [self.availableUsers count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"MLTableViewCell" bundle:nil] forCellReuseIdentifier:@"userListCell"];
    MLUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userListCell" forIndexPath:indexPath];
    [cell.userFunctionButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    /* Pulls and displays all the individuals that the user successfully invited to chat */
    
    if(indexPath.section == 0){
        PFObject *invitedUsers = [self.invitedUsers objectAtIndex:indexPath.row];
        PFUser *invitedUser = [invitedUsers objectForKey:@"toUser"];

        PFQuery *inverseQuery = [[PFQuery alloc] initWithClassName:@"Activity"];
        [inverseQuery whereKey:@"fromUser" equalTo:invitedUser];
        [inverseQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [inverseQuery whereKey:@"activity" equalTo:@"chat"];
        [inverseQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                self.checkChat = [objects mutableCopy];
                //NSLog(@"createChatRoom: %@", self.checkChat);
                
                if([self.checkChat count] == 0){
                    cell.usernameLabel.text = invitedUser.username;
                    
                    NSString *tmpInterest = [NSString stringWithFormat:@"%@, %@, %@", [invitedUser objectForKey:@"interest1"], [invitedUser objectForKey:@"interest2"], [invitedUser objectForKey:@"interest3"]];
                    
                    cell.interestOneLabel.text = tmpInterest;
                    
                    [cell.userFunctionButton setTitle:@"Pending.." forState:UIControlStateNormal];
                    [cell.userFunctionButton setEnabled:NO];
                }
                else{
                    [invitedUsers setObject:@"chat" forKey:@"activity"];
                    [invitedUsers saveInBackground];
                }}}];
    }
    
    /* Displays all the users that are available for invite */
    
    if(indexPath.section == 1){
        PFObject *availableUsers = [self.availableUsers objectAtIndex:indexPath.row];
        PFUser *availableUser = [availableUsers objectForKey:@"user"];
        
        NSString *tmpInterest = [NSString stringWithFormat:@"%@, %@, %@", [availableUser objectForKey:@"interest1"], [availableUser objectForKey:@"interest2"], [availableUser objectForKey:@"interest3"]];
        
        cell.usernameLabel.text = availableUser.username;
        
        cell.interestOneLabel.text = tmpInterest;
        
        [cell.userFunctionButton setTitle:@"Invite" forState:UIControlStateNormal];
        [cell.userFunctionButton addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.userFunctionButton setEnabled:YES];
        [cell.userFunctionButton setTag:indexPath.row];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"usersToProfileSegue" sender:indexPath];
}

#pragma mark - UI Buttons

-(IBAction)inviteFriend:(UIButton*)sender{
    
    PFObject *object = [self.availableUsers objectAtIndex:[sender tag]];
    self.selectedUser = [object objectForKey:@"user"];
    
    [self performSegueWithIdentifier:@"inviteToArraySegue" sender:[UIButton class]];
    
    [sender setTitle:@"Pending.." forState:UIControlStateNormal];
    [sender setEnabled:NO];
}

#pragma mark - Helper Methods

/* Pulls all the individuals that the user successfully invited to chat */

-(void)updateAvailableUsers{

    MLUser *userLocation = [MLUser sharedInstance];
    
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Location"];
    [query includeKey:@"user"];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"location" equalTo:userLocation.userLocation];
    
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"user" doesNotMatchKey:@"toUser" inQuery:activityQuery];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            [self.availableUsers removeAllObjects];
            self.availableUsers = [objects mutableCopy];
            [self.tableView reloadData];
            //NSLog(@"User List: %@", self.availableUsers);
        }
    }];
}

/* Pulls all the individuals that the user has successfully invited to chat */

-(void)checkInvite{
    
    PFQuery *locationQuery = [[PFQuery alloc] initWithClassName:@"Location"];
    [locationQuery whereKey:@"user" notEqualTo:[PFUser currentUser]];
    
    PFQuery *activityQuery = [[PFQuery alloc] initWithClassName:@"Activity"];
    [activityQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [activityQuery whereKey:@"activity" equalTo:@"invite"];
    [activityQuery includeKey:@"fromUser"];
    [activityQuery includeKey:@"toUser"];
    
    [locationQuery whereKey:@"location" matchesKey:@"Grassroots" inQuery:activityQuery];
    
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            [self.invitedUsers removeAllObjects];
            self.invitedUsers = [objects mutableCopy];
            [self.tableView reloadData];
            //NSLog(@"Invited Users: %@", self.invitedUsers);
        }}];
}

/* Checks to see if both the user and any individual have successfully invited each other to chat and then subsequently creates a chatroom for both */

-(void)createChatRoom:(PFUser *)user{
    PFQuery *query = [ PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    [query whereKey:@"user2" equalTo:user];
    
    PFQuery *inverseQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [inverseQuery whereKey:@"user1" equalTo:user];
    [inverseQuery whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query, inverseQuery]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error){
            if([objects count] == 0){
                PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
                [chatroom setObject:[PFUser currentUser] forKey:@"user1"];
                [chatroom setObject:@NO forKey:@"user1Avatar"];
                [chatroom setObject:user forKey:@"user2"];
                [chatroom setObject:@NO forKey:@"user2Avatar"];
                [chatroom saveInBackground];
                
            }}}];
}

/* Saves whether or not a user was invited */

-(void)saveInvite:(PFUser *)user{
    PFObject *setInvite = [PFObject objectWithClassName:@"Activity"];
    [setInvite setObject:@"invite" forKey:@"activity"];
    [setInvite setObject:[PFUser currentUser] forKey:@"fromUser"];
    [setInvite setObject:user forKey:@"toUser"];
    [setInvite saveInBackground];
    [self updateUsers];
}

/* Saves whether or not users entered into a chatroom with each other */

-(void)saveChat:(PFUser*)user{
    PFObject *setInvite = [PFObject objectWithClassName:@"Activity"];
    [setInvite setObject:@"chat" forKey:@"activity"];
    [setInvite setObject:[PFUser currentUser] forKey:@"fromUser"];
    [setInvite setObject:user forKey:@"toUser"];
    [setInvite saveInBackground];
    [self updateUsers];
}

/* If a user unsuccesfully invites an individual, it saves uninvited */

-(void)saveUninvite:(PFUser*)user{
    PFObject *setInvite = [PFObject objectWithClassName:@"Activity"];
    [setInvite setObject:@"Uninvite" forKey:@"activity"];
    [setInvite setObject:[PFUser currentUser] forKey:@"fromUser"];
    [setInvite setObject:user forKey:@"toUser"];
    [setInvite saveInBackground];
    [self updateUsers];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark - MLPeopleViewController Delegate Method

/* Performs the logic to check whether or not the user should invite or open a chatroom with an individual */

-(void)userInviteApproval:(BOOL)userSelection{

    if(userSelection == YES){
    PFQuery *queryForInvite = [PFQuery queryWithClassName:@"Activity"];
    [queryForInvite whereKey:@"fromUser" equalTo:self.selectedUser];
    [queryForInvite whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [queryForInvite whereKey:@"activity" equalTo:@"invite"];
    
    [queryForInvite findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.checkChat = [objects mutableCopy];
            if([self.checkChat count] == 0){
                [self saveInvite:self.selectedUser];
            }
            else {
                [self saveChat:self.selectedUser];
                [self createChatRoom:self.selectedUser];
            }
        }
    }];
    }
    else [self saveUninvite:self.selectedUser];

         [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/* Cancels an invite in the event the user does not want to invite said user to chat */

-(void)cancelInvite{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
