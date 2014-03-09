// KLDDatabase.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KLDSQLiteOpenFlags) {
    KLDSQLiteOpenFlagReadonly   = 1 << 0,
    KLDSQLiteOpenFlagReadWrite  = 1 << 1,
    KLDSQLiteOpenFlagCreate     = 1 << 2,
};

@class KLDResultSet;

@interface KLDDatabase : NSObject

+ (instancetype)databaseWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name;

- (BOOL)open;
- (BOOL)openWithFlags:(KLDSQLiteOpenFlags)flags;

- (BOOL)close;
- (BOOL)remove;

- (BOOL)isOpened;
- (BOOL)isReadonly;
- (BOOL)isWritable;

- (KLDResultSet *)query:(NSString *)sql;

@end
