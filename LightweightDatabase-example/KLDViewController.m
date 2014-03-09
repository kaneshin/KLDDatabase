//
//  KLDViewController.m
//  LightweightDatabase
//
//  Created by Shintaro Kaneko on 3/8/14.
//  Copyright (c) 2014 kaneshinth.com. All rights reserved.
//

#import "KLDViewController.h"

#import "KLDDatabase.h"
#import "KLDResult.h"
#import "KLDResultSet.h"
#import "KLDActiveRecord.h"

@interface KLDViewController ()
@property (nonatomic, strong) KLDDatabase *masterDatabase;
@end

@implementation KLDViewController {
    KLDResultSet *_result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.masterDatabase = [KLDDatabase databaseWithName:@"master.sqlite"];
    [self.masterDatabase open];
    
    KLDActiveRecord *activeRecord = [[KLDActiveRecord alloc] init];
    [activeRecord get:@"prefectures"];
    _result = [self.masterDatabase query:activeRecord.query];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)(_result.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    KLDResult *row = [_result.rows objectAtIndex:indexPath.row];
    NSString *prefID = [row objectForKey:@"id"];
    NSString *prefName = [row objectForKey:@"name"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", prefID, prefName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
