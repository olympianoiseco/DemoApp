//
//  ONCTouchView.m
//  My Awesome Music App
//
//  Created by Benjamin Kamen on 11/7/17.
//  Copyright © 2017 Olympia Noise Co. All rights reserved.
//

#import "ONCTouchView.h"

@interface ONCTouchView () {
    NSMutableArray <UITouch *> * _currentTouches;
    NSMutableArray <NSNumber *> * _currentNotes;
    NSMutableArray <CALayer *> * _currentLayers;
}
@end


@implementation ONCTouchView


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        [self addTouch:obj];
    }];
    [self updateTouches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateTouches];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTouch:obj];
    }];
    [self updateTouches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        [self removeTouch:obj];
    }];
    [self updateTouches];
}

- (void)addTouch:(UITouch *)touch {
    
    if (!_currentTouches) {
        _currentTouches = [[NSMutableArray alloc] init];
    }
    
    [_currentTouches addObject:touch];
    
}

- (NSNumber *)noteForTouch:(UITouch *)touch {
    
    NSArray * possibleNotes = @[@60, @64, @67, @69, @71, @72, @74, @76];
    
    CGPoint point = [touch locationInView:self];
    CGFloat x = point.x;
    
    CGFloat xPercent = x / self.bounds.size.width;
    
    CGFloat index = xPercent * possibleNotes.count;
    
    return possibleNotes[(NSInteger)index];
    
}

- (void)updateTouches {
 
    _currentNotes = nil;
    _currentNotes = [[NSMutableArray alloc] init];
    
    [_currentTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_currentNotes addObject:[self noteForTouch:obj]];
    }];
    
    NSLog(@"%@", _currentNotes);
    
}

- (void)removeTouch:(UITouch *)touch {
    
    [_currentTouches removeObject:touch];
    
}


- (NSArray *)currentNotes {
    return _currentNotes;
}





@end
