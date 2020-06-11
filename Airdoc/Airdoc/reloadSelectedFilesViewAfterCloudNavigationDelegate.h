//
//  reloadSelectedFilesViewAfterCloudNavigationDelegate.h
//  Envoy
//
//  Created by Yvan Scher on 7/26/15.
//  Copyright (c) 2015 Yvan Scher. All rights reserved.
//

#ifndef Envoy_reloadSelectedFilesViewAfterCloudNavigationDelegate_h
#define Envoy_reloadSelectedFilesViewAfterCloudNavigationDelegate_h

@protocol CloudNavigationPopulateDelegate <NSObject>

-(void)populateWithFilesToDisplay:(NSMutableArray*)filesToDisplay withPassed:(File*)file;

@end

#endif
