//
//  ViewController.m
//  PixLogin
//
//  Created by Dave Scruton on 5/21/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString * testMode;

//==========loginTestVC=========================================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    signedUp = false;
    
    NSString *vstr =   [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    _versionLabel.text = [NSString stringWithFormat:@"Version %@ ",vstr];

    // Do any additional setup after loading the view, typically from a nib.
}

//----LoginViewController---------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([PFUser currentUser] != nil) //already logged in?
    {
        //NSLog(@" Logged in at start:userobjectid %@",PFUser.currentUser.objectId);
        PFUser *user = PFUser.currentUser;
        NSString *duh = PFUser.currentUser.username;
        PFFile *pff = user[@"userPortrait"]; //replace with portraitkey at integrate time
        [pff getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            UIImage *profileImage = [UIImage imageNamed:@"vangogh120"];
            if (error)
            {
                NSLog(@" error fetching avatar...");
            }
            else
            {
                profileImage = [UIImage imageWithData:data];
            }
            //At this point populate FBCache:
            // fbc.fbid = PFUser.currentUser.objectId;
            // fbc.fbName = PFUser.currentUser.username;
            // fbc.fbProfileImage = profileImage;
            // [fbc addPortrait : PFUser.currentUser.objectId : PFUser.currentUser.username : profileImage];
            [self.loginButton setBackgroundImage:profileImage forState:UIControlStateNormal];
        }];
    }
    
    _instrsLabel.text = @"[Signup] Runs Signup Test.\n\nPress vanGogh icon to Login to existing account\nIf Van Gogh is not there then select it and log out first before testing";
}

//==========loginTestVC=========================================================================
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//==========loginTestVC=========================================================================
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"loginSegue"])
    {
        LoginViewController *vc = [segue destinationViewController];
        vc.entryMode = testMode;
    }

}

//==========loginTestVC=========================================================================
- (IBAction)onboardTestSelect:(id)sender
{
    testMode = PL_SIGNUP_MODE;
    [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];

}



//==========loginTestVC=========================================================================
- (IBAction)loginSelect:(id)sender
{
    if ([PFUser currentUser] != nil) //already logged in?
    {
        NSString *title = [NSString stringWithFormat:@"Logged in as %@",
                           PFUser.currentUser.username];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(title,nil)
                                                                       message:nil  //@"This is an action sheet."
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout",nil)
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  //NSLog(@" logout here...");
                                                                  [PFUser logOut];
                                                                  [self.loginButton setBackgroundImage:[UIImage imageNamed:@"vangogh120"] forState:nil];

                                                              }];
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Change Your Avatar",nil)
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  //NSLog(@" new avatar...");
                                                                  testMode = PL_AVATAR_MODE;
                                                                  
                                                                  [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];
                                                                  
                                                              }];
        UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                 // [_sfx makeTicSoundWithPitch : 8 : 51];
                                                              }];
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        [alert addAction:thirdAction];
        [self presentViewController:alert animated:YES completion:nil];

    }
    else //Not logged in: signup/login
    {
        testMode = PL_LOGIN_MODE;

        [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];
    }
}

//==========loginTestVC=========================================================================
- (IBAction)signupSelect:(id)sender
{
    [self performSegueWithIdentifier:@"loginSegue" sender:@"mainVC"];
}




@end
