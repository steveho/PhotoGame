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
    PacketTypeDataIVoteForPeerID = 17,
    PacketTypeNotifyDoneUnveilingPhoto = 18,
    PacketTypeDataPlayPhotoCaption = 19
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
- (void)setLocalSeedPhoto:(UIImage*)img seeder:(NSString*)peerID;
- (UIImage*)getLocalSeedPhoto;

- (void)updatePlayerInfoName:(NSString*)peerID value:(NSString*)name;
- (void)updatePlayerInfoPlayPhoto:(NSString*)peerID value:(UIImage*)roundPhoto;
- (void)updatePlayerInfoPlayVotes:(NSString*)peerID value:(int)roundVotes;
- (void)updatePlayerInfoPlayPhotoCaption:(NSString*)peerID value:(NSString*)caption;

- (void)gameFlowNext; // to determine the game next step
- (void)setCurrentSeeder:(NSString*)peerID; // the one with the seed photo being used for this round
- (BOOL)allHaveSubmittedPhoto;
- (void)unveilNextPhoto:(NSString*)peerID;
- (void)readyForNextUnveilPhoto:(NSString*)peerID;
- (void)whoVotesForWho:(NSString*)voter votee:(NSString*)votee;
- (void)doneWithUnveilingPhotos:(NSString*)peerID;
- (void)unveilVotes;
- (NSString*)doneWithVotingYet;

@end