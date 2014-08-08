//
//  MLInterestViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/26/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLInterestViewController.h"

@interface MLInterestViewController () <UITextFieldDelegate, UITextViewDelegate>

//@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) IBOutlet UITextField *userInterest1;
@property (strong, nonatomic) IBOutlet UITextField *userInterest2;
@property (strong, nonatomic) IBOutlet UITextField *userInterest3;
@property (strong, nonatomic) IBOutlet UITextField *userInterest4;
@property (strong, nonatomic) IBOutlet UITextView *userTagLine;

@property (strong, nonatomic) PFUser *user;

@end

@implementation MLInterestViewController

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
    
    /* NavBar Bottom Border */
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0] CGColor];
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];

    
    /* Making sure the Scrollview works */
    
    [scroller setScrollEnabled:YES];
    scroller.contentSize = CGSizeMake(320, 568);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [scroller addGestureRecognizer:tap];
    [self subscribeToKeyboardEvents:YES];
    
    /* Setting up all the text fields to conform to the design standards */
    
    self.userInterest1.layer.cornerRadius=8.0f;
    self.userInterest1.layer.masksToBounds=YES;
    self.userInterest1.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.userInterest1.layer.borderWidth= 1.0f;
    
    self.userInterest2.layer.cornerRadius=8.0f;
    self.userInterest2.layer.masksToBounds=YES;
    self.userInterest2.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.userInterest2.layer.borderWidth= 1.0f;
    
    self.userInterest3.layer.cornerRadius=8.0f;
    self.userInterest3.layer.masksToBounds=YES;
    self.userInterest3.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.userInterest3.layer.borderWidth= 1.0f;
    
    self.userInterest4.layer.cornerRadius=8.0f;
    self.userInterest4.layer.masksToBounds=YES;
    self.userInterest4.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.userInterest4.layer.borderWidth= 1.0f;
    
    self.userTagLine.layer.cornerRadius=8.0f;
    self.userTagLine.layer.masksToBounds=YES;
    self.userTagLine.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.userTagLine.layer.borderWidth= 1.0f;
    
    self.userInterest1.delegate = self;
    self.userInterest2.delegate = self;
    self.userInterest3.delegate = self;
    self.userInterest4.delegate = self;
    self.userTagLine.delegate = self;

    /* Pulling and assigning all the user interests to the text fields */
    
    self.user = [PFUser currentUser];
    self.navigationItem.title = self.user.username;
    self.userInterest1.text = self.user[@"interest1"];
    self.userInterest2.text = self.user[@"interest2"];
    self.userInterest3.text = self.user[@"interest3"];
    self.userInterest4.text = self.user[@"interest4"];
    self.userTagLine.text = self.user[@"tagLine"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self subscribeToKeyboardEvents:NO];
}

    /* Make sure the keyboard responds to user's request to dismiss the keyboard and scroll the view if needed */

- (void)subscribeToKeyboardEvents:(BOOL)subscribe{
    
    if(subscribe){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

    /* Make sure the keyboard shows up and pushes the view up so the text field is not being covered by the keyboard */

- (void) keyboardDidShow:(NSNotification *)nsNotification {
    
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [scroller frame];
    
    CGFloat kHeight = kbSize.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
    
    newFrame.size.height -= kHeight;
    
    [scroller setFrame:newFrame];
    
}

/* Reset the view when the keyboard is dismissed */

-(void)keyboardWillHide:(NSNotification *)nsNotification {
    
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [scroller frame];
    
    CGFloat kHeight = kbSize.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
    
    newFrame.size.height += kHeight;
    
    // save the content offset before the frame change
    CGPoint contentOffsetBefore = scroller.contentOffset;
    
    [scroller setHidden:YES];
    
    // set the new frame
    [scroller setFrame:newFrame];
    
    // get the content offset after the frame change
    CGPoint contentOffsetAfter =  scroller.contentOffset;
    
    // content offset initial state
    [scroller setContentOffset:contentOffsetBefore];
    
    [scroller setHidden:NO];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [scroller setContentOffset:contentOffsetAfter];
                     }
                     completion:^(BOOL finished){
                         // do nothing for the time being...
                     }
     ];
    
}

/* If the interests are changed by the user, then overwrite parse entry */

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([self.userInterest1 resignFirstResponder]) {
        [self.userInterest1 resignFirstResponder];
        [self.user setObject:self.userInterest1.text forKey:@"interest1"];
        //NSLog(@"Interest 1 saved");
    }
    
    if ([self.userInterest2 resignFirstResponder]) {
        [self.userInterest2 resignFirstResponder];
        [self.user setObject:self.userInterest2.text forKey:@"interest2"];
        //NSLog(@"Interest 2 saved");
    }
    if ([self.userInterest3 resignFirstResponder]) {
        [self.userInterest3 resignFirstResponder];
        [self.user setObject:self.userInterest3.text forKey:@"interest3"];
        //NSLog(@"Interest 3 saved");
    }
    if ([self.userInterest4 resignFirstResponder]) {
        [self.userInterest4 resignFirstResponder];
        [self.user setObject:self.userInterest4.text forKey:@"interest4"];
        //NSLog(@"Interest 4 saved");
    }
    if ([self.userTagLine resignFirstResponder]) {
        [self.userTagLine resignFirstResponder];
        [self.user setObject:self.userTagLine.text forKey:@"tagLine"];
        //NSLog(@"Interest Tag saved");
    }
    
    [self.user saveInBackground];
    
    return YES;
}

-(void)dismissKeyboard{
    
    if ([self.userInterest1 resignFirstResponder]) {
        [self.userInterest1 resignFirstResponder];
        [self.user setObject:self.userInterest1.text forKey:@"interest1"];
        //NSLog(@"Interest 1 saved");
    }
    
    if ([self.userInterest2 resignFirstResponder]) {
        [self.userInterest2 resignFirstResponder];
        [self.user setObject:self.userInterest2.text forKey:@"interest2"];
        //NSLog(@"Interest 2 saved");
    }
    if ([self.userInterest3 resignFirstResponder]) {
        [self.userInterest3 resignFirstResponder];
        [self.user setObject:self.userInterest3.text forKey:@"interest3"];
        //NSLog(@"Interest 3 saved");
    }
    if ([self.userInterest4 resignFirstResponder]) {
        [self.userInterest4 resignFirstResponder];
        [self.user setObject:self.userInterest4.text forKey:@"interest4"];
        //NSLog(@"Interest 4 saved");
    }
    if ([self.userTagLine resignFirstResponder]) {
        [self.userTagLine resignFirstResponder];
        [self.user setObject:self.userTagLine.text forKey:@"tagLine"];
        //NSLog(@"Interest Tag saved");
    }
    
    [self.user saveInBackground];
    
}

@end
