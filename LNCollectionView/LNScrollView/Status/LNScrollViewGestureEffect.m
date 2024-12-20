//
//  LNScrollViewGestureEffect.m
//  LNCollectionView
//
//  Created by Levison on 9.11.24.
//

#import "LNScrollViewGestureEffect.h"
#import "LNScrollViewDragSimulator.h"

@implementation LNScrollViewGestureStatus
@end

@interface LNScrollViewGestureEffect ()

@property (nonatomic, strong) LNScrollViewGestureStatus *status;

@property (nonatomic, strong) LNScrollViewDragSimulator *horizontalDragSimulator;
@property (nonatomic, strong) LNScrollViewDragSimulator *verticalDragSimulator;

@end

@implementation LNScrollViewGestureEffect
- (void)startWithFrameSize:(CGSize)frameSize
               contentSize:(CGSize)contentSize
             currentOffset:(CGPoint)contentOffset
           gesturePosition:(CGPoint)gesturePosition {
    self.status = [[LNScrollViewGestureStatus alloc] init];
    self.status.gestureStartPosition = gesturePosition;
    self.status.startContentOffset = contentOffset;
    self.status.convertedOffset = CGPointZero;
    if (contentSize.height > frameSize.height) {
        self.verticalDragSimulator =
        [[LNScrollViewDragSimulator alloc] initWithLeadingPoint:0
                                                  trailingPoint:contentSize.height - frameSize.height
                                                     startPoint:contentOffset.y];
    }
    
    if (contentSize.width > frameSize.width) {
        self.horizontalDragSimulator =
        [[LNScrollViewDragSimulator alloc] initWithLeadingPoint:0
                                                  trailingPoint:contentSize.width - frameSize.width
                                                     startPoint:contentOffset.x];
    }
    
}

- (void)updateGestureLocation:(CGPoint)location
{
    BOOL didStatusChange = NO;
    if (self.horizontalDragSimulator) {
        CGFloat horizontalOffset = location.x - self.status.gestureStartPosition.x;
        [self.horizontalDragSimulator updateOffset:horizontalOffset];
        self.status.convertedOffset = CGPointMake(self.horizontalDragSimulator.getResultOffset, self.status.convertedOffset.y);
        didStatusChange = YES;
    }
    if (self.verticalDragSimulator) {
        CGFloat verticalOffset = location.y - self.status.gestureStartPosition.y;
        [self.verticalDragSimulator updateOffset:verticalOffset];
        self.status.convertedOffset = CGPointMake(self.status.convertedOffset.x, self.verticalDragSimulator.getResultOffset);
        didStatusChange = YES;
    }
    
    if (didStatusChange && self.delegate && [self.delegate respondsToSelector:@selector(gestureEffectStatusDidChange:)]) {
        [self.delegate gestureEffectStatusDidChange:self.status];
    }
}

- (void)finish {
    self.status = nil;
    self.horizontalDragSimulator = nil;
    self.verticalDragSimulator = nil;
}

@end
