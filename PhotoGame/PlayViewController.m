//
//  PlayViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"


@implementation PlayViewController

@synthesize theParent, sessionManager, peerLabel, seedPhoto, scrollView, previewPhoto, newRoundBtn, playPhotoBtn, scrollViewLabel, roundXBtn;
@synthesize gamePlayLabel, unveilPhotoBig, nextPhotoBtn;
@synthesize players, gameStep, gameRound, mySeedPhotoURL, unveiledPhotoCounter;
@synthesize unveilResponseCount, playPhotos, iVoteForPeerID;
@synthesize photoCaptionTextField;

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
    
    gameRound = 0;
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

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1 && [photoCaptionTextField text]) {
        [self updatePlayerInfoPlayPhotoCaption:[sessionManager.mySession peerID] value:[photoCaptionTextField text]];
        
        NSData *data = [[photoCaptionTextField text] dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self sendDataToPeer:nil type:PacketTypeDataPlayPhotoCaption data:data];
	}
    
    [self updatePlayerInfoPlayPhoto:[sessionManager.mySession peerID] value:[previewPhoto image]];    
    [self setupSubmittedPhotosView];
    
    NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([previewPhoto image])];        
    [self sendDataToPeer:nil type:PacketTypeDataPlayPhoto data:imageData];
    
    gameStep = 2;
    [self gameFlowNext];
    
    //am i the current seeder? and if all have submitted, then on the "viewing" step
    if ([sessionManager.mySession peerID] == currentSeeder && [self allHaveSubmittedPhoto]) {
        gameStep = 3;
        [self gameFlowNext];
        [self unveilNextPhoto:currentSeeder];
    }        
    
}

#pragma mark - Game methods

- (void)setupGame {
    players = [[NSMutableDictionary alloc] init];
    mySeedPhotoURL = nil;
    
    sessionManager = [[SessionManager alloc] init];
    sessionManager.delegate = self;
    [sessionManager setupSession];

    // set up me player    
    Player *me = [[Player alloc] init];
    me.name = [theParent myUserName];
    [players setValue:me forKey:[sessionManager.mySession peerID]];       
    
    [self prepareNewRound];
}

-(void)prepareNewRound {    
    playPhotos = nil;
    iVoteForPeerID = nil;
    
    for (id key in players) {
        Player *player = (Player *)[players objectForKey:key];
        player.roundPhoto = nil;
        player.roundVotedFor = nil;
        player.roundVotes = 0;
        player.roundPhotoCaption = nil;
    }
    gameRound++;
    gameStep = 0;
    [self gameFlowNext];
}

- (IBAction)newRoundBtnClicked {
    if (currentSeeder == nil || gameStep == 5) {        
        if (gameStep == 5) {
            [self prepareNewRound];
        }
        
        NSData *data = [@"y" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self sendDataToPeer:nil type:PacketTypeNotifyIAmTheSeeder data:data];

        [self pickLocalSeedPhoto];
        
        //send seed photo to peers
        if ([self getLocalSeedPhoto]) {            
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([self getLocalSeedPhoto])];                    
            [self sendDataToPeer:nil type:PacketTypeDataSeedPhoto data:imageData];
            [self setCurrentSeeder:[sessionManager.mySession peerID]];
        }
        
    }   
}

- (IBAction)nextPhotoBtnClicked {
    [nextPhotoBtn setHidden:YES];
    if ([sessionManager.mySession peerID] != currentSeeder) {
        NSData *data = [@"y" dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self sendDataToPeer:currentSeeder type:PacketTypeDataDoneViewingCurrentPhoto data:data];
    }
    [self readyForNextUnveilPhoto:[sessionManager.mySession peerID]];
}

- (void)pickLocalSeedPhoto {            
    mySeedPhotoURL = [theParent getDeviceRandomPhoto];
    if (mySeedPhotoURL) {              
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                
                UIImage *img = [UIImage imageWithCGImage:iref];
                img = [theParent scaleImage:img toSize:CGSizeMake(160.0f,160.0f)];
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
    [previewPhoto setHidden:NO];
}

- (void)submittedPhotoClicked:(id)sender {

}

- (void)iVoteForPhoto:(id)sender {
    if (gameStep == 4 && iVoteForPeerID == nil) {
        iVoteForPeerID = [(UIButton*)sender titleForState:UIControlStateNormal];
        NSData *data = [iVoteForPeerID dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self sendDataToPeer:nil type:PacketTypeDataIVoteForPeerID data:data];    
        [self whoVotesForWho:[sessionManager.mySession peerID] votee:iVoteForPeerID];
    }
}

- (void)setupPlayPhotosView {
    //clear all photos in scroll view
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }    
    
    [scrollView setScrollEnabled:YES];
    [scrollView setContentSize:CGSizeMake(300, 80)];
    playPhotoCounter = 0;
    
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            UIImage *img = [UIImage imageWithCGImage:iref];
            img = [theParent scaleImage:img toSize:CGSizeMake(160.0f,160.0f)];            
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
    int max = 50;
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

    
    UIImage *hidImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pwp_hidden_image" ofType:@"png"]];
    // other players
    for (id key in players) {
        id player = [players objectForKey:key];
        if ([player roundPhoto]) {
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Photo Caption?" message:@"Add Photo Caption?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];        
        photoCaptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
        [photoCaptionTextField setBackgroundColor:[UIColor whiteColor]];
        [alert addSubview:photoCaptionTextField];     
        [photoCaptionTextField becomeFirstResponder];
        [alert show];
        [alert release];
        alert = nil; 
    }
}







#pragma mark - GamePlayDelegate methods

-(void)playerListDidChange:(SessionManager*)session peer:(NSString*)peerID {
    NSArray *connectedPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    int numPlayers = [connectedPeers count] + 1;
    NSMutableString *btnTitle = [NSMutableString stringWithFormat:@"(%d", numPlayers];
    [btnTitle appendString:@" players)"];
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
    NSLog(@"data length: %d", [data length]);
    
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
    [seedPhoto setImage:img];

    gameStep = 1;
    [self gameFlowNext];
}

- (UIImage*)getLocalSeedPhoto {
    return [seedPhoto image];
}

- (void)updatePlayerInfoName:(NSString*)peerID value:(NSString*)name {
    if (!peerID) { return; }

    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.name = name;
    [players setObject:p forKey:peerID];
}

- (void)updatePlayerInfoPlayPhoto:(NSString*)peerID value:(UIImage*)roundPhoto {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.roundPhoto = roundPhoto;
    [players setObject:p forKey:peerID];
    
    //setup submitted photo view (scrollable)
    if ([previewPhoto image] && gameStep == 2) {
        [self setupSubmittedPhotosView];
    }
    
    //am i the current seeder? and if all have submitted, then on the "viewing" step
    if ([sessionManager.mySession peerID] != peerID && [sessionManager.mySession peerID] == currentSeeder && [self allHaveSubmittedPhoto]) {
        gameStep = 3;
        [self gameFlowNext];
        [self unveilNextPhoto:currentSeeder]; //unveil first photo, my own photo
    }
}

- (void)updatePlayerInfoPlayPhotoCaption:(NSString*)peerID value:(NSString*)caption {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.roundPhotoCaption = caption;
    [players setObject:p forKey:peerID];    
}

- (BOOL)allHaveSubmittedPhoto {
    for (id key in players) {
        id player = [players objectForKey:key];
        if (![player roundPhoto]) {
            return NO;
        }
    }
    return YES;
}

- (void)updatePlayerInfoPlayVotes:(NSString*)peerID value:(int)roundVotes {
    if (!peerID) { return; }
    
    Player *p;
    if (!(p = [players objectForKey:peerID])) {
        p = [[Player alloc] init]; 
    }
    p.roundVotes = roundVotes;
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
        [gamePlayLabel setHidden:NO];
        [unveilPhotoBig setHidden:YES];
        unveiledPhotoCounter = 0;
        [nextPhotoBtn setHidden:YES];
        [roundXBtn setHidden:YES];
        [scrollViewLabel setHidden:YES];
        [newRoundBtn setHidden:YES];        
        
        NSArray *connPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
        int numPlayers = [connPeers count] + 1;      
        if (numPlayers >= 2) {
            //[[newRoundBtn layer] ];
            [[newRoundBtn layer] setCornerRadius:8.0f];
            [[newRoundBtn layer] setBorderWidth:0.0f]; 
            [newRoundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [newRoundBtn setBackgroundColor:[UIColor greenColor]];
            [newRoundBtn setHidden:NO];
        } else {
            [gamePlayLabel setText:@"Waiting For Players..."];
            [newRoundBtn setHidden:YES];
        }
    }
    else if (gameStep == 1) {//got seed photo - select a match
        [gamePlayLabel setHidden:NO];
        [newRoundBtn setHidden:YES];
        [gamePlayLabel setText:@"Match This Image"];
        [self setupPlayPhotosView];            
        [peerLabel setHidden:YES];
    }
    else if (gameStep == 2) {//clicked "Play Photo"
        [playPhotoBtn setHidden:YES];
        [gamePlayLabel setText:@"Waiting For Peeps"];
    }    
    else if (gameStep == 3) {//all have submitted - start viewing one by one (initiated by the seeder)

    }    
    else if (gameStep == 4) {//vote for a match
        [nextPhotoBtn setHidden:YES];
        [gamePlayLabel setText:@"Vote For A Match"];
        [seedPhoto setHidden:NO];
        [unveilPhotoBig setHidden:YES];
        [scrollViewLabel setHidden:YES];
    }
    else if (gameStep == 5) {//we have a winner
        [scrollViewLabel setHidden:NO];
        [gamePlayLabel setHidden:YES];
        
        NSMutableString *roundXTitle = [NSMutableString stringWithString:@"Round "];
        [roundXTitle appendFormat:@"%d", (gameRound+1)];
        [roundXBtn setTitle:roundXTitle forState:UIControlStateNormal];
        [roundXBtn setHidden:NO];
    }    
    else {}
}

- (void)setCurrentSeeder:(NSString*)peerID {
    if (peerID) {
        
        if (gameStep == 5) {
            [self prepareNewRound];
        }
        currentSeeder = peerID;
                
        Player *p = [players objectForKey:currentSeeder];
        NSLog(@"Current seeder: %@ (%@)", [p name], currentSeeder);
    }
}

- (void)unveilNextPhoto:(NSString*)peerID {    
    [nextPhotoBtn setHidden:NO];
    [seedPhoto setHidden:YES];
    [previewPhoto setHidden:YES];
    [unveilPhotoBig setHidden:NO];    
    unveilResponseCount = 0;
    
    if ([sessionManager.mySession peerID] == currentSeeder && playPhotos == nil) {
        playPhotos = [[NSMutableArray alloc] init];
        [playPhotos addObject:currentSeeder];
        for (id key in players) {
            if (key != currentSeeder) {
                [playPhotos addObject:key];
            }
        }  
    }

    
    Player *p = [players objectForKey:peerID];
    UIImage *img = [p roundPhoto];
    [unveilPhotoBig setImage:img];
    
    [scrollViewLabel setText:p.roundPhotoCaption];
    [scrollViewLabel setHidden:NO];
    
    NSMutableString *label = [NSMutableString stringWithString:[p name]];
    [label appendString:@"'s Photo"];
    [gamePlayLabel setText:label];
    
    UIButton *btn;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:peerID forState:UIControlStateNormal];
    btn.frame = CGRectMake(((75.0+2.0) * unveiledPhotoCounter), 0.0, 75.0, 75.0);  
    [btn setImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(iVoteForPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
    [scrollView addSubview:btn];                        
    unveiledPhotoCounter++;    
            
    //notify all peers (ONLY IF I'M THE SEEDER)
    if ([sessionManager.mySession peerID] == currentSeeder) {
        NSData *data = [peerID dataUsingEncoding:[NSString defaultCStringEncoding]];
        [self sendDataToPeer:nil type:PacketTypeDataUnveilPhoto data:data];
    }    
    
    [scrollView setContentSize:CGSizeMake(((75.0+2.0) * unveiledPhotoCounter), 80)];
}

//peerID is done viewing current photo and ready for next
- (void)readyForNextUnveilPhoto:(NSString*)peerID {    
    unveilResponseCount++;
    if ([sessionManager.mySession peerID] == currentSeeder && unveilResponseCount >= [playPhotos count]) {
        if (unveiledPhotoCounter < [playPhotos count]) {
            NSString *nextPeerID = [playPhotos objectAtIndex:unveiledPhotoCounter];
            [self unveilNextPhoto:nextPeerID];            
        }
        else {//last viewing
            NSData *data = [@"y" dataUsingEncoding:[NSString defaultCStringEncoding]];
            [self sendDataToPeer:nil type:PacketTypeNotifyDoneUnveilingPhoto data:data];
            gameStep = 4;
            [self gameFlowNext];
        }
    }
}

- (void)whoVotesForWho:(NSString*)voter votee:(NSString*)votee {
    Player *pVotee = [players objectForKey:votee];
    pVotee.roundVotes++;
    Player *pVoter = [players objectForKey:voter];
    pVoter.roundVotedFor = votee;
    
    if (iVoteForPeerID != nil) {
        int j = 0;
        NSArray *photos = [scrollView subviews];
        UIButton *photo;
        for (int i=0; i<[photos count]; i++) {
            photo = [photos objectAtIndex:i];
            if ([[photo titleForState:UIControlStateNormal] length] > 3) {
                Player *p = [players objectForKey:[photo titleForState:UIControlStateNormal]];
                if (p.roundVotes == 0) {
                    j++;
                    continue;
                }
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];                        
                [btn setTitle:[NSString stringWithFormat:@"%d", p.roundVotes] forState:UIControlStateNormal];
                [[btn layer] setCornerRadius:10.0f];
                [[btn layer] setMasksToBounds:YES];
                [[btn layer] setBorderWidth:0.0f]; 
                [btn setBackgroundColor:[UIColor greenColor]];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];  
                
                btn.frame = CGRectMake((77*j+55), 0.0, 20, 20);
                [scrollView addSubview:btn];
                
                j++;
            }
        }
    }    
    
    //do we have a winner yet?
    BOOL done = YES;
    int highestVotes = 0;
    NSString *winner;
    BOOL isTie = NO;
    for (id key in players) {
        Player *pl = [players objectForKey:key];
        if (pl.roundVotedFor == nil) {
            done = NO;
            break;
        }
        if (highestVotes < pl.roundVotes) {
            highestVotes = pl.roundVotes;
            winner = key;
            isTie = NO;
        }
        else if (highestVotes == pl.roundVotes) {
            highestVotes = pl.roundVotes;
            winner = key;
            isTie = YES;
        } else {}
    }
    
    if (done && winner) {
        if (isTie) {
            [scrollViewLabel setText:@"It's a tie!"];            
        }
        else {
            NSMutableString *tempStr = [NSMutableString stringWithString:@"Congrats, "];
            Player *plWinner = [players objectForKey:winner];
            [tempStr appendFormat:@"%@!", plWinner.name];
            [scrollViewLabel setText:tempStr];
        }
        gameStep = 5;
        [self gameFlowNext];        
    }
    
}

- (void)doneWithUnveilingPhotos:(NSString*)peerID {
    //this is sent from the seeder to the rest
    gameStep = 4;
    [self gameFlowNext];    
}

@end
