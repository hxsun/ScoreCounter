//
//  Game.h
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/25/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface Game : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSSet *hasPlayers;
@end

@interface Game (CoreDataGeneratedAccessors)

- (void)addHasPlayersObject:(Player *)value;
- (void)removeHasPlayersObject:(Player *)value;
- (void)addHasPlayers:(NSSet *)values;
- (void)removeHasPlayers:(NSSet *)values;

@end
