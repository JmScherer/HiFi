//
//  MLChatViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 3/5/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLChatViewController.h"

@interface MLChatViewController ()

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFUser *withUser;



@end

@implementation MLChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.currentUser = [PFUser currentUser];
    PFUser *checkUser = self.chatRoom[@"user1"];
    
    if([checkUser.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[@"user2"];
    }
    else{
        self.withUser = self.chatRoom[@"user1"];
    }
    
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
