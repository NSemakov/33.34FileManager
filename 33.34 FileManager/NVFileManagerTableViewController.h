//
//  NVFileManagerTableViewController.h
//  33.34 FileManager
//
//  Created by Admin on 15.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVFileManagerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate,NSFileManagerDelegate>
- (IBAction)actionEditTable:(UIBarButtonItem *)sender;
@property (strong,nonatomic) NSString* path;
@property (strong,nonatomic) NSArray* arrayOfContent;
@property (strong,nonatomic) NSOperationQueue* queue;
@property (strong,nonatomic) NSMutableDictionary* dictOfOperations;
@property (assign,nonatomic) BOOL isItemDeleted;
- (IBAction)actionBackToRoot:(UIBarButtonItem*)sender;
- (IBAction)actionAdd:(UIBarButtonItem *)sender;

@end
// /Users/admin/Desktop/XCodeProjects