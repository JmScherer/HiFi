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
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self updateUsers];
    
    self.userTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUsers) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.userTimer invalidate];
    self.userTimer = nil;
    //NSLog(@"View Did Disappear Executed");
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
    
//    if(!cell){
//        [tableView registerNib:[UINib nibWithNibName:@"MLTableViewCell" bundle:nil] forCellReuseIdentifier:@"userListCell"];
//        cell = [tableView dequeueReusableCellWithIdentifier:@"userListCell" forIndexPath:indexPath];
//    }
    
    
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
                    cell.interestOneLabel.text = [invitedUser objectForKey:@"interest1"];
                    cell.interestTwoLabel.text = [invitedUser objectForKey:@"interest2"];
                    cell.interestThreeLabel.text = [invitedUser objectForKey:@"interest3"];
                    [cell.userFunctionButton setTitle:@"Pending.." forState:UIControlStateNormal];
                    [cell.userFunctionButton setEnabled:NO];
                }
                else{
                    [invitedUsers setObject:@"chat" forKey:@"activity"];
                    [invitedUsers saveInBackground];
                    
                }
            }
        }];
    }
    
    if(indexPath.section == 1){
        PFObject *availableUsers = [self.availableUsers objectAtIndex:indexPath.row];
        PFUser *availableUser = [availableUsers objectForKey:@"user"];
        cell.usernameLabel.text = availableUser.username;
        cell.interestOneLabel.text = [availableUser objectForKey:@"interest1"];
        cell.interestTwoLabel.text = [availableUser objectForKey:@"interest2"];
        cell.interestThreeLabel.text = [availableUser objectForKey:@"interest3"];
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
        }
    }];
}

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
                [chatroom setObject:user forKey:@"user2"];
                [chatroom saveInBackground];
            }
        }
    }];
}

-(void)saveInvite:(PFUser *)user{
    PFObject *setInvite = [PFObject objectWithClassName:@"Activity"];
    [setInvite setObject:@"invite" forKey:@"activity"];
    [setInvite setObject:[PFUser currentUser] forKey:@"fromUser"];
    [setInvite setObject:user forKey:@"toUser"];
    [setInvite saveInBackground];
    [self updateUsers];
}

-(void)saveChat:(PFUser*)user{
    PFObject *setInvite = [PFObject objectWithClassName:@"Activity"];
    [setInvite setObject:@"chat" forKey:@"activity"];
    [setInvite setObject:[PFUser currentUser] forKey:@"fromUser"];
    [setInvite setObject:user forKey:@"toUser"];
    [setInvite saveInBackground];
    [self updateUsers];
}

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

-(void)userInviteApproval:(BOOL)userSelection{
    NSLog(@"userSelection %hhd", userSelection);
    
    
    
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
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

@end
