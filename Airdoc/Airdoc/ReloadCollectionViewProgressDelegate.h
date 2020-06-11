//
//  ReloadCollectionViewProgressDelegate.h
//  Airdoc
//
//  Created by Yvan Scher on 6/2/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#ifndef Airdoc_ReloadCollectionViewProgressDelegate_h
#define Airdoc_ReloadCollectionViewProgressDelegate_h

@protocol ReloadCollectionViewProgressDelegate <NSObject>

-(void) reloadCollectionViewFilePath:(NSString*)destinationPath withProgress:(CGFloat)percentDownloaded withReduceStack:(NSString*)reducedStack;

@end


#endif
