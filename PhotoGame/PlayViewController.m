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
@synthesize gamePlayLabel, seedPhotoLoading;
@synthesize players, gameHostID;

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
    
    
    [self setupGame];    
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

#pragma mark - Game methods

- (void)setupGame {
    players = [[NSMutableDictionary alloc] init];
    
    sessionManager = [[SessionManager alloc] init];
    sessionManager.delegate = self;
    [sessionManager setupSession];
    
    // set up me player    
    Player *me = [[Player alloc] init];
    me.name = [theParent myUserName];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmss"];
    me.started = [dateFormatter stringFromDate:[NSDate date]];    
    [players setValue:me forKey:[sessionManager.mySession peerID]];    

    
    NSLog(@"me [%@]: name=%@, started=%@", [sessionManager.mySession peerID], me.name, me.started);
    
    [self setupPlayPhotosView];
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
}

- (void)playPhotoClicked:(id)sender {
    [previewPhoto setImage:[sender currentImage]];
}

- (void)submittedPhotoClicked:(id)sender {

}

- (void)setupPlayPhotosView {
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
            [btn addTarget:self action:@selector(playPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
            
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

- (void)setupSubmittedPhotosView {
    //clear all photos in scroll view
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }    
        
    [gamePlayLabel setText:@"Players submitting their photos..."];

    int submittedPhotoCount = 0;
    UIButton *btn;
    
    // me first
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(((75.0+2.0) * submittedPhotoCount), 0.0, 75.0, 75.0);  
    [btn setImage:[[players objectForKey:[sessionManager.mySession peerID]] currentPlayPhoto] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(submittedPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];    
    [scrollView addSubview:btn];    
    submittedPhotoCount++;
    
    // other players
    for (id key in players) {
        if (key == [sessionManager.mySession peerID]) {
            continue;
        }
        id player = [players objectForKey:key];
    
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(((75.0+2.0) * submittedPhotoCount), 0.0, 75.0, 75.0);  
        [btn setImage:[player currentPlayPhoto] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(submittedPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [scrollView addSubview:btn];                        
        submittedPhotoCount++;
    
    }
    
}

- (IBAction)playPhotoBtnClicked {
    [self updatePlayerInfo:[sessionManager.mySession peerID] currentPlayPhoto:[previewPhoto image]];
    
    [self setupSubmittedPhotosView];
    [self sendPlayPhotoToPeer:nil image:[previewPhoto image]];
}

- (void)sendPlayPhotoToPeer:(NSString*)peerID image:(UIImage*)img {    
    if (img) {
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(img)];
        
        if (peerID) { // a specific peerID
            [sessionManager sendData:imageData ofType:PacketTypeDataPlayPhoto to:[NSArray arrayWithObject:peerID]];
        }
        else { // broadcast to all connected peers        
            NSArray *connectedPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected]; 
            if ([connectedPeers count]) {
                [sessionManager sendData:imageData ofType:PacketTypeDataPlayPhoto to:connectedPeers];                
            }    
        }
    }
}








#pragma mark - GamePlayDelegate methods

-(void)peerListDidChange:(SessionManager*)session peer:(NSString*)peerID {
    NSMutableString *btnTitle = [NSMutableString stringWithString:@"Peers: "];
    
    NSArray *connectedPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    [btnTitle appendString:[NSString stringWithFormat:@"%i", [connectedPeers count]]];
    [peerLabel setText:btnTitle];
}

- (void)sendSeedPhotoToPeer:(NSString*)peerID {    
    if (peerID && [self getLocalSeedPhoto]) {
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([seedPhoto image])];        
        [self sendDataToPeer:peerID type:PacketTypeDataSeedPhoto data:imageData];        
    }
}

- (void)sendBasicInfoToPeer:(NSString*)peerID {
    Player *me = [players objectForKey:[sessionManager.mySession peerID]];
    
    NSData *nameData = [me.name dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self sendDataToPeer:peerID type:PacketTypeDataPlayerName data:nameData];

    NSData *dateData = [me.started dataUsingEncoding:[NSString defaultCStringEncoding]];
    [self sendDataToPeer:peerID type:PacketTypeDataPlayerStarted data:dateData];

    NSLog(@"me [%@] sent to %@, %@, %@", [sessionManager.mySession peerID], peerID, me.name, me.started);
    
}

- (void)sendDataToPeer:(NSString*)peerID type:(PacketType)type data:(NSData*)data {
    NSArray *toPeers;
    if (peerID) {
        toPeers = [NSArray arrayWithObject:peerID];
    }
    else {//broadcast to all
        toPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    }
    [sessionManager sendData:data ofType:type to:toPeers];    
}

- (void)setLocalSeedPhoto:(UIImage*)img {
    [seedPhotoLoading setHidden:YES];
    [seedPhoto setImage:img];
}

- (UIImage*)getLocalSeedPhoto {
    return [seedPhoto image];
}

- (void)updatePlayerInfo:(NSString*)peerID name:(NSString*)value {
    if (!peerID) { return; }

    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.name = value;
    [players setObject:p forKey:peerID];
}

- (void)updatePlayerInfo:(NSString*)peerID currentPlayPhoto:(UIImage*)value {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.currentPlayPhoto = value;
    [players setObject:p forKey:peerID];
    
    // if i've selected my play photo
    if ([previewPhoto image]) {
        [self setupSubmittedPhotosView];
    }
}

- (void)updatePlayerInfo:(NSString*)peerID currentPlayVotes:(int)value {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.currentPlayVotes = value;
    [players setObject:p forKey:peerID];
    
}

- (void)updatePlayerInfo:(NSString*)peerID started:(NSString*)date {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.started = date;
    [players setObject:p forKey:peerID];  
    
    [self startNewGameRound];
}

- (void)startNewGameRound {
    // only host (the first player) can start new game round by sending a random Seed Photo
    // min # of players is 2
    
    [self updateGameHost];

    if ([players count] < 2) {
        return;
    }

    Player *pl = [players objectForKey:gameHostID];
    NSLog(@"game host %@", [pl name]);
    
    // i'm the host - start game
    if ([sessionManager.mySession peerID] == gameHostID) {
        
        NSLog(@"i'm the host %@", gameHostID);
        
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

                        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([seedPhoto image])];        
                        [self sendDataToPeer:nil type:PacketTypeDataSeedPhoto data:imageData];
                        
                    }
                };    
                ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror) {
                    NSLog(@"Can't get image - %@",[myerror localizedDescription]);
                };        
                ALAssetsLibrary* assetslibrary = [[[ALAssetsLibrary alloc] init] autorelease];
                [assetslibrary assetForURL:seedPhotoURL resultBlock:resultblock failureBlock:failureblock];
            }        
        }        
    }
}

- (void)updateGameHost {
    //game host is the very fist player
    
    NSString *smallestDate = nil;
    gameHostID = nil;
    for (id key in players) {
        id p = [players objectForKey:key];
        if (!p || ![p started]) {
            continue;
        }
        
        if (smallestDate == nil) {
            smallestDate = [p started];
            gameHostID = key;
        }
        else {
            NSComparisonResult res = [smallestDate compare:[p started]];
            if (res == NSOrderedDescending) {
                smallestDate = [p started];
                gameHostID = key;
            }
        } 
    }
    
    [smallestDate release];    
}

@end
