
//
//  HPReorderTableViewCustom.m
//
//  Created by Hermes Pique on 22/01/14.
//  Copyright (c) 2014 Hermes Pique
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "HPReorderTableViewCustom.h"

@interface HPReorderTableViewCustom(Subclassing)

@property (nonatomic, readonly) id<UITableViewDataSource> hp_realDataSource;

@end

@interface HPReorderTableViewCustom()<UITableViewDataSource>

@end

@implementation HPReorderTableViewCustom {
    UIImageView *_reorderDragView;
    __weak id<UITableViewDataSource> _realDataSource;
    NSIndexPath *_reorderInitialIndexPath;
    NSIndexPath *_reorderCurrentIndexPath;
    CADisplayLink *_scrollDisplayLink;
    CGFloat _scrollRate;
    CGFloat _reorderDragViewShadowOpacity;
}

@dynamic delegate;

static NSTimeInterval HPReorderTableViewAnimationDuration = 0.2;

static NSString *HPReorderTableViewCellReuseIdentifier = @"HPReorderTableViewCellReuseIdentifier";

@synthesize reorderDragView = _reorderDragView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initHelper];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
    _reorderGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeLongPressGestureRecognizer:)];
    _reorderGestureRecognizer.minimumPressDuration = .25; //Seconds
    [self addGestureRecognizer:_reorderGestureRecognizer];
    
    _reorderDragView = [[UIImageView alloc] init];
    
    // Data Source forwarding
    [super setDataSource:self];
    [self registerTemporaryEmptyCellClass:[UITableViewCell class]];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - NSNotificationCenter

-(void)applicationDidEnterBackground {
    [self didEndLongPressGestureRecognizer:self.reorderGestureRecognizer];
}

#pragma mark - Public

- (void)registerTemporaryEmptyCellClass:(Class)cellClass
{
    [self registerClass:cellClass forCellReuseIdentifier:HPReorderTableViewCellReuseIdentifier];
}

#pragma mark - Actions

- (void)recognizeLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (![self hasRows])
    {
        HPGestureRecognizerCancel(gestureRecognizer);
        return;
    }
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self didBeginLongPressGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self didChangeLongPressGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self didEndLongPressGestureRecognizer:gestureRecognizer];
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_reorderCurrentIndexPath && [_reorderCurrentIndexPath compare:indexPath] == NSOrderedSame)
    {
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:HPReorderTableViewCellReuseIdentifier];
        cell.layer.zPosition = -10;
        cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else
    {
        return [_realDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_realDataSource tableView:self numberOfRowsInSection:section];
}

#pragma mark - Data Source Forwarding

- (void)dealloc
{ // Data Source forwarding
    self.delegate = nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([_realDataSource respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:_realDataSource];
    }
    else
    {
        [super forwardInvocation:invocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)s
{
    return [super methodSignatureForSelector:s] ?: [(id)_realDataSource methodSignatureForSelector:s];
}

- (BOOL)respondsToSelector:(SEL)s
{
    return [super respondsToSelector:s] || [_realDataSource respondsToSelector:s];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource
{ // Data Source forwarding
    [super setDataSource:dataSource ? self : nil];
    _realDataSource = dataSource != self ? dataSource : nil;
}

#pragma mark - Utils

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
    return ![self.dataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] || [self.dataSource tableView:self canMoveRowAtIndexPath:indexPath];
}

- (BOOL)hasRows
{
    NSInteger sectionCount = [self numberOfSections];
    for (NSInteger i = 0; i < sectionCount; i++)
    {
        if ([self numberOfRowsInSection:i] > 0) return YES;
    }
    return NO;
}

static UIImage* HPImageFromView(UIView *view)
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    // Add a clip before drawing anything, in the shape of an rounded rect
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:view.bounds
                                cornerRadius:view.layer.cornerRadius + 1] addClip];
    // Draw your image
    [image drawInRect:view.bounds];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    return image;
}

static void HPGestureRecognizerCancel(UIGestureRecognizer *gestureRecognizer)
{ // See: http://stackoverflow.com/a/4167471/143378
    gestureRecognizer.enabled = NO;
    gestureRecognizer.enabled = YES;
}

#pragma mark - Private

- (void)animateShadowOpacityFromValue:(CGFloat)fromValue toValue:(CGFloat)toValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(shadowOpacity))];
    animation.fromValue = [NSNumber numberWithFloat:fromValue];
    animation.toValue = [NSNumber numberWithFloat:toValue];
    animation.duration = HPReorderTableViewAnimationDuration;
    [_reorderDragView.layer addAnimation:animation forKey:NSStringFromSelector(@selector(shadowOpacity))];
    _reorderDragViewShadowOpacity = _reorderDragView.layer.shadowOpacity;
    _reorderDragView.layer.shadowOpacity = toValue;
}

- (void)didBeginLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const CGPoint location = [gestureRecognizer locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    if (indexPath == nil || ![self canMoveRowAtIndexPath:indexPath])
    {
        HPGestureRecognizerCancel(gestureRecognizer);
        return;
    }
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:NO];
    [cell setHighlighted:NO animated:NO];
    
    UIView *cellSnapshot = ((HexCell*)cell).containerView;
    UIImage *image = HPImageFromView(cellSnapshot);
    _reorderDragView.layer.masksToBounds = NO;
    _reorderDragView.image = image;
    
    _reorderDragView.layer.shadowColor = cellSnapshot.layer.shadowColor;
    _reorderDragView.layer.shadowRadius = cellSnapshot.layer.shadowRadius;
    _reorderDragView.layer.shadowOpacity = cellSnapshot.layer.shadowOpacity;
    _reorderDragView.layer.shadowOffset = cellSnapshot.layer.shadowOffset;
    
    CGRect cellRect = [self rectForRowAtIndexPath:indexPath];
    _reorderDragView.frame = CGRectOffset(CGRectMake([HexCell horizontalMargin], [HexCell verticalMargin], image.size.width, image.size.height), cellRect.origin.x, cellRect.origin.y);
    [self addSubview:_reorderDragView];
    if (_reorderDragView.layer.shadowOpacity == 0)
    {
        _reorderDragView.layer.shadowOpacity = _reorderDragViewShadowOpacity;
    }
    
    _reorderInitialIndexPath = indexPath;
    _reorderCurrentIndexPath = indexPath;
    
    [self animateShadowOpacityFromValue:0 toValue:_reorderDragView.layer.shadowOpacity];
    [UIView animateWithDuration:HPReorderTableViewAnimationDuration animations:^{
        _reorderDragView.center = CGPointMake(location.x, location.y);
    }];
    
    [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    _scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scrollTableWithCell:)];
    [_scrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([self.delegate respondsToSelector:@selector(tableView: didBeginReorderingRowAtIndexPath:)]) {
        [self.delegate tableView:self didBeginReorderingRowAtIndexPath:indexPath];
    }
}

- (void)didEndLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    if (!_reorderCurrentIndexPath)
    {
        HPGestureRecognizerCancel(gestureRecognizer);
        return;
    }
    
    NSIndexPath *indexPath = _reorderCurrentIndexPath;
    
    { // Reset
        [_scrollDisplayLink invalidate];
        _scrollDisplayLink = nil;
        _scrollRate = 0;
        _reorderCurrentIndexPath = nil;
        _reorderInitialIndexPath = nil;
    }
    
    [self animateShadowOpacityFromValue:_reorderDragView.layer.shadowOpacity toValue:0];
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    
    [UIView animateWithDuration:HPReorderTableViewAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _reorderDragView.frame = CGRectOffset(CGRectMake([HexCell horizontalMargin], [HexCell verticalMargin], _reorderDragView.bounds.size.width, _reorderDragView.bounds.size.height), cell.frame.origin.x, cell.frame.origin.y);
                     }completion:^(BOOL finished) {
                         [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                         [self performSelector:@selector(removeReorderDragView) withObject:nil afterDelay:0]; // Prevent flicker
                         if ([self.delegate respondsToSelector:@selector(tableView: didEndReorderingRowAtIndexPath:)]) {
                             [self.delegate tableView:self didEndReorderingRowAtIndexPath:indexPath];
                         }
                     }];
}

- (void)removeReorderDragView
{
    [_reorderDragView removeFromSuperview];
}

- (void)reorderCurrentRowToIndexPath:(NSIndexPath*)toIndexPath
{
    [self beginUpdates];
    [self moveRowAtIndexPath:_reorderCurrentIndexPath toIndexPath:toIndexPath];
    if ([self.dataSource respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
    {
        [self.dataSource tableView:self moveRowAtIndexPath:_reorderCurrentIndexPath toIndexPath:toIndexPath];
    }
    _reorderCurrentIndexPath = toIndexPath;
    [self endUpdates];
}

#pragma mark Subclassing

- (id<UITableViewDataSource>)hp_realDataSource
{
    return _realDataSource;
}

#pragma mark After BVReorderTableView
// Taken from https://github.com/bvogelzang/BVReorderTableView/blob/master/BVReorderTableView.m with minor modifications
//
//  BVReorderTableView.m
//
//  Copyright (c) 2013 Ben Vogelzang.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

- (void)didChangeLongPressGestureRecognizer:(UILongPressGestureRecognizer*)gestureRecognizer
{
    const CGPoint location = [gestureRecognizer locationInView:self];
    
    _reorderDragView.center = CGPointMake(location.x, location.y);
    
    CGRect rect = self.bounds;
    // adjust rect for content inset as we will use it below for calculating scroll zones
    rect.size.height -= self.contentInset.top;
    
    [self updateCurrentLocation:gestureRecognizer];

    // tell us if we should scroll and which direction
    CGFloat scrollZoneHeight = rect.size.height / 6;
    CGFloat bottomScrollBeginning = self.contentOffset.y + self.contentInset.top + rect.size.height - scrollZoneHeight;
    CGFloat topScrollBeginning = self.contentOffset.y + self.contentInset.top  + scrollZoneHeight;

    //Limits scroll speed
//    CGFloat stopZoneBottom = self.contentOffset.y + self.contentInset.top + rect.size.height;
//    CGFloat stopZoneTop = self.contentOffset.y + self.contentInset.top;
//
//    //End reorder prematurely if user drags cell outside of tableview
//    if (location.y > stopZoneBottom || location.y < stopZoneTop) {
//        [self didEndLongPressGestureRecognizer:_reorderGestureRecognizer];
//        HPGestureRecognizerCancel(gestureRecognizer);
//        return;
//    }
    
    // we're in the bottom zone
    if (location.y >= bottomScrollBeginning)
    {
//        if (location.y <= stopZoneBottom) {
            _scrollRate = (location.y - bottomScrollBeginning) / scrollZoneHeight;
//        }
//        else {
//            _scrollRate = (stopZoneBottom - 70 - bottomScrollBeginning) / scrollZoneHeight;
//        }
    }
    // we're in the top zone
    else if (location.y <= topScrollBeginning)
    {
//        if (location.y >= stopZoneTop) {
           _scrollRate = (location.y - topScrollBeginning) / scrollZoneHeight;
//        }
//        else {
//            _scrollRate = (stopZoneTop + 70 - topScrollBeginning)/ scrollZoneHeight;
//        }
    }
    else
    {
        _scrollRate = 0;
    }
}

- (void)scrollTableWithCell:(NSTimer *)timer
{
    UILongPressGestureRecognizer *gesture = self.reorderGestureRecognizer;
    const CGPoint location = [gesture locationInView:self];
    
    CGPoint currentOffset = self.contentOffset;
    CGPoint newOffset = CGPointMake(currentOffset.x, currentOffset.y + _scrollRate * 10);
    
    if (newOffset.y < -self.contentInset.top)
    {
        newOffset.y = -self.contentInset.top;
    }
    else if (self.contentSize.height + self.contentInset.bottom < self.frame.size.height)
    {
        newOffset = currentOffset;
    }
    else if (newOffset.y > (self.contentSize.height + self.contentInset.bottom) - self.frame.size.height)
    {
        newOffset.y = (self.contentSize.height + self.contentInset.bottom) - self.frame.size.height;
    }
    
    [self setContentOffset:newOffset];
    
    if (location.y >= 0 && location.y <= self.contentSize.height + 50)
    {
        _reorderDragView.center = CGPointMake(location.x, location.y);
    }
    
    [self updateCurrentLocation:gesture];
}

- (void)updateCurrentLocation:(UILongPressGestureRecognizer *)gesture
{
    CGPoint location  = [gesture locationInView:self];
//    CGPoint originalLocation = location;
    
    CGRect rect = self.bounds;
    rect.size.height -= self.contentInset.top;
    CGFloat stopZoneBottom = self.contentOffset.y + self.contentInset.top + rect.size.height;
    CGFloat stopZoneTop = self.contentOffset.y + self.contentInset.top;
    
    //STOPS VISUAL BUG WHERE ALL CELLS BECOME CELL WE ARE REORDERING WHEN WE DRAG PAST TABLEVIEW
    if (location.y > stopZoneBottom) {
//        //NSLog(@"Stop zone bottom reached");
        location = CGPointMake(location.x, stopZoneBottom - 10);
    }
    else if (location.y < stopZoneTop) {
//        //NSLog(@"Stop zone Location.y: %f", location.y);
        location = CGPointMake(location.x, stopZoneTop + 10);
    }
    
    NSIndexPath *toIndexPath = [self indexPathForRowAtPoint:location];
    
//    if (originalLocation.y < stopZoneTop) {
//        //NSLog(@"Above stop zone index path: %@", toIndexPath);
//    }
    
    if ([self.delegate respondsToSelector:@selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
    {
        toIndexPath = [self.delegate tableView:self targetIndexPathForMoveFromRowAtIndexPath:_reorderInitialIndexPath toProposedIndexPath:toIndexPath];
    }
    
    if ([toIndexPath compare:_reorderCurrentIndexPath] == NSOrderedSame) return;
    
    //KEEP RETURN COMMENTED OUT TO FIX BUG WITH CELL NOT REORGANIZING WHEN DRAGGED UPWARDS OFF SCREEN (WHO KNOWS, MAYBE IT JUST TAKES LONGER...?)
    NSInteger originalHeight = _reorderDragView.frame.size.height;
    NSInteger toHeight = [self rectForRowAtIndexPath:toIndexPath].size.height;
    UITableViewCell *toCell = [self cellForRowAtIndexPath:toIndexPath];
    const CGPoint toCellLocation = [gesture locationInView:toCell];
    
    if (toCellLocation.y <= toHeight - originalHeight) {
        //NSLog(@"Check return");
//        return;
    }
//    //NSLog(@"ReorderingCurrentRowToIndexPath");
    
    [self reorderCurrentRowToIndexPath:toIndexPath];
}

@end

@implementation HPReorderAndSwipeToDeleteTableViewCustom

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.hp_realDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
    {
        return [self.hp_realDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end
