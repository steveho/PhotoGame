//
//  PlayViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"


@implementation PlayViewController

@synthesize theParent, sessionManager, peerLabel, seedPhoto, scrollView, previewPhoto, newRoundBtn, playPhotoBtn;
@synthesize gamePlayLabel, seedPhotoLoading;
@synthesize players, gameStep, gameRound, mySeedPhotoURL;

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
    gameStep = 0;
    mySeedPhotoURL = nil;
    
    sessionManager = [[SessionManager alloc] init];
    sessionManager.delegate = self;
    [sessionManager setupSession];
    
    // set up me player    
    Player *me = [[Player alloc] init];
    me.name = [theParent myUserName];
    [players setValue:me forKey:[sessionManager.mySession peerID]];    

    [self gameFlowNext];
}

-(IBAction)newRoundBtnClicked {
    if ([self getLocalSeedPhoto] == nil) {
        [self pickLocalSeedPhoto];
        
        //send seed photo to peers
        if ([self getLocalSeedPhoto]) {            
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([self getLocalSeedPhoto])];                    
            [self sendDataToPeer:nil type:PacketTypeDataSeedPhoto data:imageData];
            [self setCurrentSeeder:[sessionManager.mySession peerID]];
        }
        
        [newRoundBtn setHidden:YES];
    }
}

- (void)pickLocalSeedPhoto {            
    mySeedPhotoURL = [theParent getDeviceRandomPhoto];
    if (mySeedPhotoURL) {              
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
        [assetslibrary assetForURL:mySeedPhotoURL resultBlock:resultblock failureBlock:failureblock];
    }        
}

- (void)playPhotoClicked:(id)sender {
    [previewPhoto setImage:[sender currentImage]];
    [playPhotoBtn setHidden:NO];
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
        if (mySeedPhotoURL == [urls objectAtIndex:i]) {
            continue;
        }
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
        if ([player currentPlayPhoto]) {
        
            UIImage *hidImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pwp_hidden_image" ofType:@"png"]];        
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(((75.0+2.0) * submittedPhotoCount), 0.0, 75.0, 75.0);  
            [btn setImage:hidImg forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submittedPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [scrollView addSubview:btn];                        
            submittedPhotoCount++;

        }
    }
    [scrollView setContentSize:CGSizeMake(((75.0+2.0) * submittedPhotoCount), 80)];
}

- (IBAction)playPhotoBtnClicked {
    if (gameStep == 1 && [previewPhoto image]) {
        [self updatePlayerInfoPlayPhoto:[sessionManager.mySession peerID] value:[previewPhoto image]];
    
        [self setupSubmittedPhotosView];
        [self sendPlayPhotoToPeer:nil image:[previewPhoto image]];
        
        gameStep = 2;
        [self gameFlowNext];
    }
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

-(void)playerListDidChange:(SessionManager*)session peer:(NSString*)peerID {
    NSArray *connectedPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    int numPlayers = [connectedPeers count] + 1;
    NSMutableString *btnTitle = [NSMutableString stringWithFormat:@"%d", numPlayers];
    [btnTitle appendString:@" players"];
    [peerLabel setText:btnTitle];
    
    [self gameFlowNext];
}

- (void)sendSeedPhotoToPeer:(NSString*)peerID {    
    if (peerID && [self getLocalSeedPhoto]) {
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([seedPhoto image])];        
        [self sendDataToPeer:peerID type:PacketTypeDataSeedPhoto data:imageData];        
    }
}

- (void)sendBasicInfoToPeer:(NSString*)peerID {
    if (!peerID) {
        return;
    }
    Player *me = [players objectForKey:[sessionManager.mySession peerID]];
    if (!me || me == nil) {
        return;
    }
    if (me.name) {
        NSData *nameData = [me.name dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self sendDataToPeer:peerID type:PacketTypeDataPlayerName data:nameData];
    }
}

- (void)sendDataToPeer:(NSString*)peerID type:(PacketType)type data:(NSData*)data {
    NSArray *toPeers;
    if (peerID) {
        toPeers = [NSArray arrayWithObject:peerID];
    }
    else {//broadcast to all
        toPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    }
    if ([toPeers count] > 0) {
        [sessionManager sendData:data ofType:type to:toPeers];    
    }
}

- (void)setLocalSeedPhoto:(UIImage*)img {
    [seedPhotoLoading setHidden:YES];
    [seedPhoto setImage:img];

    gameStep = 1;
    [self gameFlowNext];
}

- (UIImage*)getLocalSeedPhoto {
    return [seedPhoto image];
}

- (void)updatePlayerInfoName:(NSString*)peerID value:(NSString*)value {
    if (!peerID) { return; }

    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.name = value;
    [players setObject:p forKey:peerID];
}

- (void)updatePlayerInfoPlayPhoto:(NSString*)peerID value:(UIImage*)currentPlayPhoto {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.currentPlayPhoto = currentPlayPhoto;
    [players setObject:p forKey:peerID];
    
    //setup submitted photo view (scrollable)
    if ([previewPhoto image] && gameStep == 2) {
        [self setupSubmittedPhotosView];
    }
    
    //am i the current seeder? and if all have submitted, then on the "viewing" step
    BOOL allHaveSubmitted = YES;
    if ([sessionManager.mySession peerID] == currentSeeder) {
        for (id key in players) {
            id player = [players objectForKey:key];
            if (![player currentPlayPhoto]) {
                allHaveSubmitted = NO;
                break;
            }
        }
    }
    if (allHaveSubmitted) {
        
        NSLog(@"READY FOR VIEWING?");
        
    }
}

- (void)updatePlayerInfoPlayVotes:(NSString*)peerID value:(int)currentPlayVotes {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.currentPlayVotes = currentPlayVotes;
    [players setObject:p forKey:peerID];
    
}


- (void)removePlayer:(NSString*)peerID {
    if ([players objectForKey:peerID]) {
        [players removeObjectForKey:peerID];
    }
}

- (void)gameFlowNext {
    if (gameStep == 0) {//new round - need a seed photo
        currentSeeder = nil;
        [playPhotoBtn setHidden:YES];        
        [gamePlayLabel setHidden:YES];
        
        NSArray *connPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
        int numPlayers = [connPeers count] + 1;      
        if (numPlayers >= 2) {
            [newRoundBtn setHidden:NO];
        } else {
            [gamePlayLabel setHidden:NO];
            [gamePlayLabel setText:@"Waiting For Players..."];
            [newRoundBtn setHidden:YES];
        }
    }
    else if (gameStep == 1) {//got seed photo - select a match
        [gamePlayLabel setHidden:NO];
        [newRoundBtn setHidden:YES];
        [gamePlayLabel setText:@"Match This Image"];
        [self setupPlayPhotosView];            
    }
    else if (gameStep == 2) {//clicked "Play Photo"
        [playPhotoBtn setHidden:YES];
        [gamePlayLabel setText:@"Waiting For Peeps"];
    }    
    else {}
}

- (void)setCurrentSeeder:(NSString*)peerID {
    if (peerID) {
        currentSeeder = peerID;
        
        Player *p = [players objectForKey:currentSeeder];
        NSLog(@"Current seeder: %@ (%@)", [p name], currentSeeder);
    }
}

@end
