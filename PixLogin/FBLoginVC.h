//
//  FBLoginVC.h
//  pix
//
//  Created by Dave Scruton on 8/6/17.
//  Copyright © 2017 Huedoku Labs. All rights reserved.
//

#import "FBTools.h"
#import "PIXFBCache.h"
#import <AccountKit/AccountKit.h>
#import "AppDelegate.h"
#import "FBAKInfoVC.h"
#import "soundFX.h"


@protocol FBLoginVCDelegate;

@interface FBLoginVC : UIViewController <FBToolsDelegate , FBAKInfoVCDelegate , AKFViewControllerDelegate>
{
    AKFAccountKit *_accountKit;
    UIViewController<AKFViewController> *_pendingLoginViewController;
    NSString *preFillEmailAddress;
    BOOL _showAccountOnAppear;

    NSString *FBAKaccountID;
    NSString *FBAKaccountName;
    NSString *FBAKaccountPhoneNumber;
    NSString *FBAKaccountEmailAddress;
    BOOL accountCreated;
    NSString *whichLogin;
    BOOL fbakJustCancelled;
    
    PIXFBCache *fbc;
    FBTools *fbt;
    
    BOOL loggingIn;
    BOOL gotAKLogin;

}

@property (nonatomic, unsafe_unretained) id <FBLoginVCDelegate> delegate; // receiver of completion messages

@property (nonatomic, strong) soundFX *sfx;
@property (weak, nonatomic) IBOutlet UIView *fbLoginView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)FBLoginSelect:(id)sender;
- (IBAction)mobileSelect:(id)sender;
- (IBAction)emailSelect:(id)sender;

- (IBAction)backSelect:(id)sender;


@end

@protocol FBLoginVCDelegate <NSObject>
@required
- (void)needToUpdateLoginButton : (BOOL) loggedIn;
- (void) didFBVCFetchPortrait;
@optional
@end

