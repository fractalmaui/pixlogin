//
//  AppDelegate.m
//  PixLogin
//
//  Created by Dave Scruton on 5/21/18.
//  Copyright © 2018 huedoku. All rights reserved.
//
// MailGun adapter (for password reset)
//   https://stackoverflow.com/questions/43342962/
//     what-is-the-best-way-to-setup-mailgun-to-work-on-parse-server-heroku
//  https://github.com/parse-community/parse-server/issues/4360
// AWS adapter??
//  https://www.npmjs.com/package/parse-server-amazon-ses-email-adapter
//  https://www.npmjs.com/package/parse-server-generic-email-adapter
//
//  Looks like this is where the adapter stuff gets added (on server)
//     /home/bitnami/apps/parse/htdocs
//  npm was used to install mailgun and it works, (I think)
//   here's instructions:=
//  https://www.npmjs.com/package/parse-server-mailgun
//   here's the test file (that DID send an email)
//  ./node_modules/parse-server-mailgun/mailgun.json
//  dave / dave@asdf.com / asdfasdf
//  gabe... / gabe@asdf.com / asdfasdf

#import "AppDelegate.h"


#define SASHIDODB_VERSION

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        //This is the pure AWS configuration...
        //Getting error on save:
        //Error Domain=NSURLErrorDomain Code=-1200
        //  "An SSL error has occurred and a secure connection to the server cannot be made.
#ifdef AWS_EC2_VERSION
        configuration.applicationId = @"af374cf7c9c0ad32af16e6c6ef4e8e0435f36670";
        configuration.clientKey     = @"c0cef5648663d06d6087a4cceeae36d72931b0ca";
        configuration.server        = @"http://ec2-52-42-95-208.us-west-2.compute.amazonaws.com/parse";
#endif
#ifdef SASHIDODB_VERSION
       //This is the AWS -> Mongo configuration...
       configuration.applicationId = @"EoI6eXNoTWhdd6vMM5CD5lfz3RMQ9TimYMHl5OiN";
       configuration.clientKey     = @"qkBxtrB71xtEGy1nM7CljjiNm3iMRzDoM8l4QH39";
       configuration.server        = @"https://pg-app-i7qovaugrx6ezj0t9quh6zeicej4qy.scalabl.cloud/1/";
#endif
    }]];

    
    _latestPuzzleImages = [[NSMutableArray alloc] init];
    uids        = [[NSMutableArray alloc] init];
    hdkgen      = [[HDKGenerate alloc] init];
    [self loadLatest10Games];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//=====(TESTING)======================================================================
-(void) loadLatest10Games //: (NSMutableArray *)uidsToLookFor
{
    PFQuery *query = [PFQuery queryWithClassName:@"currentGames"];
    query.limit = 10; //Get latest 10
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            [self->uids removeAllObjects];
            for (PFObject *localObject in objects)  [self->uids addObject:[localObject objectForKey:@"uniquePuzzleID"]];
            PFQuery *pquery = [PFQuery queryWithClassName:@"plixa"];
            //NSLog(@" ...found %d uids",(int)self->uids.count);
            [pquery whereKey:@"uniquePuzzleID" containedIn:self->uids];
            [pquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if (objects.count > 0)
                    {
                        int i = 0;
                        [self->_latestPuzzleImages removeAllObjects];
                        for (PFObject *localObject in objects)
                        {
                            //NSLog(@" obj[%d] uid %@",i,[localObject objectForKey:@"uniquePuzzleID"]);
                            NSNumber *nn;
                            nn = [localObject objectForKey:@"puzzleSize"];
                            int psize = nn.intValue;
                            NSString *hex1 = [localObject objectForKey:@"color1Hex"];
                            NSString *hex2 = [localObject objectForKey:@"color2Hex"];
                            NSString *hex3 = [localObject objectForKey:@"color3Hex"];
                            NSString *hex4 = [localObject objectForKey:@"color4Hex"];
                            UIColor *color1 = [self->hdkgen colorFromHexString:hex1];
                            UIColor *color2 = [self->hdkgen colorFromHexString:hex2];
                            UIColor *color3 = [self->hdkgen colorFromHexString:hex3];
                            UIColor *color4 = [self->hdkgen colorFromHexString:hex4];
                            UIImage *ii = [self->hdkgen makeBitmapFromPuzzle: 128 : psize : 1 :color1 :color2 :color3 :color4];
                            [self->_latestPuzzleImages addObject:ii];
                            i++;
                        } //end pfobj loop
                        NSLog(@" bing: got latest played puzzle bitmaps");
                    }
                }//end inner !error
            }]; //end inner query
        } //end outer !error
    }]; //end outer query
    
} //end loadLatest10Games



@end
