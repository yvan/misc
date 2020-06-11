//
//  HexCell.m
//  Hexlist
//
//  Created by Roman Scher on 1/20/16.
//  Copyright © 2016 Yvan Scher. All rights reserved.
//

#import "HexCell.h"

#define LINKS_SECTION 0

@implementation HexCell

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    _lefthandButton.layer.cornerRadius = 5;
    _righthandButton.layer.cornerRadius = 5;
    _containerView.layer.cornerRadius = 5;
    
    //Button Colors
    [_lefthandButton setExclusiveTouch:YES];
    [_righthandButton setExclusiveTouch:YES];
    
    //Hide expansion space views
    _linksView.alpha = 0.0;
    _actionsView.alpha = 0.0;
    
    //HexCellTri
    [_middleButton setExclusiveTouch:YES];
    
    //----TableView setup----
    [_linksTableView registerNib:[UINib nibWithNibName:@"LinkCell" bundle:nil] forCellReuseIdentifier:[AppConstants linkCellStringIdentifier]];
    
    [_linksTableView setDelegate:self];
    [_linksTableView setDataSource:self];
    //Remove separator
    [_linksTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _linksTableView.delaysContentTouches = NO;
    for (UIView *currentView in _linksTableView.subviews) {
        if([currentView isKindOfClass:[UIScrollView class]]){
            ((UIScrollView *)currentView).delaysContentTouches = NO;
            break;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    //NSLog(@"num links in section: %lu", (unsigned long)[_staticLinksArray count]);
    return [_staticLinksArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //HexCell
//    //NSLog(@"linkCell for row at indexpath");
    return [self generateLinkCellForTableView:tableView AndIndexPath:indexPath];
}

/* - Convenience method to generate a hexCell for an indexPath- */
-(LinkCell *)generateLinkCellForTableView:(UITableView *)tableView
                           AndIndexPath:(NSIndexPath *)indexPath {
    
    LinkCell *linkCell = [tableView dequeueReusableCellWithIdentifier:[AppConstants linkCellStringIdentifier] forIndexPath:indexPath];
    linkCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Configuring the views and colors for swipe to accept and swipe to delete.
    UIView *globeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[AppConstants globeImageStringIdentifier]]];
    UIColor *blueColor = [UIColor colorWithRed:52.0 / 255.0 green:152.0 / 255.0 blue:219.0 / 255.0 alpha:1.0];
    UIView *crossView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[AppConstants trashWhiteImageStringIdentifier]]];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    // Setting the default inactive state color to the tableView background color.
    [linkCell setDefaultColor:[AppConstants tableViewSelectionColor]];
    
    __weak LinkCell *weakLinkCell = linkCell;
    
    // Adding gestures per state basis.
    [linkCell setSwipeGestureWithView:globeView color:blueColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        [self openLinkButtonPress:weakLinkCell];
    }];
    linkCell.firstTrigger = .24;
    
    if (_hexCellType == HexCellTypeMyHexlist) {
        [linkCell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            [self deleteLinkButtonPress:weakLinkCell];
        }];
        linkCell.secondTrigger = .24;
    }
    else {
        [linkCell setSwipeGestureWithView:[[UIImageView alloc] init]  color:[AppConstants tableViewSelectionColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {}];
        linkCell.secondTrigger = .24;
    }
    
    if (indexPath.row == 0) {
        [linkCell.topBorder setHidden:YES];
    }
    else {
        [linkCell.topBorder setHidden:NO];
    }
    
    Link *link = [_staticLinksArray objectAtIndex:indexPath.row];
    
    linkCell.link = link;
    [linkCell.linkLabel setText:link.linkDescription];
    
    [linkCell.serviceImageButton setImage:[AppConstants serviceLinkImageForServiceType:[AppConstants serviceTypeForString:link.service]] forState:UIControlStateNormal];
    
    return linkCell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self class] linkHeight];
}

/* - Sets styling for section headers - */

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    // Background color
    view.tintColor = [UIColor clearColor];
}

/* - Specifically sets the line seperator insets of cells, seperate from Sections - */

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

/* - Used to set selection of file package - */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LinkCell *linkCell = (LinkCell*)[_linksTableView cellForRowAtIndexPath:indexPath];
   
    linkCell.backgroundColor = [AppConstants tableViewSelectionColor];
    [UIView animateWithDuration:.5 animations:^{
        linkCell.backgroundColor = [UIColor whiteColor];
    }];
   
    id<HexCellDelegate> strongDelegate = self.hexCellDelegate;
    
    if ([strongDelegate respondsToSelector:@selector(linkButtonPressedWithLink:)]) {
        [strongDelegate linkButtonPressedWithLink:linkCell.link];
    }
}

#pragma mark - Reordering

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_staticLinksArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
        //Update separator lines depending on if top/bottom
        if (sourceIndexPath.row == 0) {
            LinkCell *linkCellSource = ((LinkCell*)[_linksTableView cellForRowAtIndexPath:sourceIndexPath]);
            [linkCellSource.topBorder setHidden:YES];
        }
        else if (destinationIndexPath.row == 0) {
            LinkCell *linkCellSource = ((LinkCell*)[_linksTableView cellForRowAtIndexPath:sourceIndexPath]);
            [linkCellSource.topBorder setHidden:NO];
        }
    });
}

-(void)tableView:(UITableView *)tableView didBeginReorderingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _linksTableView.allowsSelection = NO;
    if ([_hexCellDelegate respondsToSelector:@selector(startedReorderingLinks)]) {
        [_hexCellDelegate startedReorderingLinks];
    }
}

-(void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath {
    _linksTableView.allowsSelection = YES;
    if ([_hexCellDelegate respondsToSelector:@selector(finishedReorderingLinks)]) {
        [_hexCellDelegate finishedReorderingLinks];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Link *linkToReorder = [_staticLinksArray objectAtIndex:indexPath.row];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        [realm beginWriteTransaction];
        [_hex.links moveObjectAtIndex:[_hex.links indexOfObject:linkToReorder] toIndex:indexPath.row];
        [realm commitWriteTransaction];
    });
}

#pragma mark - Actions

-(void)openLinkButtonPress:(id)sender {
    LinkCell *linkCell = (LinkCell*)sender;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[linkCell.link.url
    stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

-(void)deleteLinkButtonPress:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        LinkCell *linkCell = (LinkCell*)sender;
        NSIndexPath *indexPath = [_linksTableView indexPathForRowAtPoint:linkCell.center];
        Link *link = [_staticLinksArray objectAtIndex:indexPath.row];
        
        [_staticLinksArray removeObject:link];
        
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                     [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section],
                                     nil];
        
        [_linksTableView beginUpdates];
        [_linksTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [_linksTableView endUpdates];
        
        id<HexCellDelegate> strongDelegate = self.hexCellDelegate;
        
        if ([strongDelegate respondsToSelector:@selector(deleteLink:FromHex:)]) {
            [strongDelegate deleteLink:link FromHex:_hex];
        }
    });
}

#pragma mark - Helper Methods

-(void)updateLinksResetOffset:(BOOL)resetOffset {
    dispatch_async(dispatch_get_main_queue(), ^{
        _staticLinksArray = [self getStaticLinksArray:_hex.links];
        if (resetOffset) {
            [_linksTableView setContentOffset:CGPointZero animated:NO];
        }
        [_linksTableView reloadData];
    });
}

-(void)updateLinksAnimated {
    dispatch_async(dispatch_get_main_queue(), ^{
        //Update Hexes
        NSArray *oldLinksArray = [[NSArray alloc] initWithArray:_staticLinksArray copyItems:NO];
        _staticLinksArray = [self getStaticLinksArray:_hex.links];
        NSInteger linksCountBefore = [oldLinksArray count];
        NSInteger linksCountNow = [_staticLinksArray count];
        NSInteger numNewLinks = linksCountNow - linksCountBefore;
        
        //NSLog(@"Num new links: %ld", (long)numNewLinks);
        
        //If there is indeed a new hex, do the insert.
        if (numNewLinks > 0) {
            
            NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
            
            //Find indexes of objects that were inserted
            NSSet *oldLinksSet = [NSSet setWithArray:oldLinksArray];
            NSIndexSet *matchingIndexes = [_staticLinksArray indexesOfObjectsPassingTest:^BOOL(Link *link, NSUInteger idx, BOOL *stop) {
                return ![oldLinksSet containsObject:link];
            }];
            
            [matchingIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:LINKS_SECTION]];
            }];
            
            //Perform all deletion and insertion updates at once
            [_linksTableView beginUpdates];
            [_linksTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_linksTableView endUpdates];
            [_linksTableView scrollToRowAtIndexPath:(NSIndexPath*)[insertIndexPaths firstObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        else if (numNewLinks < 0) {
            NSMutableArray *deleteIndexPaths = [[NSMutableArray alloc] init];
            
            NSIndexSet *matchingIndexes = [oldLinksArray indexesOfObjectsPassingTest:^BOOL(Link *link, NSUInteger idx, BOOL *stop) {
                return link.invalidated;
            }];
            
            [matchingIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:idx inSection:LINKS_SECTION]];
            }];
            
            [_linksTableView beginUpdates];
            [_linksTableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [_linksTableView endUpdates];
        }
    });
}

-(NSMutableArray*)getStaticLinksArray:(RLMArray*)links {
    NSMutableArray *staticLinksArray = [[NSMutableArray alloc] init];
    for (Link *link in links) {
        [staticLinksArray addObject:link];
    }
    
    return staticLinksArray;
}
    
#pragma mark - Helper methods
    
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-10.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

+(NSInteger)verticalMargin {
    return 3;
}

+(NSInteger)horizontalMargin {
    return 9;
}

+(NSInteger)cellHeightUnexpanded {
    return [self mainViewHeight] + (2 * [self verticalMargin]);
}

+(NSInteger)cellHeightExpandedStaticPortion {
    return [self mainViewHeight] + [self actionsViewHeight] + (2 * [self verticalMargin]);
}

+(NSInteger)mainViewHeight {
    return 54;
}

+(NSInteger)linkHeight {
    return 45;
}

+(NSInteger)actionsViewHeight {
    return 45;
}

@end
