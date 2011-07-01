//
//  PlayViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"


@implementation PlayViewController

@synthesize theParent, sessionManager, peerLabel, seedPhoto, scrollView, previewPhoto;


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
    
    sessionManager = [[SessionManager alloc] init];
    sessionManager.delegate = self;
    [sessionManager setupSession];
    
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

- (IBAction)newSeedPhoto {
    if ([self getLocalSeedPhoto] == nil) {
        NSURL *seedPhotoURL = [theParent getDeviceRandomPhoto];
        if (seedPhotoURL) {              
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                CGImageRef iref = [rep fullResolutionImage];
                if (iref) {
                    
                    UIImage *img = [UIImage imageWithCGImage:iref];
                    img = [theParent scaleImage:img toSize:CGSizeMake(150.0f,150.0f)];
                    [self setLocalSeedPhoto:img];                    
                    
                }
            };    
            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
                NSLog(@"Can't get image - %@",[myerror localizedDescription]);
            };        
            ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
            [assetslibrary assetForURL:seedPhotoURL resultBlock:resultblock failureBlock:failureblock];
        }
        
    }    
    [self setupPlayPhotos];
}
- (void)playPhotoSelected:(id)sender {
    [previewPhoto setImage:[sender currentImage]];
}
- (void)setupPlayPhotos {
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(300, 80)];
    playPhotoCounter = 0;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *img = [UIImage imageWithCGImage:iref];
            img = [theParent scaleImage:img toSize:CGSizeMake(75.0f,75.0f)];            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(((75.0+2.0) * playPhotoCounter), 0.0, 75.0, 75.0);  
            [btn setImage:img forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(playPhotoSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [scrollView addSubview:btn];            
            playPhotoCounter++;
        }
    };    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
        NSLog(@"Can't get image - %@",[myerror localizedDescription]);
    };        
    
    ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];    
    NSMutableArray *urls = [theParent allImages];
    int max = 16;
    for (int i=[urls count]-1; i>=0; i--) {
        [assetslibrary assetForURL:[urls objectAtIndex:i] resultBlock:resultblock failureBlock:failureblock];
        max--;
        if(max == 0) {
            break;
        }
    }
    [scrollView setContentSize:CGSizeMake(((75.0+2.0) * playPhotoCounter), 80)];
}

#pragma mark - GamePlayDelegate methods

-(void)peerListDidChange:(SessionManager*)session {
    NSMutableString *btnTitle = [NSMutableString stringWithString:@"Peers: "];
    
    NSArray *connectedPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    [btnTitle appendString:[NSString stringWithFormat:@"%i", [connectedPeers count]]];
    [peerLabel setText:btnTitle];
}

- (void)sendSeedPhotoToPeer:(NSString*)peerID {    
    if ([self getLocalSeedPhoto]) {
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([seedPhoto image])];
        
        if (peerID) { // a specific peerID
            //[sessionManager.mySession sendData:imageData toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataReliable error:nil];   
            [sessionManager sendData:imageData ofType:PacketTypeDataSeedPhoto to:[NSArray arrayWithObject:peerID]];
        }
        else { // broadcast to all connected peers        
            NSArray *connectedPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected]; 
            if ([connectedPeers count]) {
                [sessionManager sendData:imageData ofType:PacketTypeDataSeedPhoto to:connectedPeers];
                
                //[sessionManager.mySession sendData:imageData toPeers:connectedPeers withDataMode:GKSendDataReliable error:nil];                                    
                
            }    
        }
    }
}

- (void)setLocalSeedPhoto:(UIImage*)img {
    [seedPhoto setImage:img];
    [self sendSeedPhotoToPeer:nil];
}

- (UIImage*)getLocalSeedPhoto {
    return [seedPhoto image];
}

@end
