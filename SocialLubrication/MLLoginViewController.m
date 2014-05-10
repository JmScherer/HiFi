//
//  MLLoginViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/2/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLLoginViewController.h"
#import "MLRegistrationUserInfoViewController.h"
#import "MLUser.h"

@interface MLLoginViewController () <UITextFieldDelegate, MLRegistrationUserInfoViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;


@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;

@end

@implementation MLLoginViewController

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
    
    [self subscribeToKeyboardEvents:YES];
    
    [scroller setScrollEnabled:YES];
    scroller.contentSize = CGSizeMake(320, 568);
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [scroller addGestureRecognizer:tap];
    
    self.loginActivityIndicator.hidden = YES;
    
    //Temp Login
    
    self.usernameTextField.text = @"Jscherer";
    self.passwordTextField.text = @"Homehome1";

    scroller.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self subscribeToKeyboardEvents:NO];
}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.destinationViewController isKindOfClass:[MLRegistrationUserInfoViewController class]]){
        MLRegistrationUserInfoViewController *registerUserVC = segue.destinationViewController;
        registerUserVC.delegate = self;
        NSLog(@"Username Before: %@", self.usernameTextField.text);
        
        
        registerUserVC.userText = self.usernameTextField.text;
        NSLog(@"Username After: %@", registerUserVC.userText);
    }
    
}

#pragma mark - Text Field Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    return YES;
}

-(void)dismissKeyboard{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - Buttons


- (IBAction)createAccountButtonPressed:(UIButton *)sender {
    
    //[self performSegueWithIdentifier:@"loginToRegisterSegue" sender:self];
    
}

- (IBAction)SigninButtonPressed:(UIButton *)sender {
    
    self.loginActivityIndicator.hidden = NO;
    [self.loginActivityIndicator startAnimating];
    self.createAccountButton.enabled = NO;
    self.signinButton.enabled = NO;
    
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        
        [self.loginActivityIndicator stopAnimating];
        self.loginActivityIndicator.hidden = YES;
        self.createAccountButton.enabled = YES;
        self.signinButton.enabled = YES;
        
        if (user) {
            [self performSegueWithIdentifier:@"loginToInterestSegue" sender:self];
            [MLUser sharedInstance];
        }
        else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
    
}

#pragma mark - MLRegistrationDelegate

- (IBAction)awesomeButton:(UIButton *)sender {
    
    self.usernameTextField.text = @"Awesome";
    self.passwordTextField.text = @"Awesome";
    
    
}




@end
