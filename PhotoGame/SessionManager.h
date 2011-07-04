//
//  SessionManager.h
//  PhotoGame
//
//  Created by Steve Ho on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h> 

typedef enum {    
    PacketTypeQueryNeedSeedPhoto = 10,
    PacketTypeDataSeedPhoto = 11,
    PacketTypeDataPlayPhoto = 12,
    PacketTypeDataPlayerName = 13,
    PacketTypeDataUnveilPhoto = 14,
    PacketTypeDataDoneViewingCurrentPhoto = 15,
    PacketTypeNotifyIAmTheSeeder = 16,
    PacketTypeNotifyDoneUnveilingPhoto = 18,
    PacketTypeDataIVoteForPeerID = 17,
    
    PacketTypeGameStep0 = 0,
    PacketTypeGameStep1 = 1,
    PacketTypeGameStep2 = 2,
    PacketTypeGameStep3 = 3,
    PacketTypeGameStep4 = 4,
} PacketType;

@interface SessionManager : NSObject <GKSessionDelegate> {
	GKSession *mySession;
    NSMutableArray *playerList;
    id delegate;
}

@property (nonatomic, retain) GKSession *mySession;
@property (nonatomic, retain) NSMutableArray *playerList;
@property (nonatomic, assign) id delegate;


- (void)setupSession;
- (void)sendData:(NSData*)data ofType:(PacketType)type to:(NSArray*)peers;

@end








@protocol GamePlayDelegate

- (void)playerListDidChange:(SessionManager *)session peer:(NSString*)peerID;
- (void)sendDataToPeer:(NSString*)peerID type:(PacketType)type data:(NSData*)data;
- (void)sendSeedPhotoToPeer:(NSString*)peerID;
- (void)sendBasicInfoToPeer:(NSString*)peerID;
- (void)removePlayer:(NSString*)peerID;
- (void)setLocalSeedPhoto:(UIImage*)img;
- (UIImage*)getLocalSeedPhoto;

- (void)updatePlayerInfoName:(NSString*)peerID value:(NSString*)name;
- (void)updatePlayerInfoPlayPhoto:(NSString*)peerID value:(UIImage*)currentPlayPhoto;
- (void)updatePlayerInfoPlayVotes:(NSString*)peerID value:(int)currentPlayVotes;

- (void)gameFlowNext; // to determine the game next step
- (void)setCurrentSeeder:(NSString*)peerID; // the one with the seed photo being used for this round
- (BOOL)allHaveSubmittedPhoto;
- (void)unveilNextPhoto:(NSString*)peerID;
- (void)readyForNextUnveilPhoto:(NSString*)peerID;
- (void)whoVotesForWho:(NSString*)voter votee:(NSString*)votee;
- (void)doneWithUnveilingPhotos:(NSString*)peerID;

@end