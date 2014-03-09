// KLDDatabase.m
//
// Copyright (c) 2014 Shintaro Kaneko (http://kaneshinth.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "KLDDatabase.h"

#import <sqlite3.h>
#import "KLDResult.h"
#import "KLDResultSet.h"

@interface KLDDatabase ()
- (void)initializeDatabase;
@end

@implementation KLDDatabase {
    sqlite3 *_db;
    NSString *_name;
    NSURL *_storeURL;
    struct {
        unsigned int isOpened:1;
        unsigned int openFlags:4;
    } _databaseFlags;
}

+ (instancetype)databaseWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name copy];
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _storeURL = [documentsDirectory URLByAppendingPathComponent:name];
        [self initializeDatabase];
    }
    return self;
}

- (void)initializeDatabase
{
    _db = NULL;
    _databaseFlags.isOpened = false;
    _databaseFlags.openFlags = 0x0;
}

- (void)finalize
{
    [self close];
    [super finalize];
}

- (void)dealloc
{
    [self close];
}

- (BOOL)open
{
    if ([self isOpened]) {
        return YES;
    }
    
    int flags = KLDSQLiteOpenFlagReadWrite;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[_storeURL path]]) {
        NSString *sqlitePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_name];
        NSError *error = nil;
        if (![fileManager copyItemAtPath:sqlitePath toPath:[_storeURL path] error:&error]) {
            flags |= KLDSQLiteOpenFlagCreate;
        }
    }
    
    const char *databasePath = [[_storeURL path] UTF8String];
    if (sqlite3_open(databasePath, &_db) == SQLITE_OK) {
        _databaseFlags.isOpened = true;
        _databaseFlags.openFlags = flags;
        return YES;
    }
    return NO;
}

- (BOOL)openWithFlags:(KLDSQLiteOpenFlags)flags
{
    if ([self isOpened]) {
        return YES;
    }
    
    int sqliteFlags = 0x0;
    if (flags & KLDSQLiteOpenFlagReadonly) {
        flags = KLDSQLiteOpenFlagReadonly;
        sqliteFlags |= SQLITE_OPEN_READONLY;
    } else {
        if (flags & KLDSQLiteOpenFlagReadWrite) {
            sqliteFlags |= SQLITE_OPEN_READWRITE;
        }
        if (flags & KLDSQLiteOpenFlagCreate) {
            sqliteFlags |= SQLITE_OPEN_CREATE;
        }
    }
    
    if (!(flags & KLDSQLiteOpenFlagCreate)) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[_storeURL path]]) {
            NSString *sqlitePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:_name];
            NSError *error = nil;
            if (![fileManager copyItemAtPath:sqlitePath toPath:[_storeURL path] error:&error]) {
                return NO;
            }
        }
    }
    
    const char *databasePath = [[_storeURL path] UTF8String];
    if (sqlite3_open_v2(databasePath, &_db, sqliteFlags, NULL) == SQLITE_OK) {
        _databaseFlags.isOpened = true;
        _databaseFlags.openFlags = flags;
        return YES;
    }
    return NO;
}

- (BOOL)close
{
    if (![self isOpened]) {
        return YES;
    }
    if (sqlite3_close(_db)) {
        [self initializeDatabase];
        return YES;
    }
    return NO;
}

- (BOOL)remove
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[_storeURL path]]) {
        if ([self close]) {
            NSError *error = nil;
            BOOL result = [fileManager removeItemAtPath:[_storeURL path] error:&error];
            if (!result) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            return result;
        }
    }
    return NO;
}

- (BOOL)isOpened
{
    return (BOOL)(_db && _databaseFlags.isOpened);
}

- (BOOL)isReadonly
{
    return (BOOL)(_databaseFlags.openFlags & KLDSQLiteOpenFlagReadonly);
}

- (BOOL)isWritable
{
    return (BOOL)(_databaseFlags.openFlags & KLDSQLiteOpenFlagReadWrite);
}

- (KLDResultSet *)query:(NSString *)sql
{
    if (![self isOpened]) {
        return [[KLDResultSet alloc] init];
    }
    sqlite3_stmt *statement = NULL;
    sqlite3_prepare_v2(_db, [sql UTF8String], -1, &statement, NULL);
    NSMutableArray *rows = [NSMutableArray array];
    NSMutableArray *columns = [NSMutableArray array];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        if (!columns.count) {
            int i = 0;
            const char *column;
            while ((column = sqlite3_column_name(statement, i))) {
                [columns addObject:[NSString stringWithCString:column encoding:NSUTF8StringEncoding]];
                ++i;
            }
        }
        int i = 0;
        const unsigned char *val;
        NSMutableDictionary *record = [NSMutableDictionary dictionary];
        while ((val = sqlite3_column_text(statement, i))) {
            NSString *obj = [NSString stringWithCString:(char *)val encoding:NSUTF8StringEncoding];
            obj = !obj || [obj isEqual:[NSNull null]] ? @"" : obj;
            [record setObject:obj forKey:[columns objectAtIndex:i]];
            ++i;
        }
        KLDResult *result = [KLDResult resultWithRecord:record];
        [rows addObject:result];
    }
    sqlite3_finalize(statement);
    KLDResultSet *result = [KLDResultSet resultWithRows:rows];
    [result setExecutedQuery:sql];
    return result;
}

@end
