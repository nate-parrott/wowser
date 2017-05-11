//
//  NSURL+NaturalURLEntry.m
//  wowser
//
//  Created by Nate Parrott on 4/16/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "NSURL+NaturalURLEntry.h"

@implementation NSURL (NaturalURLEntry)

+ (NSURL *)withNaturalString:(NSString *)string {
    if ([string rangeOfString:@" "].location == NSNotFound) {
        if ([string rangeOfString:@"."].location == NSNotFound) {
            return [self searchEngineURLForString:string];
        } else {
            NSURL *parsed = [NSURL URLWithString:string];
            if (parsed && parsed.scheme.length > 0) {
                return parsed;
            } else {
                NSURL *parsed2 = [NSURL URLWithString:[@"http://" stringByAppendingString:string]];
                if (parsed2) {
                    return parsed2;
                } else {
                    return [self searchEngineURLForString:string];
                }
            }
        }
    } else {
        return [self searchEngineURLForString:string];
    }
}

+ (NSURL *)searchEngineURLForString:(NSString *)query {
    NSURLComponents *comps = [NSURLComponents componentsWithString:@"https://google.com/search"];
    comps.queryItems = @[[NSURLQueryItem queryItemWithName:@"q" value:query]];
    return comps.URL;
}

- (NSString *)absoluteStringForDisplay {
    NSMutableString *str = self.absoluteString.mutableCopy;
    for (NSString *prefix in @[@"https://", @"http://", @"www."]) {
        if ([str hasPrefix:prefix] ) {
            [str replaceCharactersInRange:NSMakeRange(0, prefix.length) withString:@""];
        }
    }
    return str;
}

@end
