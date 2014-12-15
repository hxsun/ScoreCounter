//
//  RoundRecordViewController.h
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/25/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import "XLFormViewController.h"

@interface RoundRecordViewController : XLFormViewController

@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

@end
