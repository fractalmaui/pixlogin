//
//  AppDelegate.h
//  PixLogin
//
//  Created by Dave Scruton on 5/21/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HDKGenerate.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSMutableArray *uids;
    HDKGenerate *hdkgen;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *latestPuzzleImages;


@end

