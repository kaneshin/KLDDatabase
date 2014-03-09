// KLDActiveRecord.m
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

#import "KLDActiveRecord.h"

typedef NS_ENUM(NSUInteger, KLDActiveRecordType) {
    KLDActiveRecordTypeSelect,
    KLDActiveRecordTypeInsert,
};

@implementation KLDActiveRecord {
    NSString *_table;
    NSArray *_fields;
    NSArray *_values;
    NSString *_condition;
    uint64_t _limit;
    uint64_t _offset;
    KLDActiveRecordType _type;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _table = [NSString string];
    _fields = [NSArray array];
    _values = [NSArray array];
    _condition = [NSString string];
    _limit = 0;
    _offset = 0;
}

- (NSString *)query
{
    NSMutableString *sql = [NSMutableString string];
    if (_table.length > 0) {
        if (KLDActiveRecordTypeSelect == _type) {
            NSString *temp = [NSString string];
            temp = (_fields.count > 0 ? [_fields componentsJoinedByString:@","] : @"*");
            [sql appendFormat:@"SELECT %@ FROM %@", temp, _table];
            if (_condition.length > 0) {
                [sql appendFormat:@" WHERE %@", _condition];
            }
            if (_limit > 0) {
                [sql appendFormat:@" LIMIT %lld OFFSET %lld", _limit, _offset];
            }
        } else if (KLDActiveRecordTypeInsert == _type) {
            [sql appendFormat:@"INSERT INTO %@", _table];
            if (_fields.count > 0) {
                [sql appendFormat:@" (%@) VALUES", [_fields componentsJoinedByString:@","]];
            }
            if (_values.count > 0) {
                NSMutableArray *values = [NSMutableArray array];
                for (NSDictionary *data in _values) {
                    NSMutableArray *temp = [NSMutableArray array];
                    for (NSString *key in _fields) {
                        id value = [data objectForKey:key];
                        value = !value || [value isEqual:[NSNull null]] ? @"" : value;
                        if ([value isKindOfClass:[NSString class]]) {
                            [temp addObject:[NSString stringWithFormat:@"\"%@\"", value]];
                        } else if ([value isKindOfClass:[NSNumber class]]) {
                            [temp addObject:[NSString stringWithFormat:@"%@", value]];
                        }
                    }
                    [values addObject:[NSString stringWithFormat:@"(%@)", [temp componentsJoinedByString:@","]]];
                }
                [sql appendFormat:@" %@", [values componentsJoinedByString:@","]];
            }
        }
        [sql appendString:@";"];
    }
    [self initialize];
    return sql;
}

- (instancetype)get:(NSString *)table
{
    _type = KLDActiveRecordTypeSelect;
    _table = [table copy];
    return self;
}

- (instancetype)select:(NSArray *)fields
{
    _type = KLDActiveRecordTypeSelect;
    _fields = [fields copy];
    return self;
}

- (instancetype)from:(NSString *)table
{
    _table = [table copy];
    return self;
}

- (instancetype)where:(NSString *)condition
{
    _condition = [condition copy];
    return self;
}

- (instancetype)where:(NSString *)field in:(NSArray *)values
{
    NSMutableArray *temp = [NSMutableArray array];
    for (id value in values) {
        if ([value isKindOfClass:[NSString class]]) {
            [temp addObject:[NSString stringWithFormat:@"\"%@\"", value]];
        } else if ([value isKindOfClass:[NSNumber class]]) {
            [temp addObject:[NSString stringWithFormat:@"%@", value]];
        }
    }
    _condition = [NSString stringWithFormat:@"%@ IN (%@)", field, [temp componentsJoinedByString:@","]];
    return self;
}

- (instancetype)limit:(uint64_t)limit
{
    _limit = limit;
    return self;
}

- (instancetype)offset:(uint64_t)offset
{
    _offset = offset;
    return self;
}

- (instancetype)insert:(NSString *)table data:(id)data
{
    _type = KLDActiveRecordTypeInsert;
    _table = [table copy];
    if ([data isKindOfClass:[NSArray class]]) {
        _fields = [[[data objectAtIndex:0] keyEnumerator] allObjects];
        _values = [data copy];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        _fields = [[data keyEnumerator] allObjects];
        _values = @[data];
    }
    return self;
}

@end
