//
//  Book.h
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/20/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSDate *lastCheckOut;
@property (nonatomic, strong) NSString *lastCheckOutBy;
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property int bookid;
-(instancetype)initWithAuthor:(NSString*) author
                   categories:(NSString*) categories
                       bookid:(int) bookid
               lastCheckedOut:(NSString*) lastCheckedOut
             lastCheckedOutBy:(NSString*) lastCheckedOutBy
                    publisher:(NSString*) publisher
                        title:(NSString*) title
                          url:(NSString*) url;
@end
