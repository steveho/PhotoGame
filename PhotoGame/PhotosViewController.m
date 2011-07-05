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
@synthesize theParent;

-(IBAction)showHomeView:(id)sender {
    PhotoGameAppDelegate *delegate = (PhotoGameAppDelegate*)[[UIApplication sharedApplication] delegate];
    PhotoGameViewController *pvc = [[PhotoGameViewController alloc] initWithNibName:@"PhotoGameViewController" bundle:nil];
    [delegate switchView:self.view to:pvc.view];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    imgBtn0 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn0.frame = CGRectMake(4.0, 53.0, 75.0, 75.0);
    [self.view addSubview:imgBtn0];
    [imgBtn0 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn1.frame = CGRectMake(83.0, 53.0, 75.0, 75.0);
    [self.view addSubview:imgBtn1];
    [imgBtn1 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn2.frame = CGRectMake(162.0, 53.0, 75.0, 75.0);
    [self.view addSubview:imgBtn2];
    [imgBtn2 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn3.frame = CGRectMake(241.0, 53.0, 75.0, 75.0);
    [self.view addSubview:imgBtn3];
    [imgBtn3 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn4.frame = CGRectMake(4.0, 132.0, 75.0, 75.0);
    [self.view addSubview:imgBtn4];
    [imgBtn4 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn5.frame = CGRectMake(83.0, 132.0, 75.0, 75.0);
    [self.view addSubview:imgBtn5];
    [imgBtn5 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn6 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn6.frame = CGRectMake(162.0, 132.0, 75.0, 75.0);
    [self.view addSubview:imgBtn6];
    [imgBtn6 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn7 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn7.frame = CGRectMake(241.0, 132.0, 75.0, 75.0);
    [self.view addSubview:imgBtn7];
    [imgBtn7 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn8 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn8.frame = CGRectMake(4.0, 211.0, 75.0, 75.0);
    [self.view addSubview:imgBtn8];
    [imgBtn8 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn9 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn9.frame = CGRectMake(83.0, 211.0, 75.0, 75.0);
    [self.view addSubview:imgBtn9];
    [imgBtn9 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn10 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn10.frame = CGRectMake(162.0, 211.0, 75.0, 75.0);
    [self.view addSubview:imgBtn10];
    [imgBtn10 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn11 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn11.frame = CGRectMake(241.0, 211.0, 75.0, 75.0);
    [self.view addSubview:imgBtn11];
    [imgBtn11 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn12 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn12.frame = CGRectMake(4.0, 290.0, 75.0, 75.0);
    [self.view addSubview:imgBtn12];
    [imgBtn12 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn13 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn13.frame = CGRectMake(83.0, 290.0, 75.0, 75.0);
    [self.view addSubview:imgBtn13];
    [imgBtn13 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn14 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn14.frame = CGRectMake(162.0, 290.0, 75.0, 75.0);
    [self.view addSubview:imgBtn14];
    [imgBtn14 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    imgBtn15 = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBtn15.frame = CGRectMake(241.0, 290.0, 75.0, 75.0);
    [self.view addSubview:imgBtn15];
    [imgBtn15 addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];    
    
    [self populatePlayPhotoGrid];
    
    /*
    if ([theParent.playImages count] > 0) {
        theParent.gameData = [[GameData alloc] init];
        theParent.gameData.images = [[NSMutableArray alloc] init];
        for (int i=0; i<[theParent.playImages count]; i++) {
            [theParent.gameData.images addObject:[theParent.playImages objectAtIndex:i]];
        }
        NSLog(@"count: %d", [theParent.gameData.images count]);
        [theParent.gameData saveToFile];
        [theParent.gameData release];
    }    
    */
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
    img = [self scaleImage:img toSize:CGSizeMake(150.0f,150.0f)];
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
