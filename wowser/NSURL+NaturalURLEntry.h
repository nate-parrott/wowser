//
//  NSURL+NaturalURLEntry.h
//  wowser
//
//  Created by Nate Parrott on 4/16/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (NaturalURLEntry)

+ (NSURL *)withNaturalString:(NSString *)string;
+ (NSURL *)searchEngineURLForString:(NSString *)query;

- (NSString *)absoluteStringForDisplay;

@end
