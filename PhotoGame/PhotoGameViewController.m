//
//  PhotoGameViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoGameViewController.h"


@implementation PhotoGameViewController

@synthesize allImages, myUserName;

-(IBAction)showEditPhotoView:(id)sender {    
    PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];
    PhotosViewController *pvc = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil];
    [delegate switchView:self.view to:pvc.view];
    pvc.theParent = self;
}

-(IBAction)showPlayView:(id)sender {    
    PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];
    PlayViewController *pvc = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    [delegate switchView:self.view to:pvc.view];
    pvc.theParent = self;


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
    
    [self findAllImages];
    [self loadData];
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
        
        [alert show];
        [alert release];
        alert = nil;
    }    
 
    if (self.myUserName != nil) { 
        [self showPlayView:self];
    }
}

#pragma mark - UIAlertViewDelegate methods

// User has reacted to the dialog box and chosen accept or reject.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1 && [nameField text]) {
        gameData = [[GameData alloc] init];        
        [gameData setUserName:[NSMutableString stringWithString:[nameField text]]];
        self.myUserName = [NSMutableString stringWithString:[nameField text]];
        [gameData saveToFile];
        [gameData release];
        gameData = nil;
	}
}

#pragma mark - data methods

- (void)loadData {

    gameData = [[GameData alloc] init];        
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            //UIImage *i = [UIImage imageWithCGImage:iref];
            //[self addImageToGrid:i];
        }
    };    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
    };
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    
    for(NSURL *url in gameData.images) {
        [assetslibrary assetForURL:url resultBlock:resultblock failureBlock:failureblock];    
    }
    self.myUserName = [gameData getUserName];
    
    NSLog(@"App started: name=%@, images=%d", [gameData getUserName], [gameData.images count]);
    
    [gameData release];
    gameData = nil;
    
}

- (void)findAllImages {
    
    void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop)
    {
        if(result != nil)
        {            
            [allImages addObject:[[result defaultRepresentation] url]];
        }
    };    
    
    void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        if(group != nil)
        {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            
        }  
    };
    
    allImages = [[NSMutableArray alloc] init];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetGroupEnumerator failureBlock: ^(NSError *error) { NSLog(@"Failure");}];
        
}

- (NSURL*)getDeviceRandomPhoto {
    if ([allImages count]) {
        int rand = random() % [allImages count];
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


@end
