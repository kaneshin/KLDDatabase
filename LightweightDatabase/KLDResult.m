// KLDResult.m
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

#import "KLDResult.h"

@interface KLDResult ()
@property (readwrite, nonatomic, strong) NSDictionary *record;
@end

@implementation KLDResult
+ (instancetype)resultWithRecord:(NSDictionary *)record
{
    return [[[self class] alloc] initWithRecord:record];
}

- (instancetype)initWithRecord:(NSDictionary *)record
{
    self = [super init];
    if (self) {
        _record = [record copy];
    }
    return self;
}

- (NSArray *)namesOfColumn
{
    return [[self.record keyEnumerator] allObjects];
}

- (id)objectForKey:(id)aKey
{
    return [self.record objectForKey:aKey];
}
@end
