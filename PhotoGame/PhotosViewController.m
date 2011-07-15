//
//  PhotosViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotosViewController.h"


@implementation PhotosViewController

@synthesize imgBtn0, imgBtn1, imgBtn2, imgBtn3, imgBtn4, imgBtn5, imgBtn6, imgBtn7, imgBtn8;
@synthesize imgBtn9, imgBtn10, imgBtn11, imgBtn12, imgBtn13, imgBtn14, imgBtn15;
@synthesize theParent, loadingBtn;

-(IBAction)playBtnClicked:(id)sender {
    //PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];    
    //[delegate switchView:self.view to:theParent.view];
    [theParent showPlayView:self];
}

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


- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {       
        [self recreateRandomPhotos];     
    }    
    if ([super respondsToSelector:@selector(motionEnded:withEvent:)]) {
        [super motionEnded:motion withEvent:event];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self becomeFirstResponder];
    [self setupGrid];
    [self populatePlayPhotoGrid];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self viewDidAppear:animated];
    [self resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)buttonPushed:(id)sender {
    
}


- (void)populatePlayPhotoGrid {
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            
            UIImage *img = [UIImage imageWithCGImage:iref];
            [self addImageToGrid:img];                    
            
        }
    };    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
    };        
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    
    for (int i=0; i<[theParent.playImages count]; i++) {
        [assetslibrary assetForURL:[theParent.playImages objectAtIndex:i] resultBlock:resultblock failureBlock:failureblock];
    }
    
}

- (BOOL)addImageToGrid:(UIImage *)img {
    
    BOOL added = NO;
    
    if(img == nil) {
        return added;
    }
    img = [theParent scaleImage:img toSize:CGSizeMake(150.0f,150.0f)];
    if ([imgBtn0 currentImage] == nil) {
        [imgBtn0 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn1 currentImage] == nil) {
        [imgBtn1 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn2 currentImage] == nil) {
        [imgBtn2 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn3 currentImage] == nil) {
        [imgBtn3 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn4 currentImage] == nil) {
        [imgBtn4 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn5 currentImage] == nil) {
        [imgBtn5 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn6 currentImage] == nil) {
        [imgBtn6 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn7 currentImage] == nil) {
        [imgBtn7 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn8 currentImage] == nil) {
        [imgBtn8 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn9 currentImage] == nil) {
        [imgBtn9 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn10 currentImage] == nil) {
        [imgBtn10 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn11 currentImage] == nil) {
        [imgBtn11 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn12 currentImage] == nil) {
        [imgBtn12 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn13 currentImage] == nil) {
        [imgBtn13 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn14 currentImage] == nil) {
        [imgBtn14 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else if ([imgBtn15 currentImage] == nil) {
        [imgBtn15 setImage:img forState:UIControlStateNormal];
        added = YES;
    }
    else {
        NSLog(@"Max number of image allowed = 16");
    }    
    
    return added;
}

- (void)recreateRandomPhotos {
    
    
    if ([theParent.playImages count] > 0) {
        [loadingBtn setHidden:NO];
        
        GameData *_gameData = [[GameData alloc] init];
        [_gameData.images removeAllObjects];
        [theParent.playImages removeAllObjects];
        
        [imgBtn0 setImage:nil forState:UIControlStateNormal];
        [imgBtn1 setImage:nil forState:UIControlStateNormal];
        [imgBtn2 setImage:nil forState:UIControlStateNormal];
        [imgBtn3 setImage:nil forState:UIControlStateNormal];
        [imgBtn4 setImage:nil forState:UIControlStateNormal];
        [imgBtn5 setImage:nil forState:UIControlStateNormal];
        [imgBtn6 setImage:nil forState:UIControlStateNormal];
        [imgBtn7 setImage:nil forState:UIControlStateNormal];
        [imgBtn8 setImage:nil forState:UIControlStateNormal];
        [imgBtn9 setImage:nil forState:UIControlStateNormal];
        [imgBtn10 setImage:nil forState:UIControlStateNormal];
        [imgBtn11 setImage:nil forState:UIControlStateNormal];
        [imgBtn12 setImage:nil forState:UIControlStateNormal];
        [imgBtn13 setImage:nil forState:UIControlStateNormal];
        [imgBtn14 setImage:nil forState:UIControlStateNormal];
        [imgBtn15 setImage:nil forState:UIControlStateNormal]; 
        
        [imgBtn0 setHidden:YES];
        [imgBtn1 setHidden:YES];
        [imgBtn2 setHidden:YES];
        [imgBtn3 setHidden:YES];
        [imgBtn4 setHidden:YES];
        [imgBtn5 setHidden:YES];
        [imgBtn6 setHidden:YES];
        [imgBtn7 setHidden:YES];
        [imgBtn8 setHidden:YES];
        [imgBtn9 setHidden:YES];
        [imgBtn10 setHidden:YES];
        [imgBtn11 setHidden:YES];
        [imgBtn12 setHidden:YES];
        [imgBtn13 setHidden:YES];
        [imgBtn14 setHidden:YES];
        [imgBtn15 setHidden:YES];
                
        NSURL *url;
        int max = 17;
        
        for (int i=0; i<100; i++) {
            url = [theParent getDeviceRandomPhoto];
            if (url && [theParent.playImages indexOfObject:url] == NSNotFound) {
                [theParent.playImages addObject:url];
                if ([theParent.playImages count] >= max) {
                    break;
                }
            }
        }
        
        [self populatePlayPhotoGrid];   

        for (int i=0; i<[theParent.playImages count]; i++) {
            [_gameData.images addObject:[theParent.playImages objectAtIndex:i]];
        }        
        [_gameData saveToFile];     
        [_gameData release];    
        
        [loadingBtn setHidden:YES];
        
        [imgBtn0 setHidden:NO];
        [imgBtn1 setHidden:NO];
        [imgBtn2 setHidden:NO];
        [imgBtn3 setHidden:NO];
        [imgBtn4 setHidden:NO];
        [imgBtn5 setHidden:NO];
        [imgBtn6 setHidden:NO];
        [imgBtn7 setHidden:NO];
        [imgBtn8 setHidden:NO];
        [imgBtn9 setHidden:NO];
        [imgBtn10 setHidden:NO];
        [imgBtn11 setHidden:NO];
        [imgBtn12 setHidden:NO];
        [imgBtn13 setHidden:NO];
        [imgBtn14 setHidden:NO];
        [imgBtn15 setHidden:NO];        
    }
    
}

- (void)setupGrid {    
    
    imgBtn0 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn0.frame = CGRectMake(4.0, 73.0, 75.0, 75.0);    
    [self.view addSubview:imgBtn0];
    [imgBtn0 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn1.frame = CGRectMake(83.0, 73.0, 75.0, 75.0);
    [self.view addSubview:imgBtn1];
    [imgBtn1 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn2.frame = CGRectMake(162.0, 73.0, 75.0, 75.0);
    [self.view addSubview:imgBtn2];
    [imgBtn2 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn3.frame = CGRectMake(241.0, 73.0, 75.0, 75.0);
    [self.view addSubview:imgBtn3];
    [imgBtn3 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn4.frame = CGRectMake(4.0, 152.0, 75.0, 75.0);
    [self.view addSubview:imgBtn4];
    [imgBtn4 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn5.frame = CGRectMake(83.0, 152.0, 75.0, 75.0);
    [self.view addSubview:imgBtn5];
    [imgBtn5 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn6 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn6.frame = CGRectMake(162.0, 152.0, 75.0, 75.0);
    [self.view addSubview:imgBtn6];
    [imgBtn6 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn7 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn7.frame = CGRectMake(241.0, 152.0, 75.0, 75.0);
    [self.view addSubview:imgBtn7];
    [imgBtn7 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn8 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn8.frame = CGRectMake(4.0, 231.0, 75.0, 75.0);
    [self.view addSubview:imgBtn8];
    [imgBtn8 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn9 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn9.frame = CGRectMake(83.0, 231.0, 75.0, 75.0);
    [self.view addSubview:imgBtn9];
    [imgBtn9 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn10 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn10.frame = CGRectMake(162.0, 231.0, 75.0, 75.0);
    [self.view addSubview:imgBtn10];
    [imgBtn10 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn11 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn11.frame = CGRectMake(241.0, 231.0, 75.0, 75.0);
    [self.view addSubview:imgBtn11];
    [imgBtn11 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn12 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn12.frame = CGRectMake(4.0, 310.0, 75.0, 75.0);
    [self.view addSubview:imgBtn12];
    [imgBtn12 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn13 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn13.frame = CGRectMake(83.0, 310.0, 75.0, 75.0);
    [self.view addSubview:imgBtn13];
    [imgBtn13 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn14 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn14.frame = CGRectMake(162.0, 310.0, 75.0, 75.0);
    [self.view addSubview:imgBtn14];
    [imgBtn14 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn15 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    imgBtn15.frame = CGRectMake(241.0, 310.0, 75.0, 75.0);
    [self.view addSubview:imgBtn15];
    [imgBtn15 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];     
}



@end
