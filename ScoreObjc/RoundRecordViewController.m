//
//  RoundRecordViewController.m
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/25/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import "RoundRecordViewController.h"
#import "XLForm.h"
#import "Game.h"
#import "Player.h"
#import "PXAlertView.h"

@interface RoundRecordViewController ()

@property (nonatomic, strong) NSMutableDictionary *playerScores;
@property (nonatomic, strong) NSMutableDictionary *scoreDictionaryForValidation;
@property (nonatomic) NSInteger numberOfBombs;

@end

@implementation RoundRecordViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadFetchedResults:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateParent" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadFetchedResults:(NSNotification *)notification {
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    if (notification) {
        [self.tableView reloadData];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        Game *game = [Game MR_findFirstOrderedByAttribute:@"createDate" ascending:NO];
        if (game != nil) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"whichGame", game];
            self.fetchedResultsController = [Player MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:predicate groupBy:nil delegate:nil];
        }
        
    }
    return _fetchedResultsController;
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"当局战果"];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"炸弹总数"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"numberOfBomb"
                                                rowType:XLFormRowDescriptorTypeSelectorPickerView
                                                  title:@"炸弹数量"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"未使用炸弹"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"1个"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"2个"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"3个"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"4个"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"5个"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"6个"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"未使用炸弹"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"玩家剩余张数"];
    [form addFormSection:section];
    
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numberOfPlayers = [sectionInfo numberOfObjects];
    
    for (int i = 0; i < numberOfPlayers; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        Player *player = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        // Set up the row
        row = [XLFormRowDescriptor formRowDescriptorWithTag:[player.id stringValue]
                                                    rowType:XLFormRowDescriptorTypeSelectorPickerView
                                                      title:player.name];
        // NSLog(@"player.id is %@", player.id);
        
        row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"0张"],
                               [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"1张"],
                               [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"2张"],
                               [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"3张"],
                               [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"4张"],
                               [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"5张"]];
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"0张"];
        [section addFormRow:row];
        [self.playerScores setObject:player forKey:[player.id stringValue]];
    }
    
    
    self.form = form;
}
- (IBAction)saveRoundData:(id)sender {
    NSString *errorMsg;
    Boolean hasError = false;
    
    XLFormSectionDescriptor *firstSection = self.form.formSections[0];
    for (XLFormRowDescriptor *row in firstSection.formRows) {
        if (row.tag && [row.tag isEqualToString:@"numberOfBomb"]) {
            XLFormOptionsObject *selected = row.value;
            self.numberOfBombs = [selected.formValue integerValue];
        }
        
    }
    
    Player *winner;
    NSInteger winningScore = 0;
    
    Boolean hasWinner = false;
    
    XLFormSectionDescriptor *secSection = self.form.formSections[1];
    for (XLFormRowDescriptor *row in secSection.formRows) {
        if ([self.playerScores.allKeys containsObject:row.tag]) {
            XLFormOptionsObject *selected = row.value;
            
            NSInteger score = [selected.formValue integerValue];
            
            if (score == 0) {
                if (!hasWinner) {
                    hasWinner = true;
                    winner = [self.playerScores objectForKey:row.tag];
                } else {
                    hasError = true;
                    errorMsg = @"不能存在多个赢家!";
                    NSLog(@"This round has more than one winners.");
                }
            } else if (score != 1) {
                NSInteger calculatedScore = -1 * score * pow(2, self.numberOfBombs);
                if (score == 5) {
                    calculatedScore *= 2;
                }
                winningScore += calculatedScore * -1;
                [self.scoreDictionaryForValidation setValue:[NSNumber numberWithLong:calculatedScore] forKey:row.tag];

            }
        }
    }
    
    if (!hasWinner) {
        hasError = true;
        errorMsg = @"当局必须要有玩家获胜!";
    }
    
    if (hasError) {
        [PXAlertView showAlertWithTitle:@"错误" message:errorMsg cancelTitle:@"OK" completion:nil];
    } else {
        [self.scoreDictionaryForValidation setObject:[NSNumber numberWithLong:winningScore] forKey:[winner.id stringValue]];
        NSString *confirmMsg = [NSString stringWithFormat:@"%@获得了%ld分", winner.name, (long)winningScore];
        [PXAlertView showAlertWithTitle:@"确认比分" message:confirmMsg cancelTitle:@"取消" otherTitle:@"确认" completion:^(BOOL cancelled, NSInteger buttonIndex) {
            if (cancelled) {
                NSLog(@"User canceled the input.");
            } else {
                for (NSString *key in self.scoreDictionaryForValidation.allKeys) {
                    Player *player = [self.playerScores objectForKey:key];
                    player.score = [NSNumber numberWithLong:([player.score longValue] + [[self.scoreDictionaryForValidation valueForKey:key] longValue])];
                    
                    NSLog(@"%@获得%ld", player.name, [[self.scoreDictionaryForValidation valueForKey:key] longValue]);
                }
                [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (NSMutableDictionary *)scoreDictionaryForValidation {
    if (_scoreDictionaryForValidation == nil) {
        _scoreDictionaryForValidation = [NSMutableDictionary dictionary];
    }
    
    return _scoreDictionaryForValidation;
}

- (NSMutableDictionary *)playerScores {
    if (_playerScores == nil) {
        _playerScores = [NSMutableDictionary dictionary];
    }
    return _playerScores;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
