//
//  LNScrollViewAutoEffect.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollViewAutoEffect.h"
#import "LNScrollViewBounceSimulator.h"
#import "LNScrollViewDecelerateSimulator.h"
#import <UIKit/UIKit.h>
#import "LNScrollViewClock.h"
#import "LNScrollViewPageSimulator.h"

@interface LNScrollViewRestStatus()
@property (nonatomic, assign) CGPoint leadingPoint;
@property (nonatomic, assign) CGPoint trailingPoint;
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint offset;

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, assign) CGPoint startPosition;
@end

@implementation LNScrollViewRestStatus
@end

@interface LNScrollViewAutoEffect() <LNScrollViewClockProtocol>

@property (nonatomic, strong) LNScrollViewBounceSimulator *horizontalBounceSimulator;
@property (nonatomic, strong) LNScrollViewBounceSimulator *verticalBounceSimulator;

@property (nonatomic, strong) LNScrollViewDecelerateSimulator *horizontalDecelerateSimulator;
@property (nonatomic, strong) LNScrollViewDecelerateSimulator *verticalDecelerateSimulator;

@property (nonatomic, strong) LNScrollViewPageSimulator *horizontalPageSimulator;
@property (nonatomic, strong) LNScrollViewPageSimulator *verticalPageSimulator;

@property (nonatomic, strong) LNScrollViewRestStatus *restStatus;

@end

@implementation LNScrollViewAutoEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageDamping = 20;
    }
    return self;
}

- (void)dealloc
{
}

- (BOOL)startWithContentSize:(CGSize)contentSize
                   frameSize:(CGSize)frameSize
                    velocity:(CGPoint)velocity
                    position:(CGPoint)position {
    [self finish];
    [LNScrollViewClock.shareInstance addObject:self];
    self.restStatus = [[LNScrollViewRestStatus alloc] init];
    self.restStatus.velocity = velocity;
    self.restStatus.contentSize = contentSize;
    self.restStatus.frameSize = frameSize;
    self.restStatus.startPosition = position;
    CGFloat leadingX = 0;
    CGFloat trailingX = contentSize.width - frameSize.width;
    CGFloat leadingY = 0;
    CGFloat trailingY = contentSize.height - frameSize.height;
    self.restStatus.leadingPoint = CGPointMake(leadingX, leadingY);
    self.restStatus.trailingPoint = CGPointMake(trailingX, trailingY);
    self.restStatus.offset = position;

    [self createHorizontalSimulatorIfNeeded];
    [self createVerticalSimulatorIfNeeded];
    return NO;
}

- (BOOL)updateHorizontalDecelerateSimulator:(NSTimeInterval)time
{
    if (self.horizontalDecelerateSimulator) {
        [self.horizontalDecelerateSimulator accumulate:time];
        self.restStatus.velocity = CGPointMake(self.horizontalDecelerateSimulator.velocity, self.restStatus.velocity.y);
        self.restStatus.offset = CGPointMake(self.horizontalDecelerateSimulator.position, self.restStatus.offset.y);
        if (self.restStatus.offset.x < self.restStatus.leadingPoint.x) {
            self.horizontalBounceSimulator =
            [[LNScrollViewBounceSimulator alloc] initWithPosition:self.horizontalDecelerateSimulator.position
                                                         velocity:self.horizontalDecelerateSimulator.velocity
                                                   targetPosition:self.restStatus.leadingPoint.x];
            self.horizontalDecelerateSimulator = nil;
        } else if (self.restStatus.offset.x > self.restStatus.trailingPoint.x) {
            self.horizontalBounceSimulator =
            [[LNScrollViewBounceSimulator alloc] initWithPosition:self.horizontalDecelerateSimulator.position
                                                         velocity:self.horizontalDecelerateSimulator.velocity
                                                   targetPosition:self.restStatus.trailingPoint.x];
            self.horizontalDecelerateSimulator = nil;
        } else if (self.horizontalDecelerateSimulator.isFinished) {
            self.horizontalDecelerateSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (BOOL)updateHorizontalBounceSimulator:(NSTimeInterval)time
{
    if (self.horizontalBounceSimulator) {
          [self.horizontalBounceSimulator accumulate:time];
          self.restStatus.velocity = CGPointMake(self.horizontalBounceSimulator.velocity, self.restStatus.velocity.y);
          self.restStatus.offset = CGPointMake(self.horizontalBounceSimulator.position, self.restStatus.offset.y);
          if (self.horizontalBounceSimulator.isFinished) {
              self.horizontalBounceSimulator = nil;
          }
        return YES;
    }
    return NO;
}

- (BOOL)updateHorizontalPageSimulator:(NSTimeInterval)time
{
    if (self.horizontalPageSimulator) {
          [self.horizontalPageSimulator accumulate:time];
          self.restStatus.velocity = CGPointMake(self.horizontalPageSimulator.velocity, self.restStatus.velocity.y);
          self.restStatus.offset = CGPointMake(self.horizontalPageSimulator.position, self.restStatus.offset.y);
          if (self.horizontalPageSimulator.isFinished) {
              self.horizontalPageSimulator = nil;
          }
        return YES;
    }
    return NO;
}

- (BOOL)updateVerticalDecelerateSimulator:(NSTimeInterval)time
{
    if (self.verticalDecelerateSimulator) {
        [self.verticalDecelerateSimulator accumulate:time];
        self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.verticalDecelerateSimulator.position);
        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, self.verticalDecelerateSimulator.velocity);
        if (self.restStatus.offset.y < self.restStatus.leadingPoint.y) {
            self.verticalBounceSimulator =
            [[LNScrollViewBounceSimulator alloc] initWithPosition:self.verticalDecelerateSimulator.position
                                                         velocity:self.verticalDecelerateSimulator.velocity
                                                   targetPosition:self.restStatus.leadingPoint.y];
            self.verticalDecelerateSimulator = nil;
        } else if (self.restStatus.offset.y > self.restStatus.trailingPoint.y) {
            self.verticalBounceSimulator =
            [[LNScrollViewBounceSimulator alloc] initWithPosition:self.verticalDecelerateSimulator.position
                                                         velocity:self.verticalDecelerateSimulator.velocity
                                                   targetPosition:self.restStatus.trailingPoint.y];
            self.verticalDecelerateSimulator = nil;
        } else if (self.verticalDecelerateSimulator.isFinished) {
            self.verticalDecelerateSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (BOOL)updateVerticalBounceSimulator:(NSTimeInterval)time
{
    if (self.verticalBounceSimulator) {
        [self.verticalBounceSimulator accumulate:time];
        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, self.verticalBounceSimulator.velocity);
        self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.verticalBounceSimulator.position);
        if (self.verticalBounceSimulator.isFinished) {
            self.verticalBounceSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (BOOL)updateVerticalPageSimulator:(NSTimeInterval)time
{
    if (self.verticalPageSimulator) {
        [self.verticalPageSimulator accumulate:time];
        self.restStatus.velocity = CGPointMake(self.restStatus.velocity.x, self.verticalPageSimulator.velocity);
        self.restStatus.offset = CGPointMake(self.restStatus.offset.x, self.verticalPageSimulator.position);
        if (self.verticalPageSimulator.isFinished) {
            self.verticalPageSimulator = nil;
        }
        return YES;
    }
    return NO;
}

- (void)scrollViewClockUpdateTimeInterval:(NSTimeInterval)time
{
    BOOL didStatusChange = NO;
    didStatusChange = [self updateVerticalDecelerateSimulator:time] || didStatusChange;
    didStatusChange = [self updateVerticalBounceSimulator:time] || didStatusChange;
    didStatusChange = [self updateVerticalPageSimulator:time] || didStatusChange;
    didStatusChange = [self updateHorizontalDecelerateSimulator:time] || didStatusChange;
    didStatusChange = [self updateHorizontalBounceSimulator:time] || didStatusChange;
    didStatusChange = [self updateHorizontalPageSimulator:time] || didStatusChange;
   
    if (didStatusChange && self.delegate && [self.delegate respondsToSelector:@selector(autoEffectStatusDidChange:)]) {
        [self.delegate autoEffectStatusDidChange:self.restStatus];
    }
    [self checkFinished];
}

- (void)checkFinished
{
    if ([self hasFinished]) {
        [self finish];
        if (self.delegate && [self.delegate respondsToSelector:@selector(autoEffectStatusHasFinished:)]) {
            [self.delegate autoEffectStatusHasFinished:self];
        }
    }
}

- (BOOL)hasFinished
{
    if (self.horizontalDecelerateSimulator &&
        !self.horizontalDecelerateSimulator.isFinished) {
        return NO;
    }
    if (self.horizontalBounceSimulator &&
        !self.horizontalBounceSimulator.isFinished) {
        return NO;
    }
    if (self.verticalDecelerateSimulator &&
        !self.verticalDecelerateSimulator.isFinished) {
        return NO;
    }
    if (self.verticalBounceSimulator &&
        !self.verticalBounceSimulator.isFinished) {
        return NO;
    }
    if (self.verticalPageSimulator &&
        !self.verticalPageSimulator.isFinished) {
        return NO;
    }
    if (self.horizontalPageSimulator &&
        !self.horizontalPageSimulator.isFinished) {
        return NO;
    }
    return YES;
}
- (void)finishForcely
{
    [self finish];
}

- (void)finish
{
    self.horizontalBounceSimulator = nil;
    self.horizontalDecelerateSimulator = nil;
    self.horizontalPageSimulator = nil;
    self.verticalBounceSimulator = nil;
    self.verticalDecelerateSimulator = nil;
    self.verticalPageSimulator = nil;
    self.restStatus = nil;
    [LNScrollViewClock.shareInstance removeObject:self];
}

- (BOOL)isFinished {
    return [self hasFinished];
}

- (void)createHorizontalBounceSimulator:(BOOL)isTrailing
{
    CGFloat targetPosition = isTrailing? self.restStatus.trailingPoint.x : self.restStatus.leadingPoint.x;
    self.horizontalBounceSimulator =
    [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.startPosition.x
                                                 velocity:self.restStatus.velocity.x
                                           targetPosition:targetPosition];
}

- (void)createHorizontalDecelerateSimulator
{
    LNScrollViewDecelerateSimulator *simulator = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(autoEffect:horizontalDecelerateWithPosition:velocity:)]) {
        simulator = [self.dataSource autoEffect:self horizontalDecelerateWithPosition:self.restStatus.startPosition.x velocity:self.restStatus.velocity.x];
    }
    if (simulator) {
        self.horizontalDecelerateSimulator = simulator;
    } else {
        self.horizontalDecelerateSimulator =
        [[LNScrollViewDecelerateSimulator alloc] initWithPosition:self.restStatus.startPosition.x
                                                         velocity:self.restStatus.velocity.x];
    }
}

- (void)createHorizontalPageSimulatorTo:(CGFloat)targetPosition
{
    self.horizontalPageSimulator =
    [[LNScrollViewPageSimulator alloc] initWithPosition:self.restStatus.startPosition.x
                                               velocity:self.restStatus.velocity.x
                                         targetPosition:targetPosition
                                                damping:self.pageDamping];
}

- (CGFloat)validPositionForHorizontalPage:(NSInteger)pageIndex
{
    CGFloat pageSize = self.restStatus.frameSize.width;
    CGFloat targetPosition = MAX(self.restStatus.leadingPoint.x, MIN(pageIndex * pageSize, self.restStatus.trailingPoint.x));
    return targetPosition;
}

- (void)createHorizontalPageSimulator
{
    CGFloat pageSize = self.restStatus.frameSize.width;
    NSInteger pageIndex = floor(self.restStatus.startPosition.x/pageSize);
    CGFloat restOffset = self.restStatus.startPosition.x - pageIndex * pageSize;
    if (restOffset < pageSize/2.f) {
        if (self.restStatus.velocity.x <= 0) {
            CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex];
            [self createHorizontalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.x
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset > pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex + 1];
                [self createHorizontalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex];
                [self createHorizontalPageSimulatorTo:targetPosition];
            }
        }
    } else {
        if (self.restStatus.velocity.x >= 0) {
            CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex + 1];
            [self createHorizontalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.x
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset < -pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex];
                [self createHorizontalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForHorizontalPage:pageIndex + 1];
                [self createHorizontalPageSimulatorTo:targetPosition];
            }
        }
    }
}


- (void)createVerticalBounceSimulator:(BOOL)isTrailing
{
    CGFloat targetPosition = isTrailing? self.restStatus.trailingPoint.y : self.restStatus.leadingPoint.y;
    self.verticalBounceSimulator = [[LNScrollViewBounceSimulator alloc] initWithPosition:self.restStatus.startPosition.y
                                                                              velocity:self.restStatus.velocity.y
                                                                        targetPosition:targetPosition];
}

- (void)createVerticalDecelerateSimulator
{
    LNScrollViewDecelerateSimulator *simulator = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(autoEffect:verticalDecelerateWithPosition:velocity:)]) {
        simulator = [self.dataSource autoEffect:self
                 verticalDecelerateWithPosition:self.restStatus.startPosition.y
                                       velocity:self.restStatus.velocity.y];
    }
    if (simulator) {
        self.verticalDecelerateSimulator = simulator;
    } else {
        self.verticalDecelerateSimulator =
        [[LNScrollViewDecelerateSimulator alloc] initWithPosition:self.restStatus.startPosition.y
                                                         velocity:self.restStatus.velocity.y];
    }
}

- (void)createVerticalPageSimulatorTo:(CGFloat)targetPosition
{
    self.verticalPageSimulator =
    [[LNScrollViewPageSimulator alloc] initWithPosition:self.restStatus.startPosition.y
                                               velocity:self.restStatus.velocity.y
                                         targetPosition:targetPosition
                                                damping:self.pageDamping];
}


- (CGFloat)validPositionForVerticalPage:(NSInteger)pageIndex
{
    CGFloat pageSize = self.restStatus.frameSize.height;
    CGFloat targetPosition = MAX(self.restStatus.leadingPoint.y, MIN(pageIndex *pageSize, self.restStatus.trailingPoint.y));
    return targetPosition;
}

- (void)createVerticalPageSimulator
{
    CGFloat pageSize = self.restStatus.frameSize.height;
    NSInteger pageIndex = floor(self.restStatus.startPosition.y/pageSize);
    CGFloat restOffset = self.restStatus.startPosition.y - pageIndex * pageSize;
    if (restOffset < pageSize/2.f) {
        if (self.restStatus.velocity.y <= 0) {
            CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex];
            [self createVerticalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.y
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset > pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex + 1];
                [self createVerticalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex];
                [self createVerticalPageSimulatorTo:targetPosition];
            }
        }
    } else {
        if (self.restStatus.velocity.y >= 0) {
            CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex + 1];
            [self createVerticalPageSimulatorTo:targetPosition];
        } else {
            CGFloat targetOffset =
            [LNScrollViewPageSimulator targetOffsetWithVelocity:self.restStatus.velocity.y
                                                         offset:restOffset
                                                        damping:self.pageDamping];
            if (targetOffset < -pageSize/2.f) {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex];
                [self createVerticalPageSimulatorTo:targetPosition];
            } else {
                CGFloat targetPosition = [self validPositionForVerticalPage:pageIndex + 1];
                [self createVerticalPageSimulatorTo:targetPosition];
            }
        }
    }
}

- (void)createHorizontalSimulatorIfNeeded
{
    if (self.restStatus.contentSize.width > self.restStatus.frameSize.width) {
        if (self.restStatus.startPosition.x < self.restStatus.leadingPoint.x) {
            [self createHorizontalBounceSimulator:NO];
        } else if (self.restStatus.startPosition.x > self.restStatus.trailingPoint.x) {
            [self createHorizontalBounceSimulator:YES];
        } else {
            if (self.pageEnable) {
                [self createHorizontalPageSimulator];
            } else {
                [self createHorizontalDecelerateSimulator];
            }
        }
    }
}

- (void)createVerticalSimulatorIfNeeded
{
    if (self.restStatus.contentSize.height > self.restStatus.frameSize.height) {
        if (self.restStatus.startPosition.y < self.restStatus.leadingPoint.y) {
            [self createVerticalBounceSimulator:NO];
        } else if (self.restStatus.startPosition.y > self.restStatus.trailingPoint.y) {
            [self createVerticalBounceSimulator:YES];
        } else {
            if (self.pageEnable) {
                [self createVerticalPageSimulator];
            } else {
                [self createVerticalDecelerateSimulator];
            }
        }
    }
}

@end
