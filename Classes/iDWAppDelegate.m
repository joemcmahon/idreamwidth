//
//  iDreamwidthAppDelegate.m
//  iDreamwidth
//
//  Copyright (c) 2010, Xerxes Botkin
//  Copyright (c) 2012, Dreamwidth Studios, LLC.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//  * Neither the name of iDreamwidth nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "iDWAppDelegate.h"
#import "DWClient.h"
#import "Configuration.h"

#import "DWORequest.h"
//#import "DWPendingAuthorization.h"

@class DWPendingAuthorization;

@implementation iDWAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize createEntryController;
@synthesize draftsController;
@synthesize journalController;
@synthesize accountsController;
@synthesize readingController;
@synthesize settingsController;

//@synthesize dwProtocol;

@synthesize createEntry;
@synthesize drafts;
@synthesize journal;
@synthesize accounts;
@synthesize reading;
@synthesize settings;

@synthesize accountsType;
@synthesize accountsArray;
@synthesize draftsArray;
@synthesize journalArray;
@synthesize readingArray;
@synthesize readingLoadArray;

@synthesize readingCount;

@synthesize dwClient;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    NSArray *acctType = [[NSArray alloc] initWithObjects:@"Dreamwidth", nil];
    self.accountsType = acctType;
    [acctType release];

    dwClient = [[DWClient alloc] initWithEndpoint:DW_ENDPOINT ssl:DW_SSL tokenPair:
                [newConsumerTokenPair() autorelease]];

    [self loadData:self];

    for (NSUInteger i = 0; i < [accountsArray count]; ++i) {
        //DWAccount *currAccount = [accountsArray objectAtIndex:i];
        //[dwProtocol login:currAccount];
        //[dwProtocol getEvents:currAccount];
    }
}

- (void)accountAlert:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                    message:@"You need to add an account first!"
                                                   delegate:nil 
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"Add Account",nil];
    [alert setDelegate:self];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1) {
        [self openAccounts:self];
    }
}

- (IBAction)openNewEntry:(id)sender {
    if ([accountsArray count] > 0) {
        if (self.createEntryController == nil) {
            
            NewEntryViewController *newEntryVC = [[NewEntryViewController alloc] 
                                                  initWithNibName:@"NewEntryViewController"
                                                  bundle:[NSBundle mainBundle]];
            self.createEntryController = newEntryVC;
            [newEntryVC release];
        } else {
            [self.createEntryController clear];
        }
        [self.navigationController pushViewController:self.createEntryController animated:YES];
    } else {
        [self accountAlert:self];
    }
}

- (IBAction)openDrafts:(id)sender {
    if ([accountsArray count] > 0) {
        if (self.draftsController == nil) {
            DraftsViewController *draftsVC = [[DraftsViewController alloc] 
                                              initWithNibName:@"DraftsViewController"
                                              bundle:[NSBundle mainBundle]];
            self.draftsController = draftsVC;
            [draftsVC release];
        }
        
        [self.navigationController pushViewController:self.draftsController animated:YES];
    } else {
        [self accountAlert:self];
    }
}

- (IBAction)openJournal:(id)sender {
    if ([accountsArray count] > 0) {
        if (self.journalController == nil) {
            JournalViewController *journalVC = [[JournalViewController alloc] 
                                                initWithNibName:@"JournalViewController"
                                                bundle:[NSBundle mainBundle]];
            self.journalController = journalVC;
            [journalVC release];
        }
        
        [self.navigationController pushViewController:self.journalController animated:YES];    
    } else {
        [self accountAlert:self];
    }
}

- (IBAction)openAccounts:(id)sender {
    if (self.accountsController == nil) {
        AccountsViewController *accountsVC = [[AccountsViewController alloc] 
                                            initWithNibName:@"AccountsViewController"
                                            bundle:[NSBundle mainBundle]];
        self.accountsController = accountsVC;
        [accountsVC release];
    }
    
    [self.navigationController pushViewController:self.accountsController animated:YES];
}

- (IBAction)openReading:(id)sender {
    if ([accountsArray count] > 0) {
        if (self.readingController == nil) {
            ReadingViewController *readingVC = [[ReadingViewController alloc] 
                                                initWithNibName:@"ReadingViewController"
                                                bundle:[NSBundle mainBundle]];
            self.readingController = readingVC;
            [readingVC release];
        }
        
        [self.navigationController pushViewController:self.readingController animated:YES];    
    } else {
        [self accountAlert:self];
    }
}

- (IBAction)openSettings:(id)sender {
    if (self.settingsController == nil) {
        SettingsViewController *settingsVC = [[SettingsViewController alloc] 
                                            initWithNibName:@"SettingsViewController"
                                            bundle:[NSBundle mainBundle]];
        self.settingsController = settingsVC;
        [settingsVC release];
    }
    
    [self.navigationController pushViewController:self.settingsController animated:YES];
}

- (void)updateAccounts:(id)sender {
    if (accountsController != nil) {
        [accountsController.tblView reloadData];
    }
    
    for (NSUInteger i = 0; i < [accountsArray count]; ++i) {
        //DWAccount *acct = [accountsArray objectAtIndex:i];
        //acct.accountNum = i;
    }
}

- (void)updateDrafts:(id)sender {
    if (draftsController != nil) {
        [draftsController.tblView reloadData];
    }
    
    for (NSUInteger i = 0; i < [draftsArray count]; ++i) {
        //DWPost *post = [draftsArray objectAtIndex:i];
        //post.draftNum = i;
    }
}

- (void)updateJournal:(id)sender {
    if (journalController != nil) {
        [journalController.tblView reloadData];
    }
    
    for (NSUInteger i = 0; i < [journalArray count]; ++i) {
        //DWPost *post = [journalArray objectAtIndex:i];
        //post.journalNum = i;
    }
}

- (void)updateReading:(id)sender {
    if (readingController != nil) {
        [readingController.tblView reloadData];
    }
    
    for (NSUInteger i = 0; i < [readingArray count]; ++i) {
        //DWPost *post = [readingArray objectAtIndex:i];
        //post.readNum = i;
    }
}


- (void)sortReading:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    /*
    NSArray *sorted = [readingLoadArray sortedArrayUsingComparator: ^(id post1, id post2) {
        return (NSComparisonResult)[(NSString *)[post2 date] localizedCaseInsensitiveCompare:(NSString *)[post1 date]];
    }];
     */
    [readingLoadArray sortUsingSelector:@selector(comparePost:)];
    
    NSMutableArray *replacement = [[NSMutableArray alloc] initWithCapacity:50];
    NSUInteger limit = 25;
    if (limit > [readingLoadArray count]) {
        limit = [readingLoadArray count];
    }
    for (NSUInteger i = 0; i < limit; ++i) {
        [replacement addObject:[readingLoadArray objectAtIndex:i]];
    }
    [pool release];
    
    self.readingLoadArray = replacement;
    [replacement release];
}

- (void)reloadReading:(id)sender {
    if (readingCount <= 0) {
        [self sortReading:self];
        self.readingArray = readingLoadArray;
        self.readingLoadArray = nil;
        if (readingController != nil) {
            [readingController.tblView reloadData];
        }
        
        for (NSUInteger i = 0; i < [readingArray count]; ++i) {
            //DWPost *newPost = [readingArray objectAtIndex:i];
            //[newPost fetchLightPost:self];
        }
    }
}

- (void)saveData:(id)sender {
    // Store accounts, drafts, & cached entries
    if ([accountsArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver 
                                                          archivedDataWithRootObject:self.accountsArray] 
                                                  forKey:@"accountsArray"];    
    }
    if ([draftsArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver 
                                                          archivedDataWithRootObject:self.draftsArray] 
                                                  forKey:@"draftsArray"];
    }
    if ([journalArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver 
                                                          archivedDataWithRootObject:self.journalArray] 
                                                  forKey:@"journalArray"];
    }
    if ([readingArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver 
                                                          archivedDataWithRootObject:self.readingArray] 
                                                  forKey:@"readingArray"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadData:(id)sender {
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];

    NSData *savedAccounts = [data objectForKey:@"accountsArray"];
    if (savedAccounts != nil) {
        NSArray *oldAccounts = [NSKeyedUnarchiver unarchiveObjectWithData:savedAccounts];
        if (oldAccounts != nil) {
            NSMutableArray *reloaded = [[NSMutableArray alloc] initWithArray:oldAccounts];
            self.accountsArray = reloaded;
            [reloaded release];
        } else {
            NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
            self.accountsArray = newArray;
            [newArray release];
        }
    } else {
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.accountsArray = newArray;
        [newArray release];
    }
    
    NSData *savedDrafts = [data objectForKey:@"draftsArray"];
    if (savedDrafts != nil) {
        NSArray *oldDrafts = [NSKeyedUnarchiver unarchiveObjectWithData:savedDrafts];
        if (oldDrafts != nil) {
            NSMutableArray *reloaded = [[NSMutableArray alloc] initWithArray:oldDrafts];
            self.draftsArray = reloaded;
            [reloaded release];
        } else {
            NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
            self.draftsArray = newArray;
            [newArray release];
        }
    } else {
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.draftsArray = newArray;
        [newArray release];
    }
    
    NSData *savedJournal = [data objectForKey:@"journalArray"];
    if (savedJournal != nil) {
        NSArray *oldJournal = [NSKeyedUnarchiver unarchiveObjectWithData:savedJournal];
        if (oldJournal != nil) {
            NSMutableArray *reloaded = [[NSMutableArray alloc] initWithArray:oldJournal];
            self.journalArray = reloaded;
            [reloaded release];
        } else {
            NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
            self.journalArray = newArray;
            [newArray release];
        }
    } else {
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.journalArray = newArray;
        [newArray release];
    }
    
    NSData *savedReading = [data objectForKey:@"readingArray"];
    if (savedReading != nil) {
        NSArray *oldReading = [NSKeyedUnarchiver unarchiveObjectWithData:savedReading];
        if (oldReading != nil) {
            NSMutableArray *reloaded = [[NSMutableArray alloc] initWithArray:oldReading];
            self.readingArray = reloaded;
            [reloaded release];
        } else {
            NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
            self.readingArray = newArray;
            [newArray release];
        }
    } else {
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.readingArray = newArray;
        [newArray release];
    }
    
    /*DWProtocol *dw = [[DWProtocol alloc] init];
    self.dwProtocol = dw;
    [dw release];
    
    for (int i = 0; i < [accountsArray count]; i++) {
        DWAccount *acct = [accountsArray objectAtIndex:i];
        [acct update:self];
        [dwProtocol downloadUserPic:[acct.username lowercaseString]];
    }*/
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. 
     This can occur for certain types of temporary interruptions (such as 
     an incoming phone call or SMS message) or when the user quits the 
     application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle 
     down OpenGL ES frame rates. Games should use this method to pause the game.
     */

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate 
     timers, and store enough application state information to restore your 
     application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of 
     applicationWillTerminate: when the user quits.
     */
    
    [self saveData:self];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: 
     here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the 
     application was inactive. If the application was previously in the background, 
     optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    [self saveData:self];
}

- (void)dealloc {
    [navigationController release];
    [createEntryController release];
    [draftsController release];
    [journalController release];
    [accountsController release];
    [readingController release];
    [settingsController release];
    
    [createEntry release];
    [drafts release];
    [journal release];
    [accounts release];
    [reading release];
    [settings release];
    
    [accountsArray release];
    [draftsArray release];
    [journalArray release];
    [readingArray release];

    [dwClient release];

    [window release];
    [mainButtonGrid release];
    [super dealloc];
}


@end
