//
//  FBLoginVC.h
//  pix
//
//  Created by Dave Scruton on 8/6/17.
//  Copyright © 2017 Huedoku Labs. All rights reserved.
//
//  Links / etc: There is something weird going on logging in on phone vs simulator
//   https://developers.facebook.com/docs/facebook-login
//  Take a look here for more examples? (downloaded to Docs folder!)
//   https://github.com/fbsamples/account-kit-samples-for-ios
//
//  DHS 2/9/18 new mechanism for fbc name/portrait fetch


#import "DebugFlags.h"
#import "FBLoginVC.h"

@implementation FBLoginVC

@synthesize delegate = _delegate;

//==========<<<FBLogin>>>=================================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;

    fbc = [PIXFBCache sharedInstance];
    fbt = [[FBTools alloc] init];
    fbt.delegate      = self;
    loggingIn         = FALSE;
    fbakJustCancelled = FALSE;
    gotAKLogin        = FALSE;
    
#ifdef USE_SFX
    _sfx = [soundFX sharedInstance];
#endif

    return self;
}


//==========<<<FBLogin>>>=================================================================
- (void)viewDidLoad {
    NSLog(@" FBLoginVC viewDidLoad");
    [super viewDidLoad];
    
    if (_accountKit == nil) {
        //NSLog(@" init accountKit...");
        _accountKit = [[AKFAccountKit alloc] initWithResponseType: AKFResponseTypeAccessToken];
    }

}

//==========<<<FBLogin>>>=================================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!loggingIn)
    {
        _fbLoginView.hidden       = FALSE;
        _backButton.hidden        = FALSE;
        _activityIndicator.hidden = TRUE;
    }
} //end viewWillAppear


//==========<<<FBLogin>>>=================================================================
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getAKnum]; //DHS 11/14 pull account # from accountKit object
    if (!fbakJustCancelled) //Make sure we aren't coming back from a cancel op in fbak
    {
        fbakJustCancelled = FALSE;
    }
    //    [fbt fetchUserInfo]; //See if we were logged in to FB
    
}


//==========<<<FBLogin>>>=================================================================
-(void) loadView
{
    [super loadView];
    
} //end loadView


//==========<<<FBLogin>>>=================================================================
// If accountKit object is properly configured, fetches accountID , etc
//  Presents FBAK login VC if needed!
-(void) getAKnum
{
    if (_accountKit == nil) {
        NSLog(@" getAKnum err: nil accountKit");
        return;
    }
    NSLog(@"FB AK: request account info... %@",_accountKit);
    [_accountKit requestAccount:^(id<AKFAccount> account, NSError *error) {
        if (error != nil) {
            //NSLog(@" FB AK error... %@",error);
        } else {
            FBAKaccountID = account.accountID;
            NSLog(@" token? FBAKaccountID : %@" , FBAKaccountID);
            if (FBAKaccountID != nil)  //Got something? lookup acct and save if new...
            {
                FBAKaccountPhoneNumber    = [account.phoneNumber stringRepresentation];
                if ([whichLogin containsString:@"email"])
                    FBAKaccountEmailAddress   = account.emailAddress;
                else
                {
                    AKFPhoneNumber *pn        = account.phoneNumber;
                    FBAKaccountEmailAddress   = pn.stringRepresentation; //we only save email addy...
                    FBAKaccountPhoneNumber    = pn.stringRepresentation;
                }
                //NSLog(@" OK! FB accountID/phone/email... %@/%@/%@",
                //      FBAKaccountID,FBAKaccountPhoneNumber,FBAKaccountEmailAddress);
                //Prompt for new account info...
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                if ([appDelegate.uu isFBIDNew:FBAKaccountID])
                {
                    NSLog(@" segue to FBInfoVC...");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"fbInfoSegue" sender:@"FBLoginVC"];
                    });
                }
                else  //Account already exists? Pull from parse...
                {
                    //NSLog(@" account already exists, already logged in, need to get from parse...");
                    NSUInteger index = [fbc.fbids indexOfObject : FBAKaccountID ]; //11/25 Find ID
                    if (index != NSNotFound)
                    {
                        //Are we in range and is array legit?
                        FBAKaccountName = @"emptyFBCName";
                        //DHS 2/9/18 new mechanism for fbc name/portrait fetch
                        NSString *tname = [fbc getFBNameByID:FBAKaccountID];
                        if (tname != nil)
                        {
                            FBAKaccountName    = tname;
                            fbc.fbProfileImage = [fbc getPortraitByID:FBAKaccountID];
                            fbc.fbName = FBAKaccountName;
                        }

                        //OK We have all our info, inform parent and clobber this VC
//                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.delegate needToUpdateLoginButton : TRUE];
                            [self dismissViewControllerAnimated : NO completion:nil];
//                        });

                    }
                } //end else
            } //end if FBAK...
        }
    }]; //end requestAccount block
    
} //end getAKnum


//==========<<<FBLogin>>>=================================================================
-(void) updateUIForLogin : (BOOL) aboutToLogIn
{

    _fbLoginView.hidden       = aboutToLogIn;
    _backButton.hidden        = aboutToLogIn;
    _activityIndicator.hidden = !aboutToLogIn;

    if (aboutToLogIn)
    {
        [_activityIndicator startAnimating];
    }
    else
    {
        [_activityIndicator stopAnimating];
    }
} //end updateUIForLogin

//==========<<<FBLogin>>>=================================================================
- (IBAction)FBLoginSelect:(id)sender
{
    [self updateUIForLogin:TRUE];

    loggingIn = TRUE;

    [fbt login : self];

}

//==========<<<FBLogin>>>=================================================================
- (IBAction)mobileSelect:(id)sender
{
    [self updateUIForLogin:TRUE];
    loggingIn = TRUE;
    [self loginWithPhone];

}

//==========<<<FBLogin>>>=================================================================
- (IBAction)emailSelect:(id)sender
{
    [self updateUIForLogin:TRUE];

    loggingIn = TRUE;
    [self loginWithEmail];

}

//==========<<<FBLogin>>>=================================================================
- (IBAction)backSelect:(id)sender
{
#ifdef USE_SFX
    [_sfx makeTicSoundWithPitch : 8 : 48];
#endif
    [self dismissViewControllerAnimated : YES completion:nil];
}


//==========<<<FBLogin>>>=================================================================
- (void)loginWithPhone
{
    AKFPhoneNumber *pnumber;
    //NSString *preFillPhoneNumber = @"555-1234";
    NSString *inputState = [[NSUUID UUID] UUIDString];
    //NOTE: some examples just pass nil for both args below...??
    UIViewController<AKFViewController> *viewController =
    [_accountKit viewControllerForPhoneLoginWithPhoneNumber: pnumber //11/18 was using string; use object instead
                                                      state: inputState];
    viewController.enableSendToFacebook = YES;          // defaults to NO
    viewController.delegate = self;
    [self _prepareLoginViewController:viewController]; // see below
    [self presentViewController:viewController animated:YES completion:NULL];
    //_fbakPhone = 1;
    
} //end loginWithPhone

//==========<<<FBLogin>>>=================================================================
- (void)loginWithEmail
{
    NSString *inputState = [[NSUUID UUID] UUIDString];
    //NOTE: some examples just pass nil for both args below...??
    UIViewController<AKFViewController> *viewController =
    [_accountKit viewControllerForEmailLoginWithEmail : preFillEmailAddress
                                                state : inputState];
    viewController.delegate = self;
    [self _prepareLoginViewController:viewController]; // see below
    [self presentViewController:viewController animated:YES completion:NULL];
    //_fbakEmail = 1;
} //end loginWithEmail

//==========<<<FBLogin>>>=================================================================
- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)loginViewController
{
    loginViewController.delegate = self;
}


//==========HDKPIX=========================================================================
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"fbInfoSegue"])
    {
        NSLog(@" ...set FBAKInfoVC Delegate...");
        //Make sure we handle delegate returns!!
        FBAKInfoVC *vc = [segue destinationViewController];
        vc.delegate = self;
    }
}


#pragma mark - AKFViewControllerDelegate

//==========<<<FBLogin>>>=================================================================
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state
{
    NSLog(@" AKFViewController got accesstoken %@",accessToken);
    FBAKaccountID = accessToken.accountID;
    gotAKLogin = TRUE;
}

//==========<<<FBLogin>>>=================================================================
- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
    NSLog(@" AKFViewController didFailWithError");
    gotAKLogin = FALSE;
}

//==========<<<FBLogin>>>=================================================================
- (void) viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController
{
    NSLog(@" AKFViewController cancelled");
    gotAKLogin = FALSE;
    
}


#pragma mark - FBAKInfoVCDelegate

//==========<<<FBLogin>>>=================================================================
-(void) finishUpFBAK
{
//    [fbt addPortaitForFBAK  : FBAKaccountID : fbc.fbName : fbc.fbProfileImage];
    [fbc addPortrait : FBAKaccountID : fbc.fbName : fbc.fbProfileImage ];
    [self manageFBAK];
    //Note we have 2 login flags now!
    fbc.loggedInFBAK = TRUE;
    fbc.loggedIn     = FALSE;
}

//==========<<<FBLogin>>>=================================================================
//  User is logged in but has NO photo and NO name...??
- (void)fbakInfoDidCancel
{
    NSLog(@" fbakInfoDidCancel...");
    fbc.fbName = @"noname";
    fbc.fbProfileImage = [UIImage imageNamed:@"emptyUser"];
    [self finishUpFBAK];
}


//==========<<<FBLogin>>>=================================================================
// User just came back with a new portrait and name (phone/email login)
- (void)fbakInfoDidSelectOK : (NSString *) name : (UIImage *) portrait
{
    NSLog(@" fbakInfoDidSelectOK...");
    fbc.fbName = name;
    fbc.fbProfileImage = portrait;
    [self finishUpFBAK];
}



//FBTools Delegate behavior...
//==========<<<FBLogin>>>=================================================================
- (void)didFBTLogIn
{
    NSLog(@" FBLoginVC didFBTLogIn");

    //[self cleanupScreen];
    fbc.loggedIn     = fbt.loggedIn;
    fbc.loggedInFBAK = FALSE;
    //Tell Parent UI to update...
    [self.delegate needToUpdateLoginButton : TRUE];
    
} //end didFBTLogIn

//==========<<<FBLogin>>>=================================================================
// Does this ever hit here???
- (void)didFBTLogOut
{
    NSLog(@" FBLoginVC didlogout");
    loggingIn = FALSE;
    fbc.loggedIn     = FALSE;
    fbc.loggedInFBAK = FALSE;
    //Tell Parent UI to update...
    [self.delegate needToUpdateLoginButton : FALSE];
    [self dismissViewControllerAnimated : YES completion:nil];
    
} //end didFBTLogOut

//==========<<<FBLogin>>>=================================================================
// DHS 7/6: This gets called when logged-in user portrait comes back...
- (void)didFBTFetchPortrait
{
    NSLog(@" FBLoginVC didFBTFetchPortrait");
    //Update our "notification" count
    //let other VC's know...
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fbLoginChangedState" object:nil userInfo:nil];
    //Tell Parent UI to update...
    [self.delegate needToUpdateLoginButton : TRUE];
    [self.delegate didFBVCFetchPortrait];
    loggingIn = FALSE;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated : NO completion:nil];
    });
    
    

} //end didFBTFetchPortrait

//==========<<<FBLogin>>>=================================================================
// FBTools fetch return: take incoming FB info and use it as needed
- (void)didFBTFetchUserInfo
{
    //    _loggedIntoFB = _fbt.loggedIn;

} //end didFBTFetchUserInfo

//==========<<<FBLogin>>>=================================================================
- (void)didFBTFailToGetToken
{
    fbc.loggedIn     = FALSE;
    fbc.loggedInFBAK = FALSE;
    //Tell Parent UI to update...
    [self.delegate needToUpdateLoginButton : FALSE];
    
} //end didFBTFailToGetToken

//==========<<<FBLogin>>>=================================================================
- (void)didFBTCancelLogIn
{
    loggingIn = FALSE;

} //end didFBTCancelLogIn

//==========<<<FBLogin>>>=================================================================
- (void)didFBTHitLoginError
{
    loggingIn = FALSE;

    //NSLog(@" mainVC didFBTHitLoginError");
} //end didFBTCancelLogIn



//==========<<<FBLogin>>>=================================================================
-(void) manageFBAK
{
    //OK, time to manage the account. see if it already exists...
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSLog(@" manage FBAK... %@",FBAKaccountID);
    if (FBAKaccountID != nil && [appDelegate.uu isFBIDNew:FBAKaccountID])
    {
        NSLog(@" new acct, saving to parse...%@ : %@",fbc.fbName,FBAKaccountID);
        [appDelegate.uu saveToParse : @"emptyAmplID"  : @"emptyUserID"
                                    : fbc.fbName : FBAKaccountID
                                    : fbc.fullnamesky : FBAKaccountEmailAddress : fbc.fbProfileImage];
    }
    else //FBAK acct already exists, should we fetch from uniqueUsers?...
    {
        //NSLog(@" acct exists...");
    }
    
} //end manageFBAK


@end
