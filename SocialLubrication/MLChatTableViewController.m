//
//  MLChatTableViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/27/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLChatTableViewController.h"
#import "MLProfileViewController.h"
#import "MLUserListTableViewCell.h"


@interface MLChatTableViewController ()

@property (strong, nonatomic) NSMutableArray *availableUsers;
@property (strong, nonatomic) NSMutableArray *invitedUsers;
@property (strong, nonatomic) NSTimer *userTimer;

@end

@implementation MLChatTableViewController

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
    
    [self updateUsers];
    
    self.userTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUsers) userInfo:nil repeats:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUsers{
    [self updateAvailableUsers];
    [self checkInvite];
}


#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    MLProfileViewController *usrProfile = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    usrProfile.userProfile = [self.availableUsers objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){ return [self.invitedUsers count]; }
    else return [self.availableUsers count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MLUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userListCell"];
    if(!cell){
        [tableView registerNib:[UINib nibWithNibName:@"MLTableViewCell" bundle:nil] forCellReuseIdentifier:@"userListCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"userListCell"];
    }
    
    if(indexPath.section == 0){
        
        PFObject *invitedUsers = [self.invitedUsers objectAtIndex:indexPath.row];
        PFUser *invitedUser = [invitedUsers objectForKey:@"toUser"];
        cell.usernameLabel.text = invitedUser.username;
        [cell.userFunctionButton setTitle:@"Chat" forState:UIControlStateNormal];
        [cell.userFunctionButton addTarget:self
                                    action:@selector(chatFriend:) forControlEvents:UIControlEventTouchUpInside];
        }
    
    if(indexPath.section == 1){
        PFObject *availableUsers = [self.availableUsers objectAtIndex:indexPath.row];
        PFUser *availableUser = [availableUsers objectForKey:@"user"];
        cell.usernameLabel.text = availableUser.username;
        [cell.userFunctionButton setTitle:@"Invite" forState:UIControlStateNormal];
        [cell.userFunctionButton addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.userFunctionButton setTag:indexPath.row];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"usersToProfileSegue" sender:indexPath];
}

#pragma mark - UI Buttons

-(IBAction)inviteFriend:(id)sender{
    
    UIButton *button = (UIButton *)sender;
    
    [button setTitle:@"Pending.." forState:UIControlStateNormal];
    [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    PFUser *user = [self.availableUsers objectAtIndex:[sender tag]];
    [self saveInvite:user];
}

-(IBAction)chatFriend:(id)sender{
    NSLog(@"Open Chatroom");
}

#pragma mark - Helper Methods

-(void)updateAvailableUsers{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Location"];
    [query includeKey:@"user"];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"location" equalTo:@"Grassroots"];

    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
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
    [locationQuery whereKey:@"location" equalTo:@"Grassroots"];
    [locationQuery whereKey:@"user" notEqualTo:[PFUser currentUser]];
    
    PFQuery *activityQuery = [[PFQuery alloc] initWithClassName:@"Activity"];
    [activityQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [activityQuery includeKey:@"fromUser"];
    [activityQuery includeKey:@"toUser"];
    [locationQuery whereKey:@"activity" matchesKey:@"invite" inQuery:activityQuery];
    
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
                [self.invitedUsers removeAllObjects];
                self.invitedUsers = [objects mutableCopy];
                [self.tableView reloadData];
                //NSLog(@"Invited Users: %@", self.invitedUsers);
            }
    }];
    
}

-(void)saveInvite:(PFUser *)user{
    PFObject *setInvite = [PFObject objectWithClassName:@"Activity"];
    [setInvite setObject:@"invite" forKey:@"activity"];
    [setInvite setObject:[PFUser currentUser] forKey:@"fromUser"];
    [setInvite setObject:user[@"user"] forKey:@"toUser"];
    [setInvite saveInBackground];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
