//
//  HowToPlay.m
//  PhotoGame
//
//  Created by Steve Ho on 7/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HowToPlay.h"


@implementation HowToPlay

@synthesize theParent, dontShowCBBtn, showRules;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];


    GameData *_gameData = [[GameData alloc] init];
    UIImage *img;
    NSMutableString *temp = [_gameData getShowRules];
    if (temp == nil || [temp compare:@"y"] == NSOrderedSame) {
        showRules = YES;  
        img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cb_off" ofType:@"png"]];
    }
    else {
        showRules = NO;
        img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cb_on" ofType:@"png"]];
    }
    [dontShowCBBtn setImage:img forState:UIControlStateNormal];
    [_gameData release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)letsGoBtn {
    [theParent showEditPhotoView:self];
}

- (IBAction)dontShowRuleAgainClicked {
    UIImage *img;
    if (showRules) {
        showRules = NO;
    }
    else {
        showRules = YES;        
    }   
    if (!showRules) {
        img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cb_on" ofType:@"png"]];
    }
    else {
        img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cb_off" ofType:@"png"]];                
    }
    
    [dontShowCBBtn setImage:img forState:UIControlStateNormal];
    [self updateShowRules];
}

- (void)updateShowRules {
        
    GameData *_gameData = [[GameData alloc] init];
    if (showRules) {
        [_gameData setShowRules:[NSMutableString stringWithString:@"y"]];
        NSLog(@"yes");
    }
    else {
        [_gameData setShowRules:[NSMutableString stringWithString:@"n"]];
        NSLog(@"no");

    }
    [_gameData saveToFile];     
    [_gameData release];    
}

@end
