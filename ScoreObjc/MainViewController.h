//
//  MainViewController.h
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/24/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext * managedObjectContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
