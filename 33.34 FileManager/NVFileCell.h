//
//  NVFileCell.h
//  33.34 FileManager
//
//  Created by Admin on 15.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVFileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelFileName;
@property (weak, nonatomic) IBOutlet UILabel *labelFileSize;
@property (weak, nonatomic) IBOutlet UILabel *labelFileDate;

@end
