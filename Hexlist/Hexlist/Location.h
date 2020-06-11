//
//  Location.h
//  Hexlist
//
//  Created by Roman Scher on 1/23/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import <Realm/Realm.h>
#import "Hex.h"

@interface Location : RLMObject

@property NSString *hexLocation;
@property RLMArray<Hex*><Hex> *hexes;

//Constructor
+(Location*)createLocationWithHexLocation:(HexLocationType)hexLocationType;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<Location>
RLM_ARRAY_TYPE(Location)
