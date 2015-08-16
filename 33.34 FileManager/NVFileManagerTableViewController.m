//
//  NVFileManagerTableViewController.m
//  33.34 FileManager
//
//  Created by Admin on 15.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NVFileManagerTableViewController.h"
#import "NVFileCell.h"
#import "NVFolderCell.h"
@interface NVFileManagerTableViewController ()

@end

@implementation NVFileManagerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.path) {
        self.path=@"/Users/admin/Desktop/XCodeProjects";
    }
    if (!self.dictOfOperations) {
        self.dictOfOperations=[[NSMutableDictionary alloc]init];
    }
    if (!self.queue) {
        self.queue=[[NSOperationQueue alloc]init];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.path=@"/Users/admin/Desktop/XCodeProjects";
        self.dictOfOperations=[[NSMutableDictionary alloc]init];
        self.queue=[[NSOperationQueue alloc]init];
        
    }
    return self;
}
- (void) setPath:(NSString *)path {
    _path=path;
    //self.arrayOfContent=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        self.arrayOfContent=[self contentsOfDirectoryWithURLAtFullPath:path];


}
- (NSArray*) contentsOfDirectoryWithURLAtFullPath:(NSString*) path {
    NSMutableArray *tempArray=[[NSMutableArray alloc]init];
    NSURL* url=[NSURL fileURLWithPath:path];
    self.arrayOfContent=[[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants error:nil];
    for (NSURL* obj in self.arrayOfContent){
        [tempArray addObject:[[obj path] lastPathComponent]];
    }
    NSArray* arrayOut=[self sortArrayByCellsAndFoldersAndByNames:tempArray];
    return arrayOut;

}
- (BOOL) isDirectoryAtPath:(NSString*) path {
    BOOL isDirectory=YES;
    NSString* entirePath=[self.path stringByAppendingPathComponent:path];
    [[NSFileManager defaultManager] fileExistsAtPath:entirePath isDirectory:&isDirectory];
    return isDirectory;
}
- (NSString*) convertFileSizeAtPath:(NSString*)path {
    NSString* entirePath=[self.path stringByAppendingPathComponent:path];
    NSError *error = nil;
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:entirePath error:&error];
    NSString *string=nil;
    if (attribs) {
        string = [NSByteCountFormatter stringFromByteCount:[attribs fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    }
    return string;
}
- (NSString*) defineFileModificationDateAtPath:(NSString*)path {
    NSString* entirePath=[self.path stringByAppendingPathComponent:path];
    NSError *error = nil;
    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:entirePath error:&error];
    NSString *string=nil;
    if (attribs) {
        NSDateFormatter* formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"dd.MM.yyyy HH:mm";
        string=[formatter stringFromDate:attribs.fileModificationDate];

    }
    return string;

}
//2nd way. Now is unused. Method is realized below, in NSBlockOperation where it can be cancelled. Though in this case it is almost useless, because the most hard part - taking subpaths - is presented by one function, and can't be cancelled during implementation. So, operation can be cancelled during enumerating paths.
//another possible option to cancel - use manual recursive function. But is it safe to call each loop async?...big question for a while
//- (unsigned long long) calculateFolderSizeAtPath:(NSString*) path{
    //1st way
- (NSString*) calculateFolderSizeAtPath:(NSString*) path{
    
    NSString* entirePath=[self.path stringByAppendingPathComponent:path];
    NSError *error = nil;
    NSArray* subpaths=[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:entirePath error:&error];
    unsigned long long folderSize=0;
    //NSLog(@"subpaths %@",subpaths);
    for (NSString* obj in subpaths){
        NSString* entireSubpath=[entirePath stringByAppendingPathComponent:obj];
        if (![self isDirectoryAtPath:[path stringByAppendingPathComponent:obj]]) {
            NSError *error1 = nil;
            NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:entireSubpath error:&error1];
            if (attribs) {
                folderSize += attribs.fileSize;
            }
        }
    }
    return [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    //end of 1st way
     /*
    
    unsigned long long folderSize=0;
    NSString* entirePath=[self.path stringByAppendingPathComponent:path];
    //NSLog(@"%@",entirePath);
        
        if (![self isDirectoryAtPath:path]) {
            //NSString* entireSubpath=[entirePath stringByAppendingPathComponent:obj];
            NSError *error1 = nil;
            NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:entirePath error:&error1];
            if (attribs) {
                folderSize += attribs.fileSize;
            }
            
        } else {
            NSArray* subPaths=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:entirePath error:nil];
            for (NSString* obj in subPaths){
                folderSize +=[self calculateFolderSizeAtPath:[path stringByAppendingPathComponent:obj]];
            }
        }
    
    return folderSize;
      */
}

- (NSArray*) sortArrayByCellsAndFoldersAndByNames:(NSArray*) arrayIn {
    NSArray *arrayOut=[arrayIn sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {

        BOOL isDirectoryAtPath1=[self isDirectoryAtPath:obj1];
        BOOL isDirectoryAtPath2=[self isDirectoryAtPath:obj2];
        if ((isDirectoryAtPath1 && isDirectoryAtPath2) || (!isDirectoryAtPath1 && !isDirectoryAtPath2)) {
            return NSOrderedSame;
        } else if (isDirectoryAtPath1 && !isDirectoryAtPath2){
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return arrayOut;
}

- (void) handleNameOfNewFolder:(NSString*) folderName{
    NSError* error=nil;
    NSString* newPathForDirectory=[self.path stringByAppendingPathComponent:folderName];
    BOOL isAccess=[[NSFileManager defaultManager] createDirectoryAtPath:newPathForDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
        NSLog(@"error:%@",[error localizedDescription]);
    }
    if (isAccess) {
        self.arrayOfContent=[self contentsOfDirectoryWithURLAtFullPath:self.path];
        [self.tableView beginUpdates];
        NSInteger index=[self.arrayOfContent indexOfObject:(NSString*)[newPathForDirectory lastPathComponent]];
        NSIndexPath* indexPath=[NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [self.arrayOfContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString* folderIdentifier=@"folderCell";
    static NSString* fileIdentifier=@"fileCell";
    NSString *currentPath=[self.arrayOfContent objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtPath:currentPath]) {
        NVFolderCell* cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier forIndexPath:indexPath];
        cell.labelFolderName.text=[currentPath lastPathComponent];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        /*
        NSBlockOperation* blockOperation=[NSBlockOperation blockOperationWithBlock:^{
            
            //1st way
            NSString* sizeOfFolder =[self calculateFolderSizeAtPath:currentPath];
            //2nd way
         
           //NSString* sizeOfFolder =[NSByteCountFormatter stringFromByteCount:[self calculateFolderSizeAtPath:currentPath] countStyle:NSByteCountFormatterCountStyleFile];
         
            //end of 2nd way
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[(NVFolderCell*)[tableView cellForRowAtIndexPath:indexPath] labelFolderSize] setText:sizeOfFolder];
                //cell.labelFolderSize.text - the same one
            }];
        }];
        */
        NSBlockOperation *blockOperation=[[NSBlockOperation alloc]init];
        __weak NSBlockOperation* weakOperation=blockOperation;
        [blockOperation addExecutionBlock:^{
            NSString* entirePath=[self.path stringByAppendingPathComponent:currentPath];
            NSError *error = nil;
            NSArray* subpaths=[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:entirePath error:&error];
            unsigned long long folderSize=0;
            //NSLog(@"subpaths %@",subpaths);
            for (NSString* obj in subpaths){
                if ([weakOperation isCancelled]) {
                    NSLog(@"cancelled");
                    return;
                }
                NSString* entireSubpath=[entirePath stringByAppendingPathComponent:obj];
                if (![self isDirectoryAtPath:[currentPath stringByAppendingPathComponent:obj]]) {
                    NSError *error1 = nil;
                    NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:entireSubpath error:&error1];
                    if (attribs) {
                        folderSize += attribs.fileSize;
                    }
                }
            }
            NSString *sizeOfFolder=[NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[(NVFolderCell*)[tableView cellForRowAtIndexPath:indexPath] labelFolderSize] setText:sizeOfFolder];
                //cell.labelFolderSize.text - the same one
            }];
            
        }];
        
        [self.queue addOperation:blockOperation];
        [self.dictOfOperations setValue:blockOperation forKey:currentPath];
        //NSLog(@"dict=%@",self.dictOfOperations);
        return cell;
    } else {
        NVFileCell* cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier forIndexPath:indexPath];
        cell.labelFileName.text=[currentPath lastPathComponent];
        cell.labelFileSize.text=[self convertFileSizeAtPath:currentPath];
        cell.labelFileDate.text=[self defineFileModificationDateAtPath:currentPath];
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* currentPath=[self.arrayOfContent objectAtIndex:indexPath.row];
    NSString* completePath=[self.path stringByAppendingPathComponent:currentPath];
    
    //NSLog(@"path:%@",currentPath);
    if ([self isDirectoryAtPath:currentPath]) {
        UIStoryboard* storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NVFileManagerTableViewController* newVC=[storyboard instantiateViewControllerWithIdentifier:@"NVFileManagerTableViewController"];
        newVC.path=completePath;
        [self.navigationController pushViewController:newVC animated:YES];
    }
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        NSError *error = nil;
        NSString* currentPath=[self.arrayOfContent objectAtIndex:indexPath.row];
        NSString* completePath=[self.path stringByAppendingPathComponent:currentPath];
        BOOL isDeleted = [[NSFileManager defaultManager] removeItemAtPath:completePath error:&error];
        if (isDeleted) {
            self.isItemDeleted=YES;
            [self cancellingOperation:indexPath];
            self.arrayOfContent=[self contentsOfDirectoryWithURLAtFullPath:[completePath stringByDeletingLastPathComponent]];
            
        }
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
    }
    
}
- (void) cancellingOperation:(NSIndexPath*)indexPath {
     NSString* opName=[self.arrayOfContent objectAtIndex:indexPath.row];
        //NSLog(@"cell:%@",opName);
        NSBlockOperation* op=[self.dictOfOperations valueForKey:opName];
        if (op) {
            [op cancel];
            [self.dictOfOperations removeObjectForKey:opName];
        }
}
#pragma mark -UITableViewDelegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    if (self.isItemDeleted) {
        self.isItemDeleted=NO;
    } else {
        [self cancellingOperation:indexPath];
    }
    
}

#pragma mark -actions

- (IBAction)actionEditTable:(UIBarButtonItem *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    UIBarButtonSystemItem buttonType=UIBarButtonSystemItemEdit;
    if (self.tableView.isEditing) {
        buttonType=UIBarButtonSystemItemDone;
    }
    UIBarButtonItem* buttonDone=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:buttonType target:self action:@selector(actionEditTable:)];
    [self.navigationItem setRightBarButtonItem:buttonDone];
}

- (IBAction)actionBackToRoot:(UIBarButtonItem*)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)actionAdd:(UIBarButtonItem *)sender {
    self.alertCtrl=[UIAlertController alertControllerWithTitle:@"Input folder name" message:@"please" preferredStyle:UIAlertControllerStyleAlert];
    [self.alertCtrl addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder=@"New folder name";
    }];
    
    UIAlertAction* okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField* field=self.alertCtrl.textFields.firstObject;
        [self handleNameOfNewFolder:field.text];
    }];
    UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.alertCtrl addAction:okAction];
    [self.alertCtrl addAction:cancelAction];
    [self presentViewController:self.alertCtrl animated:YES completion:nil];
}

@end
