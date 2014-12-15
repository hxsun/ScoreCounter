//
//  Player.h
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/25/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game;

@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) Game *whichGame;

@end
