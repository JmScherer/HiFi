//
//  MLTabBarViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 7/11/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLTabBarViewController.h"

@interface MLTabBarViewController ()
@property (weak, nonatomic) IBOutlet UITabBar *customTabBarItem;

@end

@implementation MLTabBarViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITabBarItem *item0 = [self.customTabBarItem.items objectAtIndex:0];
    UITabBarItem *item1 = [self.customTabBarItem.items objectAtIndex:1];
    UITabBarItem *item2 = [self.customTabBarItem.items objectAtIndex:2];
    UITabBarItem *item3 = [self.customTabBarItem.items objectAtIndex:3];

    [item0 setImage:[[UIImage imageNamed:@"interests_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item0 setSelectedImage:[[UIImage imageNamed:@"interests_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [item1 setImage:[[UIImage imageNamed:@"whosaround_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item1 setSelectedImage:[[UIImage imageNamed:@"whosaround_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [item2 setImage:[[UIImage imageNamed:@"invite_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item2 setSelectedImage:[[UIImage imageNamed:@"invite_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [item3 setImage:[[UIImage imageNamed:@"chat_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item3 setSelectedImage:[[UIImage imageNamed:@"chat_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
