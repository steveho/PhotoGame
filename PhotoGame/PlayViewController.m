//
//  PlayViewController.m
//  PhotoGame
//
//  Created by Steve Ho on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayViewController.h"


@implementation PlayViewController

@synthesize theParent, sessionManager, peerLabel, seedPhoto, scrollView, previewPhoto, scrollViewLabel;
@synthesize gamePlayLabel, unveilPhotoBig;
@synthesize players, gameStep, gameRound, mySeedPhotoURL, unveiledPhotoCounter;
@synthesize unveilResponseCount, playPhotos, iVoteForPeerID;
@synthesize photoCaptionTextField, alreadySeededPhotos, startGameBtn, navBar, navBarItem, navBarBtnItem;
@synthesize curSelectedPlayPhoto, customeBtn1, playPhotoCheckMarkBtn, imageContainer;

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

    [imageContainer setBackgroundColor:[UIColor colorWithRed:203.0/255.0 green:210.0/255.0 blue:216.0/255.0 alpha:1.0]];
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 18.0f, 320.0f, 48.0f)];    
    customeBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [customeBtn1 setTitle:PLAY_PIC forState:UIControlStateNormal];
    customeBtn1.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
    [customeBtn1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];    
    customeBtn1.showsTouchWhenHighlighted = YES;
    [customeBtn1.layer setCornerRadius:4.0f];
    [customeBtn1.layer setMasksToBounds:YES];
    [customeBtn1.layer setBorderWidth:1.0f];
    [customeBtn1.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [customeBtn1.layer setBackgroundColor:[[UIColor colorWithRed:31.0/255.0 green:199.0/255.0 blue:48.0/255.0 alpha:1.0] CGColor]];
    customeBtn1.frame=CGRectMake(0.0, 100.0, 65.0, 28.0);    
    [customeBtn1 addTarget:self action:@selector(navBarBtnItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    navBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customeBtn1];    
    
    navBarItem = [[UINavigationItem alloc] initWithTitle:@"Match This Image"];
    [navBarItem setBackBarButtonItem:nil];
    [navBar pushNavigationItem:navBarItem animated:NO];    
    [self.view addSubview: navBar]; 
    [navBar setHidden:YES];
    
    
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
    curSelectedPlayPhoto = nil;
    
    sessionManager = [[SessionManager alloc] init];
    sessionManager.delegate = self;
    [sessionManager setupSession];

    // set up me player    
    Player *me = [[Player alloc] init];
    me.name = [theParent myUserName];
    [players setValue:me forKey:[sessionManager.mySession peerID]];       
    
    [self prepareNewRound];
}


-(void)navBarBtnItemClicked:(id)sender {    
    NSString *btnText = [customeBtn1.titleLabel text];
        
    if ([btnText compare:PLAY_PIC] == NSOrderedSame) {
        if (gameStep == 1 && [previewPhoto image]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Photo Caption?" message:@"Add Photo Caption?" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Add", nil];        
            photoCaptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
            [photoCaptionTextField setBackgroundColor:[UIColor whiteColor]];
            [alert addSubview:photoCaptionTextField];     
            [photoCaptionTextField becomeFirstResponder];
            [alert show];
            [alert release];
            alert = nil; 
        }    
    }
    else if ([btnText compare:NEXT_PIC] == NSOrderedSame || [btnText compare:GO_VOTE] == NSOrderedSame) {
        if ([sessionManager.mySession peerID] != currentSeeder) {
            NSData *data = [@"y" dataUsingEncoding:[NSString defaultCStringEncoding]];
            [self sendDataToPeer:currentSeeder type:PacketTypeDataDoneViewingCurrentPhoto data:data];
        }
        [customeBtn1 setTitle:WAITINGX forState:UIControlStateNormal];
        [self readyForNextUnveilPhoto:[sessionManager.mySession peerID]];
        
    }
    else if ([[btnText substringToIndex:5] compare:@"Round"] == NSOrderedSame) {
        [self newRoundBtnClicked];
    }
    else {}
    
}


-(void)prepareNewRound {    
    playPhotos = nil;
    iVoteForPeerID = nil;
    playPhotoCheckMarkBtn = nil;
    
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

        [self setCurrentSeeder:[sessionManager.mySession peerID]];
        [self pickLocalSeedPhoto];
        
        //send seed photo to peers
        if ([self getLocalSeedPhoto]) {            
            NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation([self getLocalSeedPhoto])];                    
            [self sendDataToPeer:nil type:PacketTypeDataSeedPhoto data:imageData];            
        }
        else {
            currentSeeder = nil;
        }
        
    }   
}

- (void)pickLocalSeedPhoto {    
    //picking a random seed photo and make sure it has not been used in previous rounds
    if (alreadySeededPhotos == nil) {
        alreadySeededPhotos = [[NSMutableArray alloc] init];
    }    
    NSURL *tempUrl;
    for (int i=0; i<50; i++) {
        tempUrl = [theParent getDeviceRandomPhoto];
        if ([alreadySeededPhotos indexOfObject:tempUrl] == NSNotFound) {
            mySeedPhotoURL = tempUrl;
        }
    }
    
    if (mySeedPhotoURL) {              
        [alreadySeededPhotos addObject:mySeedPhotoURL];
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                
                UIImage *img = [UIImage imageWithCGImage:iref];
                CGSize newSize = [theParent getImageDimsProportional:img max:IMAGE_PREVIEW_SIZE];
                img = [theParent scaleImage:img toSize:newSize];
                [self setLocalSeedPhoto:img seeder:[sessionManager.mySession peerID]];                    
                
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
    if (curSelectedPlayPhoto == nil || curSelectedPlayPhoto != sender) {
        curSelectedPlayPhoto = sender;
        [previewPhoto setImage:[sender currentImage]];
        [previewPhoto setHidden:NO];        
        [customeBtn1 setTitle:PLAY_PIC forState:UIControlStateNormal];
        [navBarItem setRightBarButtonItem:navBarBtnItem animated:NO];  

        if (playPhotoCheckMarkBtn == nil) {
            playPhotoCheckMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];                        
            [playPhotoCheckMarkBtn setTitle:[NSString stringWithFormat:@"%@", @"\u2713"] forState:UIControlStateNormal];
            [playPhotoCheckMarkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [playPhotoCheckMarkBtn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [[playPhotoCheckMarkBtn layer] setCornerRadius:8.0f];
            [[playPhotoCheckMarkBtn layer] setMasksToBounds:YES];
            [[playPhotoCheckMarkBtn layer] setBorderWidth:2.0f]; 
            [playPhotoCheckMarkBtn setBackgroundColor:[UIColor colorWithRed:31.0/255.0 green:199.0/255.0 blue:48.0/255.0 alpha:1.0]];
            [playPhotoCheckMarkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [playPhotoCheckMarkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [playPhotoCheckMarkBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
            
        }  

        playPhotoCheckMarkBtn.frame = CGRectMake(59.0, 0.0, 17.0, 17.0);
        [playPhotoCheckMarkBtn setHidden:NO];
        [sender addSubview:playPhotoCheckMarkBtn];
        [seedPhoto setHidden:YES];
    }
    else {
        curSelectedPlayPhoto = nil;
        [previewPhoto setImage:nil];
        [previewPhoto setHidden:YES];
        [navBarItem setRightBarButtonItem:nil animated:NO];
        [playPhotoCheckMarkBtn setHidden:YES];
        [seedPhoto setHidden:NO];
    }
    
    
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
            CGSize newSize = [theParent getImageDimsProportional:img max:IMAGE_PREVIEW_SIZE];
            img = [theParent scaleImage:img toSize:newSize];
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

    int j = 0;
    for (int i=0; i<[theParent.playImages count]; i++) {
        if (mySeedPhotoURL) {
            NSString *str1 = [mySeedPhotoURL absoluteString];
            NSString *str2 = [[theParent.playImages objectAtIndex:i] absoluteString];
            if ([str1 compare:str2] == NSOrderedSame) {
                continue;
            }
        }
        [assetslibrary assetForURL:[theParent.playImages objectAtIndex:i] resultBlock:resultblock failureBlock:failureblock];
        j++;
        if (j >= 16) {
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

    NSArray *toPeers;
    if (peerID) { //single peer
        toPeers = [NSArray arrayWithObject:peerID];
    }
    else {//broadcast to all
        toPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
    }
    if ([toPeers count] > 0) {
        //send in chunks for images
        if (type == PacketTypeDataSeedPhoto || type == PacketTypeDataPlayPhoto) {
            NSUInteger chunkCount = (data.length / 51200) + ((data.length % 51200) == 0 ? 0 : 1);
            NSLog(@"data length: %d => %d chunks", [data length], chunkCount);
            
            //send chunk count
            NSString *chunkCountStr = [NSString stringWithFormat:@"%d",chunkCount];
            NSData *chunkCountData = [chunkCountStr dataUsingEncoding: NSASCIIStringEncoding];
            [sessionManager sendData:chunkCountData ofType:PacketTypeDataChunkCount to:toPeers];
            
            //split data into chunks and send each individually
            NSData *chunkData;
            NSRange range = {0, 0};
            NSUInteger j = 0;
            for(NSUInteger i=0; i<data.length; i+=51200){
                if (i + 51200 < data.length) {
                    j = 51200;
                }
                else {
                    j = data.length - i;
                }
                NSLog(@"range: %d - %d", i, i+j-1);
                range = NSMakeRange(i, j);
                chunkData = [data subdataWithRange:range];
                [sessionManager sendData:chunkData ofType:type to:toPeers];
            }
        }
        else {
            [sessionManager sendData:data ofType:type to:toPeers];    
        }
    }
}

- (void)setLocalSeedPhoto:(UIImage*)img seeder:(NSString*)peerID {
    if (currentSeeder && [currentSeeder compare:peerID] == NSOrderedSame) {
        
        [seedPhoto setImage:img];
        gameStep = 1;
        [self gameFlowNext];        
        
        Player *p = [players objectForKey:currentSeeder];
        NSLog(@"setLocalSeedPhoto(): %@ (%@)", [p name], currentSeeder);        
    }
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
        [gamePlayLabel setHidden:NO];
        [navBar setHidden:YES];
        [unveilPhotoBig setHidden:YES];
        unveiledPhotoCounter = 0;
        [scrollViewLabel setHidden:YES];
        [navBarItem setRightBarButtonItem:nil animated:NO];
        [startGameBtn setHidden:NO];
        [imageContainer setHidden:YES];
        
        NSArray *connPeers = [sessionManager.mySession peersWithConnectionState:GKPeerStateConnected];
        int numPlayers = [connPeers count] + 1;      
        if (numPlayers >= 2) {
            //[[newRoundBtn layer] setCornerRadius:8.0f];
            //[[newRoundBtn layer] setBorderWidth:0.0f]; 
            //[newRoundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //[newRoundBtn setBackgroundColor:[UIColor greenColor]];
            //[newRoundBtn setHidden:NO];
        } else {            
            //[newRoundBtn setHidden:YES];
        }
    }
    else if (gameStep == 1) {//got seed photo - select a match
        [startGameBtn setHidden:YES];
        [gamePlayLabel setHidden:YES];
        [navBar setHidden:NO];
        [navBarItem setTitle:@"Match This Image"];
        [self setupPlayPhotosView];            
        [peerLabel setHidden:YES];
        [imageContainer setHidden:NO];
    }
    else if (gameStep == 2) {//clicked "Play Photo"
        [startGameBtn setHidden:YES];
        [gamePlayLabel setHidden:YES];
        [navBarItem setTitle:@"Waiting For Peeps"];
        [navBarItem setRightBarButtonItem:nil animated:NO];
    }    
    else if (gameStep == 3) {//all have submitted - start viewing one by one (initiated by the seeder)
        [navBarItem setRightBarButtonItem:navBarBtnItem animated:NO];
    }    
    else if (gameStep == 4) {//vote for a match
        [gamePlayLabel setHidden:YES];
        [seedPhoto setHidden:NO];
        [unveilPhotoBig setHidden:YES];
        [scrollViewLabel setHidden:YES];
        [navBarItem setTitle:@"Vote For A Match"];
        [navBarItem setRightBarButtonItem:nil animated:NO];
        
    }
    else if (gameStep == 5) {//we have a winner
        [gamePlayLabel setHidden:YES];
        [scrollViewLabel setHidden:NO];
        [navBarItem setTitle:@""];
        
        NSMutableString *roundXTitle = [NSMutableString stringWithString:@"Round "];
        [roundXTitle appendFormat:@"%d", (gameRound+1)];
        [customeBtn1 setTitle:roundXTitle forState:UIControlStateNormal];
        [navBarItem setRightBarButtonItem:navBarBtnItem animated:NO];
        
    }    
    else {}
}

- (void)setCurrentSeeder:(NSString*)peerID {
    if (peerID) {        
        if (gameStep == 5) {
            [self prepareNewRound];
        }
        if (currentSeeder == nil || (currentSeeder && [currentSeeder compare:peerID] == NSOrderedAscending)) {
            currentSeeder = peerID;

            Player *p = [players objectForKey:currentSeeder];
            NSLog(@"setCurrentSeeder(): %@ (%@)", [p name], currentSeeder);            
        }
    }
}

- (void)unveilNextPhoto:(NSString*)peerID {      
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
    [navBarItem setTitle:label];
    
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

    
    if (unveiledPhotoCounter >= [players count]) {
        [customeBtn1 setTitle:GO_VOTE forState:UIControlStateNormal];
    } 
    else {
        [customeBtn1 setTitle:NEXT_PIC forState:UIControlStateNormal];        
    }
    [navBarItem setRightBarButtonItem:navBarBtnItem animated:NO];     
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
    
    //i've voted
    if (iVoteForPeerID != nil) {
        NSString *winner = [self doneWithVotingYet];
        //no winner yet
        if (winner == nil) {
            //clearing scroll view
            for (UIView *view in scrollView.subviews) {
                [view removeFromSuperview];
            }

            //all voted photos faced DOWN
            int votedCount = 0;
            UIButton *btn;            
            UIImage *hidImg = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pwp_hidden_image" ofType:@"png"]];            
            for (id key in players) {
                id player = [players objectForKey:key];
                if ([player roundVotedFor] != nil) {
                    btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.frame = CGRectMake(((75.0+2.0) * votedCount), 0.0, 75.0, 75.0);  
                    [btn setImage:hidImg forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(submittedPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [scrollView addSubview:btn];                        
                    votedCount++;
                    
                }
            }
            [scrollView setContentSize:CGSizeMake(((75.0+2.0) * votedCount), 80)];            
                        
        }
        else {//done voting, unveil results
            [self unveilVotes];
        }
    }    
}

- (void)doneWithUnveilingPhotos:(NSString*)peerID {
    //this is sent from the seeder to the rest
    gameStep = 4;
    [self gameFlowNext];    
}

- (NSString*)doneWithVotingYet {//return nil if not done, winner peerID or "tie"
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
            return @"tie";
        }
        else {
            return winner;
        }
    }
    else {
        return nil;
    }
}

- (void)unveilVotes {
    
    NSString *winner = [self doneWithVotingYet];
    
    if (winner != nil) {
        if ([winner compare:@"tie"] == NSOrderedSame) {
            [scrollViewLabel setText:@"It's a tie!"];            
        }
        else {
            NSMutableString *tempStr = [NSMutableString stringWithString:@"Congrats, "];
            Player *plWinner = [players objectForKey:winner];
            [tempStr appendFormat:@"%@!", plWinner.name];
            [scrollViewLabel setText:tempStr];
        }
        
        
        //clearing scroll view
        for (UIView *view in scrollView.subviews) {
            [view removeFromSuperview];
        }
        
        //all voted photos faced UP
        int viewCount = 0;
        UIButton *btn;            
        for (id key in players) {
            id player = [players objectForKey:key];
            btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:key forState:UIControlStateNormal];
            btn.frame = CGRectMake(((75.0+2.0) * viewCount), 0.0, 75.0, 75.0);  
            [btn setImage:[player roundPhoto] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submittedPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [scrollView addSubview:btn];                        
            viewCount++;
                
        }
        [scrollView setContentSize:CGSizeMake(((75.0+2.0) * viewCount), 80)];        


        //adding vote count to the top right corner of each image
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
                [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                [btn.layer setBorderColor:[[UIColor whiteColor] CGColor]];
                [[btn layer] setCornerRadius:8.0f];
                [[btn layer] setMasksToBounds:YES];
                [[btn layer] setBorderWidth:2.0f]; 
                [btn setBackgroundColor:[UIColor colorWithRed:31.0/255.0 green:199.0/255.0 blue:48.0/255.0 alpha:1.0]];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
                [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0]];  
                btn.frame = CGRectMake((77*j+59), 0.0, 17, 17);
                [scrollView addSubview:btn];

                j++;
            }
        }
        
        
        gameStep = 5;
        [self gameFlowNext];        
    }
    
}

@end
