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
    PacketTypeQueryNeedSeedPhoto = 0,
    PacketTypeDataSeedPhoto = 1,
    PacketTypeDataPlayPhoto = 2,
    PacketTypeDataPlayerName = 3
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

@end