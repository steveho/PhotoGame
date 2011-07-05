//
//  SessionManager.m
//  PhotoGame
//
//  Created by Steve Ho on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

@synthesize mySession, delegate, playerList;


- (id)init {
	if ((self = [super init])) {
        
        // Set up starting/stopping session on application hiding/terminating
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willTerminate:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
	}
	return self;  
}

- (void)dealloc {
	mySession = nil;
    [super dealloc];
}

- (void)willTerminate:(NSNotification *)notification {
    [mySession disconnectFromAllPeers];
    mySession.delegate = nil;
    [mySession setDataReceiveHandler:nil withContext:nil];
    [mySession release];
    mySession = nil;
    [playerList release];
    playerList = nil;
}

#pragma mark - Session & data

- (void)setupSession {
    
    
	mySession = [[GKSession alloc] initWithSessionID:@"PhotoGame" displayName:@"PhotoGame" sessionMode:GKSessionModePeer];
	mySession.delegate = self; 
	[mySession setDataReceiveHandler:self withContext:nil]; 
	mySession.available = YES;
    [mySession setDisconnectTimeout:5.0];
    
    [playerList addObject:[mySession peerID]];
    
}


// Received an invitation.  If we aren't already connected to someone, open the invitation dialog.
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
    
}

// Unable to connect to a session with the peer, due to rejection or exiting the app
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    
}

// The running session ended, potentially due to network failure.
- (void)session:(GKSession *)session didFailWithError:(NSError*)error {
    NSLog(@"%@",[error localizedDescription]);
}

// React to some activity from other peers on the network.
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    NSError *error = nil;
	switch (state) { 
		case GKPeerStateAvailable:
            [mySession connectToPeer:peerID withTimeout:10];                
            break;
		case GKPeerStateUnavailable:
            [delegate playerListDidChange:self peer:peerID];
			break;
		case GKPeerStateConnected:
            [delegate playerListDidChange:self peer:peerID];
            if ([delegate getLocalSeedPhoto]) {
                [delegate sendSeedPhotoToPeer:peerID];
            }
            [delegate sendBasicInfoToPeer:peerID];
			break;				
		case GKPeerStateDisconnected:
            [delegate playerListDidChange:self peer:peerID];
            [delegate removePlayer:peerID];
			break;
        case GKPeerStateConnecting:
            if (![mySession acceptConnectionFromPeer:peerID error:&error]) {
                NSLog(@"%@",[error localizedDescription]);
            }            
            break;
		default:
			break;
	}
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {

    PacketType header;
    uint32_t swappedHeader;
    if ([data length] >= sizeof(uint32_t)) {    
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (PacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        
        if (header == PacketTypeDataSeedPhoto) {//seed photo
            UIImage *img = [UIImage imageWithData:payload];
            [delegate setLocalSeedPhoto:img];
            [delegate setCurrentSeeder:peer];
        } 
        else if (header == PacketTypeDataPlayPhoto) {//play photo (player submits his photo)
            UIImage *img = [UIImage imageWithData:payload];
            [delegate updatePlayerInfoPlayPhoto:peer value:img];
        }
        else if (header == PacketTypeDataPlayPhotoCaption) {//play photo caption
            NSMutableString *caption = [[NSMutableString alloc] initWithData:payload encoding:[NSString defaultCStringEncoding]];            
            [delegate updatePlayerInfoPlayPhotoCaption:peer value:caption];
        }
        else if (header == PacketTypeDataPlayerName) {//player name
            NSMutableString *name = [[NSMutableString alloc] initWithData:payload encoding:[NSString defaultCStringEncoding]];
            [delegate updatePlayerInfoName:peer value:name];
        }
        else if (header == PacketTypeDataUnveilPhoto) {//unveil photo
            NSMutableString *unveilPeerID = [[NSMutableString alloc] initWithData:payload encoding:[NSString defaultCStringEncoding]];
            [delegate unveilNextPhoto:unveilPeerID];
        }    
        else if (header == PacketTypeDataDoneViewingCurrentPhoto) {//done viewing current photo (unveil stage)
            //this is strictly sent to the current seeder
            [delegate readyForNextUnveilPhoto:peer];
        }
        else if (header == PacketTypeNotifyDoneUnveilingPhoto) {//done with unveiling photos (sent from seeder)
            [delegate doneWithUnveilingPhotos:peer];
        }        
        else if (header == PacketTypeNotifyIAmTheSeeder) {//I am the seeder
            [delegate setCurrentSeeder:peer];
        }
        else if (header == PacketTypeDataIVoteForPeerID) {//vote
            NSMutableString *votee = [[NSMutableString alloc] initWithData:payload encoding:[NSString defaultCStringEncoding]];            
            [delegate whoVotesForWho:peer votee:votee];
        }          
        else {

        }
    }    
    
    

    
    

}

-(void) sendData:(NSData*)data ofType:(PacketType)type to:(NSArray*)peers {
    NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];

    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    NSError *error;
    if (![mySession sendData:newPacket toPeers:peers withDataMode:GKSendDataReliable error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }

}


@end
