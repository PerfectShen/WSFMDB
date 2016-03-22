//
//  ViewController.m
//  WSFMDB
//
//  Created by TYRBL on 15/10/28.
//  Copyright © 2015年 Senro Wang. All rights reserved.
//

#import "ViewController.h"

#import "explame.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *numTF;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;
@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
//    explame  *aE = [[explame alloc] init];
//    aE.number = @"3";
//    aE.name = @"108965";
//    [aE saveOrUpdate];
//    
//    
//    explame *expObj = [explame findWhereColoum:@"number" equleToValue:@"3"];
//    NSLog(@" %@ , %@",expObj.number,expObj.name);
    
    [self _queryResult];
    
}


- (IBAction)addAction:(id)sender {
    
    explame *aE = [[explame alloc] init];
    aE.number = self.numTF.text;
    aE.name = self.nameTF.text;
    
    [aE saveOrUpdate];
    
    [self _queryResult];
    
}
- (IBAction)deleAction:(id)sender {
    
    NSString *num = self.numTF.text;
    
   BOOL sucess =  [explame deleteObjectsByCriteria:[NSString stringWithFormat:@"where number = '%@'",num]];
    
    NSLog(@"%zd",sucess);
    
    [self _queryResult];
    
}


- (void)_queryResult{
    
   NSArray *array =  [explame findByCriteria:@""];
    
    
    NSMutableArray  *textArray = @[].mutableCopy;
//    NSMutableArray *nameAraay = @[].mutableCopy;
    for (explame *model in array) {
        
        [textArray addObject:model.number];
         [textArray addObject:@" "];
        [textArray addObject:model.name];
        [textArray addObject:@"   "];
       
        
    }
    self.resultTextView.text = [textArray componentsJoinedByString:@""];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
