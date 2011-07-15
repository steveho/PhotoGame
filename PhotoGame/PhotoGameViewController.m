//
//  PhotoGameViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoGameViewController.h"


@implementation PhotoGameViewController

@synthesize allImages, myUserName, playImages, gameData, showRules;
@synthesize views;

-(IBAction)showEditPhotoView:(id)sender {    
    if (self.myUserName == nil) { 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Your Name" message:@"Enter Your Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
        [nameField setBackgroundColor:[UIColor whiteColor]];
        [alert addSubview:nameField];
        [nameField becomeFirstResponder];
        
        [alert show];
        [alert release];
        alert = nil;
        
    }

    if (self.myUserName != nil) {
        
        if (views == nil) {
            views = [[NSMutableDictionary alloc] init];
        }
        
        PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        PhotosViewController *pvc;
        if (!(pvc = [views objectForKey:@"PhotosViewController"])) {
            pvc = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil];
        }    
        pvc.theParent = self;
        if ([sender isKindOfClass:[HowToPlay class]]) {
            [delegate switchView:[sender view] to:pvc.view]; 
        }
        else {
            [delegate switchView:self.view to:pvc.view]; 
        }
        [views setValue:pvc forKey:@"PhotosViewController"];
    }    
}

-(IBAction)showPlayView:(id)sender {  
    if (views == nil) {
        views = [[NSMutableDictionary alloc] init];
    }
    
    PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];

    PlayViewController *pvc;
    if (!(pvc = [views objectForKey:@"PlayViewController"])) {
        pvc = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    }    
    pvc.theParent = self;  

    if ([sender isKindOfClass:[PhotosViewController class]]) {
        [delegate switchView:[sender view] to:pvc.view]; 
    }
    else {
        [delegate switchView:self.view to:pvc.view]; 
    }    
    [views setValue:pvc forKey:@"PlayViewController"];
}


-(IBAction)showHowToPlay:(id)sender {  
    if (views == nil) {
        views = [[NSMutableDictionary alloc] init];
    }
    
    PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    HowToPlay *pvc;
    if (!(pvc = [views objectForKey:@"HowToPlay"])) {
        pvc = [[HowToPlay alloc] initWithNibName:@"HowToPlay" bundle:nil];
    }    
    
    pvc.theParent = self;  
    [delegate switchView:[sender view] to:pvc.view];
    [views setValue:pvc forKey:@"HowToPlay"];
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
    
    /*
    gameData = [[GameData alloc] init];
    [gameData.images removeAllObjects];
    [gameData saveToFile];     
    [gameData release];    
    return;
    */
    
    [self findAllImages];
    
    [self loadData];

    if ([playImages count] == 0) {
        [self getRandomPlayPhotos];
    }
    
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

#pragma mark - init methods

-(void)startGame {    
    if (self.myUserName == nil) { 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Your Name" message:@"Enter Your Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        
        nameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
        [nameField setBackgroundColor:[UIColor whiteColor]];
        [alert addSubview:nameField];
        [nameField becomeFirstResponder];
        
        [alert show];
        [alert release];
        alert = nil;
    }    
 
    if (self.myUserName != nil) { 
        if (showRules != nil && [showRules compare:@"n"] == NSOrderedSame) {
            [self showEditPhotoView:self];
        }
        else {
            [self showHowToPlay:self];
        }
    }
}

#pragma mark - UIAlertViewDelegate methods

// User has reacted to the dialog box and chosen accept or reject.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *enteredName = [[nameField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	if (buttonIndex == 1 && enteredName != nil && [enteredName compare:@""] != NSOrderedSame) {
        gameData = [[GameData alloc] init];        
        [gameData setUserName:[NSMutableString stringWithString:[nameField text]]];
        self.myUserName = [NSMutableString stringWithString:[nameField text]];
        [gameData saveToFile];
        [gameData release];
        gameData = nil;
        
        if ([self.myUserName length] > 0) {
            [self startGame];
        }
	}
}

#pragma mark - data methods

-(void)getRandomPlayPhotos {
    //pick 16 random photos from "allImages"
    NSURL *url;
    int max = 17;
    
    for (int i=0; i<100; i++) {
        url = [self getDeviceRandomPhoto];
        if (url && [playImages indexOfObject:url] == NSNotFound) {
            [playImages addObject:url];
            if ([playImages count] >= max) {
                break;
            }
        }
    }

    if ([playImages count] > 0 && [gameData.images count] == 0) {
        gameData = [[GameData alloc] init];
        for (int i=0; i<[playImages count]; i++) {
            [gameData.images addObject:[playImages objectAtIndex:i]];
        }
        [gameData saveToFile];        
        [gameData release];
    }    
}

- (void)loadData {
    playImages = [[NSMutableArray alloc] init];
    gameData = [[GameData alloc] init];        
        
    for(NSURL *url in gameData.images) {
        [playImages addObject:url];
    }
    self.myUserName = [gameData getUserName];
    self.showRules = [gameData getShowRules];
    [gameData release];
    gameData = nil;
    
}

- (void)findAllImages {
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
    {
        if(result != nil)
        {        
            if ([self.allImages count] < 1000) {
                [self.allImages addObject:[[result defaultRepresentation] url]];
            }
        }
    };    
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if(group != nil)            
        {   
            if ([self.allImages count] < 1000) {
                [group enumerateAssetsUsingBlock:assetEnumerator];    
            }
            if ([self.playImages count] == 0) {
                [self getRandomPlayPhotos];
            }
        }  
    };
    
    self.allImages = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock: ^(NSError *error) { NSLog(@"Failure");}];
            
}

- (NSURL*)getDeviceRandomPhoto {
    if ([allImages count]) {
        int rand = arc4random() % [allImages count];
        return [allImages objectAtIndex:rand];
    } 
    else {
        return nil;
    }
}

- (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(CGSize)getImageDimsProportional:(UIImage*)image max:(CGSize)maxSize {
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxSize.width/maxSize.height;
    
    if(imgRatio != maxRatio) {
        if(imgRatio < maxRatio) {
            imgRatio = maxSize.height / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxSize.height;
        }
        else {
            imgRatio = maxSize.width / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxSize.width;
        }
    }    
    return CGSizeMake(actualWidth, actualHeight);
}


@end
