//
//  MainViewController.m
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/24/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import "MainViewController.h"
#import "PXAlertView.h"
#import "Game.h"
#import "Player.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)reloadFetchedResults:(NSNotification *)notification {
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    if (notification) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self reloadFetchedResults:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFetchedResults:)
                                                 name:@"updateParent"
                                               object:nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.fetchedResultsController = nil;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)clickToCreateNewGame:(id)sender {
    
    [PXAlertView showAlertWithTitle:@"重新开始游戏" message:@"确认是否重新开始游戏，所有玩家信息将丢失！" cancelTitle:@"取消" otherTitle:@"确认" completion:^(BOOL cancelled, NSInteger buttonIndex) {
        if (cancelled) {
            NSLog(@"Cancel button clicked");
        } else {
            NSLog(@"Confirm button clicked");
            [self performSegueWithIdentifier:@"newGameSegue" sender:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger count = [[self.fetchedResultsController sections] count];
    
    if (count == 0) {
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Player* player = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSLog(@"%@ gets %@", player.name, [NSString stringWithFormat:@"%d", [player.score intValue]]);
    cell.textLabel.text = player.name;
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [player.score intValue]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18.0];
    
    if ([player.score intValue] < 0) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:1 green:0.231 blue:0.188 alpha:1]; /*#ff3b30*/
    } else if ([player.score intValue] > 0) {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.298 green:0.851 blue:0.392 alpha:1]; /*#4cd964*/
    } else {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        Game *game = [Game MR_findFirstOrderedByAttribute:@"createDate" ascending:NO];
        if (game != nil) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"whichGame", game];
            self.fetchedResultsController = [Player MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
        }

    }
    return _fetchedResultsController;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"playerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeUpdate:
        case NSFetchedResultsChangeInsert:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}


- (IBAction)unwindFromRefreshModalViewController:(UIStoryboardSegue *)segue {
    
}

@end
