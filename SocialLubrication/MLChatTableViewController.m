//
//  MLChatTableViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 5/5/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLChatTableViewController.h"
#import "MLUserListTableViewCell.h"
#import "MLProfileViewController.h"
#import "MLChatRoomViewController.h"

@interface MLChatTableViewController ()

@property (strong, nonatomic) NSMutableArray *chatRooms;
@property (strong, nonatomic) NSTimer *userTimer;

@property (strong, nonatomic) PFObject *selectedChatRoom;

@end

@implementation MLChatTableViewController

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
    
    [self updateAvailableChatRooms];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    
    self.userTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateAvailableChatRooms) userInfo:nil repeats:YES];
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

#pragma mark - Chat room update

-(void)updateAvailableChatRooms{
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    
    PFQuery *inverseQuery = [PFQuery queryWithClassName:@"ChatRoom"];
    [inverseQuery whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[query, inverseQuery]];
    [combinedQuery includeKey:@"user1"];
    [combinedQuery includeKey:@"user2"];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            [self.chatRooms removeAllObjects];
            self.chatRooms = [objects mutableCopy];
            [self.tableView reloadData];
            //[self checkInvite];
            NSLog(@"Chat Rooms: %@", self.chatRooms);
        }
    }];
    
}

#pragma mark - Chat Room Segue Methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.destinationViewController isKindOfClass:[MLProfileViewController class]]){
        
        MLProfileViewController *usrProfile = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        
            
            PFObject *chatUsers = [self.chatRooms objectAtIndex:indexPath.row];
            PFUser *chatUser;
            PFUser *currentUser = [PFUser currentUser];
            PFUser *testUser1 = [chatUsers objectForKey:@"user1"];
            
            if([testUser1.objectId isEqual:currentUser.objectId]){
                chatUser = [chatUsers objectForKey:@"user2"];
            }
            else chatUser = [chatUsers objectForKey:@"user1"];
            
            usrProfile.userProfile = chatUser;
        }

    if([segue.destinationViewController isKindOfClass:[MLChatRoomViewController class]]){
        
        MLChatRoomViewController *chatVC = segue.destinationViewController;
        chatVC.chatRoom = self.selectedChatRoom;
        
    }
}


-(IBAction)chatFriend:(UIButton*)sender{
    
    self.selectedChatRoom = [self.chatRooms objectAtIndex:[sender tag]];
    
    [self performSegueWithIdentifier:@"chatTableToChatSegue" sender:[UIButton class]];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatRooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerNib:[UINib nibWithNibName:@"MLTableViewCell" bundle:nil] forCellReuseIdentifier:@"userListCell"];
    MLUserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userListCell" forIndexPath:indexPath];
    [cell.userFunctionButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    PFObject *chatUsers = [self.chatRooms objectAtIndex:indexPath.row];
    PFUser *chatUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = [chatUsers objectForKey:@"user1"];
    
    if([testUser1.objectId isEqual:currentUser.objectId]){
        chatUser = [chatUsers objectForKey:@"user2"];
    }
    else chatUser = [chatUsers objectForKey:@"user1"];
    
    cell.usernameLabel.text = chatUser.username;
    cell.interestOneLabel.text = [chatUser objectForKey:@"interest1"];
    cell.interestTwoLabel.text = [chatUser objectForKey:@"interest2"];
    cell.interestThreeLabel.text = [chatUser objectForKey:@"interest3"];
    [cell.userFunctionButton setTitle:@"Chat" forState:UIControlStateNormal];
    [cell.userFunctionButton addTarget:self
                                action:@selector(chatFriend:) forControlEvents:UIControlEventTouchUpInside];
    [cell.userFunctionButton setEnabled:YES];
    [cell.userFunctionButton setTag:indexPath.row];
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"chatToProfileSegue" sender:indexPath];
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

@end
