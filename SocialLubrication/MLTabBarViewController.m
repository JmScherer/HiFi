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
    
    /* Setting title font, size, and colors */
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:241.0/255.0f green:90.0/255.0f blue:41.0/255.0f alpha:1.0f],
                                                        NSFontAttributeName : [UIFont fontWithName:@"EuphemiaUCAS" size:10.0f]
                                                        } forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f],
                                                        NSFontAttributeName : [UIFont fontWithName:@"EuphemiaUCAS" size:10.0f]
                                                        } forState:UIControlStateNormal];
    
    /* Set custom TabBar appearance: Tint & Bar Tint Colors */
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:241.0/255.0f green:90.0/255.0f blue:41/255.0f alpha:1.0f]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:241.0/255.0f green:242/255.0f blue:242.0/255.0f alpha:1.0f]];
    
    
    /* TabBar Top Border */
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 1.0f);
    topBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0f] CGColor];

    
    
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:241.0/255.0f green:242/255.0f blue:242.0/255.0f alpha:1.0f]];
    
    [self.tabBar.layer addSublayer:topBorder];
    
    /* Uncomment to make border go away, testing purposes */
    
    //self.tabBar.clipsToBounds = YES;
    
    /* TabBar Images & Titles */
    
    UITabBarItem *item0 = [self.customTabBarItem.items objectAtIndex:0];
    UITabBarItem *item1 = [self.customTabBarItem.items objectAtIndex:1];
    UITabBarItem *item2 = [self.customTabBarItem.items objectAtIndex:2];
    UITabBarItem *item3 = [self.customTabBarItem.items objectAtIndex:3];
    
    item0.title = @"Interests";
    [item0 setImage:[[UIImage imageNamed:@"interests_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item0 setSelectedImage:[[UIImage imageNamed:@"interests_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    item1.title = @"Who's Around";
    [item1 setImage:[[UIImage imageNamed:@"whosaround_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item1 setSelectedImage:[[UIImage imageNamed:@"whosaround_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    item2.title = @"Invite";
    [item2 setImage:[[UIImage imageNamed:@"invite_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item2 setSelectedImage:[[UIImage imageNamed:@"invite_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    item3.title = @"Chat";
    [item3 setImage:[[UIImage imageNamed:@"chat_unactivated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item3 setSelectedImage:[[UIImage imageNamed:@"chat_activated.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
