//
//  Book.m
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/20/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

#import "Book.h"

@implementation Book

-(instancetype)initWithAuthor:(NSString *)author categories:(NSString *)categories bookid:(int)bookid lastCheckedOut:(NSString *)lastCheckedOut lastCheckedOutBy:(NSString *)lastCheckedOutBy publisher:(NSString *)publisher title:(NSString *)title url:(NSString *)url
{
    self = [super init];
    if(self)
    {
        _author = author;
        _categories = categories;
        _bookid = bookid;
        _lastCheckOutBy = lastCheckedOutBy;
        _publisher = publisher;
        _url = url;
        _title = title;
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        _lastCheckOut = [formatter dateFromString:lastCheckedOut];
    }
    return self;
}
@end
