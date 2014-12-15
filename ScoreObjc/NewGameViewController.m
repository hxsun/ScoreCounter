//
//  NewGameViewController.m
//  ScoreObjc
//
//  Created by Kenneth Sun on 10/24/14.
//  Copyright (c) 2014 Kenneth Sun. All rights reserved.
//

#import "XLForm.h"
#import "NewGameViewController.h"
#import "Game.h"
#import "Player.h"

@implementation NewGameViewController

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateParent" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"新游戏"];
    
    // MultivaluedSection section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"玩家列表" multivaluedSection:true];
    section.multiValuedTag = @"newPlayersSection";
    [form addFormSection:section];
    
    // add a row to the section, the row will be used to crete new rows.
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText];
    [[row cellConfig] setObject:@"添加新玩家名称" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    self.form = form;
}
- (IBAction)didSaveData:(id)sender {
    
    Game* newGame = [Game MR_createEntity];
    newGame.createDate = [NSDate date];
    // [newGame.createDate timeInterval]
    long initialId = [newGame.createDate timeIntervalSince1970];
    
    NSLog(@"dateInterval is %ld", initialId);
    
    NSDictionary* dataDictionary = self.form.formValues;
    NSArray* namesList = [dataDictionary mutableArrayValueForKey:@"newPlayersSection"];
    
    for (NSString* name in namesList) {
        NSString* trimedName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSLog(@"%@", trimedName);
        
        if ([trimedName length] != 0) {
            Player* player = [Player MR_createEntity];
            player.name = trimedName;
            player.score = [NSNumber numberWithLong:0];
            player.whichGame = newGame;
            player.id = [NSNumber numberWithDouble:++initialId];
        }
        
    }
    [self saveContext];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your default context.");
        } else {
            NSLog(@"Error saving context: %@", error.localizedDescription);
        }
    }];
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
