//
//  NewEntryViewController.m
//  iDreamwidth
//
//  Copyright (c) 2010, Xerxes Botkin
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
//  DISCLAIMED. IN NO EVENT SHALL XERXES BOTKIN BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NewEntryViewController.h"

#import "iDreamwidthAppDelegate.h"
#import "DWAccount.h"

// Taken from Cocoa With Love 
// (http://cocoawithlove.com/2010/07/tips-tricks-for-conditional-ios3-ios32.html)
#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0 478.23
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_1
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_3_2
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#endif

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
#define IF_IOS4_OR_GREATER(...) \
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) \
    { \
        __VA_ARGS__ \
    }
#else
#define IF_IOS4_OR_GREATER(...)
#endif

@implementation NewEntryViewController

@synthesize postAsText;
@synthesize postToText;
@synthesize subjectText;
@synthesize entryView;
@synthesize tagsText;
@synthesize moodSelText;
@synthesize moodText;
@synthesize locationText;
@synthesize musicText;
@synthesize commentsText;
@synthesize screenText;
@synthesize ageRestrictText;
@synthesize accessText;

@synthesize postAsPick;
@synthesize postToPick;
@synthesize moodPick;
@synthesize commentsPick;
@synthesize screenPick;
@synthesize ageRestrictPick;
@synthesize accessPick;
@synthesize actionSheet;

@synthesize scrollView;
@synthesize kbShown;

@synthesize post;

@synthesize submitButton;

/*
 // The designated initializer.  Override if you create the controller programmatically 
 // and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
 */

- (IBAction)submit {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWAccount *account = (DWAccount *)[appDelegate.accountsArray objectAtIndex:accountNum];
    
    [self save:self];
    [appDelegate.dwProtocol postEvent:account withPost:self.post];
}

- (void)clear {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWAccount *account = (DWAccount *)[appDelegate.accountsArray objectAtIndex:0];
    
    accountNum = 0;
    postToNum = 0;
    self.postAsText.text = account.username;
    self.postToText.text = [account.postToArray objectAtIndex:0];
    self.subjectText.text = @"";
    self.entryView.text = @"";
    self.tagsText.text = @"";
    self.moodSelText.text = [appDelegate.moodArray objectAtIndex:0];
    self.moodText.text = @"";
    self.locationText.text = @"";
    self.musicText.text = @"";
    self.commentsText.text = [commentsArray objectAtIndex:0];
    self.screenText.text = [screenArray objectAtIndex:0];
    self.ageRestrictText.text = [ageRestrictArray objectAtIndex:0];
    
    DWPost *newPost = [[DWPost alloc] init];
    self.post = newPost;
    [newPost release];
}

- (void)finalizeChanges {
    self.post.subject = self.subjectText.text;
    self.post.body = self.entryView.text;
    self.post.location = self.locationText.text;
    self.post.mood = self.moodText.text;
    self.post.music = self.musicText.text;
    self.post.tags = self.tagsText.text;
    self.post.community = self.postToText.text;
    
    self.post.comments = commentsNum;
    self.post.screen = screenNum;
    self.post.adultContent = adultContentNum;
    self.post.moodNum = moodNum;
    self.post.privatePost = accessSel;
    
    self.post.accountNum = accountNum;
    self.post.communityNum = postToNum;
}

- (void)save:(id)sender {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Edit this
    if (self.post.draftNum == -1) {
        // New save
        [self finalizeChanges];
        self.post.draftNum = [appDelegate.draftsArray count];
        [appDelegate.draftsArray addObject:self.post];
    } else {
        // Old save, draft should already be edited - just need to update
        [self finalizeChanges];
    }
    
    [appDelegate updateDrafts:self];
    
    if (currTextField != nil) {
        [currTextField resignFirstResponder];
        currTextField = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadPost:(DWPost *)newPost {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.post = newPost;
    
    accountNum = self.post.accountNum;
    postToNum = self.post.communityNum;
    accessSel = self.post.privatePost;
    
    self.subjectText.text = self.post.subject;
    self.entryView.text = self.post.body;
    self.locationText.text = self.post.location;
    self.moodText.text = self.post.mood;
    self.musicText.text = self.post.music;
    self.tagsText.text = self.post.tags;
    self.postToText.text = self.post.community;
    NSString *moodNString = [[NSString alloc] initWithFormat:@"%i", self.post.moodNum];
    int moodN = [[appDelegate.moodDict objectForKey:moodNString] intValue];
    [moodNString release];
    self.moodSelText.text = [appDelegate.moodArray objectAtIndex:moodN];
    self.commentsText.text = [commentsArray objectAtIndex:self.post.comments];
    self.screenText.text = [screenArray objectAtIndex:self.post.screen];
    self.ageRestrictText.text = [ageRestrictArray objectAtIndex:self.post.adultContent];
    if (accessSel == NO) {
        self.accessText.text = [accessArray objectAtIndex:0];
    } else if (accessSel == YES) {
        self.accessText.text = [accessArray objectAtIndex:1];
    }
}

- (void)cancel:(id)sender {
    if (currTextField != nil) {
        [currTextField resignFirstResponder];
        currTextField = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currTextField = textField;
    
    if (textField == commentsText) {
        [self showCommentsPicker];
    } else if (textField == screenText) {
        [self showScreenPicker];
    } else if (textField == ageRestrictText) {
        [self showAgeRestrictPicker];
    } else if (textField == moodSelText) {
        [self showMoodPicker];
    } else if (textField == postAsText) {
        [self showPostAsPicker];
    } else if (textField == postToText) {
        [self showPostToPicker];
    } else if (textField == accessText) {
        [self showAccessPicker];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {    
    currTextField = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
                                               initWithTitle:@"Done" 
                                               style:UIBarButtonItemStyleDone 
                                               target:self 
                                               action:@selector(textViewDoneEditing:)] 
                                              autorelease];
    self.navigationItem.leftBarButtonItem = nil;
    currTextField = (UITextField *)textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    currTextField = nil;
}

- (void) textViewDoneEditing:(id)sender {
    [self.entryView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                           target:self 
                                                                                           action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(cancel:)];    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(320,880);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                           target:self 
                                                                                           action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                          target:self 
                                                                                          action:@selector(cancel:)];
    self.navigationItem.title = @"New Entry";
    
    DWPost *dwPost = [[DWPost alloc] init];
    self.post = dwPost;
    [dwPost release];
    commentsArray = [[NSArray alloc] initWithObjects:@"Journal Default", @"Disabled", 
                        @"Don't Email", nil];
    screenArray = [[NSArray alloc] initWithObjects:@"Journal Default", @"Disabled",
                   @"Anonymous Only", @"Non-access List", @"All Comments", nil];
    ageRestrictArray = [[NSArray alloc] initWithObjects:@"Journal Default", @"No Age Restriction", 
                        @"Viewer Discretion", @"Age 18+", nil];
    accessArray = [[NSArray alloc] initWithObjects:@"Public", @"Private", nil];
    accountNum = 0;
    postToNum = 0;
    accessSel = NO;
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    DWAccount *account = (DWAccount *)[appDelegate.accountsArray objectAtIndex:accountNum];
    
    self.postAsText.text = account.username;
    self.postToText.text = [account.postToArray objectAtIndex:0];
    self.subjectText.text = @"";
    self.entryView.text = @"";
    self.tagsText.text = @"";
    self.moodSelText.text = [appDelegate.moodArray objectAtIndex:0];
    self.moodText.text = @"";
    self.locationText.text = @"";
    self.musicText.text = @"";
    self.commentsText.text = [commentsArray objectAtIndex:0];
    self.screenText.text = [screenArray objectAtIndex:0];
    self.ageRestrictText.text = [ageRestrictArray objectAtIndex:0];
    self.accessText.text = [accessArray objectAtIndex:0];
    
    postAsPick = [[UIPickerView alloc] init];
    postToPick = [[UIPickerView alloc] init];
    moodPick = [[UIPickerView alloc] init];
    commentsPick = [[UIPickerView alloc] init];
    ageRestrictPick = [[UIPickerView alloc] init];
    screenPick = [[UIPickerView alloc] init];
    accessPick = [[UIPickerView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(kbShown:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:self.view.window]; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kbHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}


- (void) kbShown:(NSNotification *) notification {
    if (kbShown) return;
    
    // iOS 3 Code
    NSDictionary* info = [notification userInfo];
    
    NSValue *kb = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize kbSize = [kb CGRectValue].size;
    CGFloat kbHeight = kbSize.height;

    IF_IOS4_OR_GREATER
    (
        CGRect kbEndFrame;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbEndFrame];
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || 
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
            kbHeight = kbEndFrame.size.height;
        } else {
            kbHeight = kbEndFrame.size.width;
        }
     );
    
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height -= kbHeight;
    scrollView.frame = viewFrame;
    
    CGRect textFieldRect = [currTextField frame];
    [scrollView scrollRectToVisible:textFieldRect animated:YES];
    
    kbShown = YES;
}

- (void) kbHidden:(NSNotification *) notification {
    if (!kbShown) return;
    
    // iOS 3 Code
    NSDictionary* info = [notification userInfo];
    
    NSValue* kb = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize kbSize = [kb CGRectValue].size;
    CGFloat kbHeight = kbSize.height;
    
    IF_IOS4_OR_GREATER
    (
        CGRect kbEndFrame;
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&kbEndFrame];
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ||
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
            kbHeight = kbEndFrame.size.height;
        } else {
            kbHeight = kbEndFrame.size.width;
        }
     );

    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += kbHeight;
    scrollView.frame = viewFrame;
    
    kbShown = NO;
}

- (void) showPostAsPicker {
    postAsShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Post As"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:accountNum inComponent:0 animated:NO];
    
    self.postAsPick = pickerView;
    self.actionSheet = aSheet;
}

- (void)showPostToPicker {
    postToShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Post To"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:postToNum inComponent:0 animated:NO];
    
    self.postToPick = pickerView;
    self.actionSheet = aSheet;
}

- (void) showMoodPicker {
    moodShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Mood"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    // [pickerView selectRow:self.post.mood inComponent:0 animated:NO];
    
    self.moodPick = pickerView;
    self.actionSheet = aSheet;
}

- (void) showCommentsPicker {
    commentsShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Comments"
                                                             delegate:nil 
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:self.post.comments inComponent:0 animated:NO];
    
    self.commentsPick = pickerView;
    self.actionSheet = aSheet;
}

- (void) showScreenPicker {
    screenShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Comment Screening"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:self.post.screen inComponent:0 animated:NO];
    
    self.screenPick = pickerView;
    self.actionSheet = aSheet;
}

- (void) showAgeRestrictPicker {
    ageRestrictShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Age Restriction"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:self.post.adultContent inComponent:0 animated:NO];
    
    self.ageRestrictPick = pickerView;
    self.actionSheet = aSheet;
}

- (void)showAccessPicker {
    accessShown = YES;
    
    UIActionSheet *aSheet = [[UIActionSheet alloc] initWithTitle:@"Access"
                                                        delegate:nil 
                                               cancelButtonTitle:nil
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    [aSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [aSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventValueChanged];
    [aSheet addSubview:closeButton];
    [closeButton release];
    
    [aSheet showInView:self.view];
    
    [aSheet setBounds:CGRectMake(0, 0, 320, 485)];
    
    [pickerView selectRow:self.post.privatePost inComponent:0 animated:NO];
    
    self.accessPick = pickerView;
    self.actionSheet = aSheet;
}

- (void) dismissPicker:(id)sender {
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (commentsShown) {
        // [commentsText resignFirstResponder];
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [commentsPick selectedRowInComponent:0];
        self.commentsText.text = [commentsArray objectAtIndex:n];
        [commentsText resignFirstResponder];
        commentsNum = n;
        commentsShown = NO;
    } else if (screenShown) {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [screenPick selectedRowInComponent:0];
        self.screenText.text = [screenArray objectAtIndex:n];
        [screenText resignFirstResponder];
        screenNum = n;
        screenShown = NO;
    } else if (ageRestrictShown) {
        // [ageRestrictText resignFirstResponder];
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [ageRestrictPick selectedRowInComponent:0];
        self.ageRestrictText.text = [ageRestrictArray objectAtIndex:n];
        [ageRestrictText resignFirstResponder];
        adultContentNum = n;
        ageRestrictShown = NO;
    } else if (moodShown) {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [moodPick selectedRowInComponent:0];
        self.moodSelText.text = [appDelegate.moodArray objectAtIndex:n];
        [moodSelText resignFirstResponder];
        moodNum = [[appDelegate.moodNumArray objectAtIndex:n] intValue];
        moodShown = NO;
    } else if (postAsShown) {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [postAsPick selectedRowInComponent:0];
        DWAccount *account = (DWAccount *)[appDelegate.accountsArray objectAtIndex:n];
        self.postAsText.text = account.username;
        [postAsText resignFirstResponder];
        accountNum = n;
        postAsShown = NO;
    } else if (postToShown) {
        appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [postToPick selectedRowInComponent:0];
        DWAccount *account = (DWAccount *)[appDelegate.accountsArray objectAtIndex:accountNum];
        self.postToText.text = [account.postToArray objectAtIndex:n];
        [postToText resignFirstResponder];
        postToNum = n;
        postToShown = NO;
    } else if (accessShown) {
        [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        NSInteger n = [accessPick selectedRowInComponent:0];
        
        if (n == 0) {
            accessSel = NO;
        } else if (n == 1) {
            accessSel = YES;
        }
        self.accessText.text = [accessArray objectAtIndex:n];
        [accessText resignFirstResponder];
        accessShown = NO;
    }
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (commentsShown) {
        return (NSString *)[commentsArray objectAtIndex:row];
    } else if (ageRestrictShown) {
        return (NSString *)[ageRestrictArray objectAtIndex:row];
    } else if (screenShown) {
        return (NSString *)[screenArray objectAtIndex:row];
    } else if (moodShown) {
        return (NSString *)[appDelegate.moodArray objectAtIndex:row];
    } else if (postToShown) {
        appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        DWAccount *account = [appDelegate.accountsArray objectAtIndex:accountNum];
        return (NSString *)[account.postToArray objectAtIndex:row];
    } else if (postAsShown) {
        appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        return (NSString *)((DWAccount *)[appDelegate.accountsArray objectAtIndex:row]).username;
    } else if (accessShown) {
        return (NSString *)[accessArray objectAtIndex:row];
    } else {
        return @"";
    }
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    iDreamwidthAppDelegate *appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (commentsShown) {
        return [commentsArray count];
    } else if (screenShown) {
        return [screenArray count];
    } else if (ageRestrictShown) {
        return [ageRestrictArray count];
    } else if (moodShown) {
        return [appDelegate.moodArray count];
    } else if (postAsShown) {
        appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        return [appDelegate.accountsArray count];
    } else if (postToShown) {
        appDelegate = (iDreamwidthAppDelegate *)[[UIApplication sharedApplication] delegate];
        DWAccount *account = [appDelegate.accountsArray objectAtIndex:accountNum];
        return [account.postToArray count];
    } else if (accessShown) {
        return [accessArray count];
    } else {
        return 0;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [postAsText release];
    [postToText release];
    [subjectText release];
    [entryView release];
    [tagsText release];
    [moodSelText release];
    [moodText release];
    [locationText release];
    [musicText release];
    [commentsText release];
    [screenText release];
    [ageRestrictText release];
    [accessText release];
    
    [postAsPick release];
    [postToPick release];
    [moodPick release];
    [commentsPick release];
    [screenPick release];
    [ageRestrictPick release];
    [accessPick release];
    
    [commentsArray release];
    [screenArray release];
    [ageRestrictArray release];
    [accessArray release];
    
    [actionSheet release];
    [scrollView release];
    [submitButton release];
    
    [post release];
    
    [self.navigationItem.rightBarButtonItem release];
    [self.navigationItem.leftBarButtonItem release];
    
    [super dealloc];
}


@end
