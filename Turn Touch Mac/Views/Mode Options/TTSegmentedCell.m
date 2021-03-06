//
//  TTSegmentedCell.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 6/16/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTSegmentedCell.h"

@interface TTSegmentedCell ()

@property (nonatomic, strong) NSDictionary *labelAttributes;
@property (nonatomic) CGFloat radius;

@end

@implementation TTSegmentedCell

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {

    }
    return self;
}

- (void)awakeFromNib {
    [self setHighlightedSegment:-1];
}

#pragma mark - Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    self.radius = NSHeight(cellFrame) * 2.f/3.f;
    cellFrame.size.width = [self totalWidthInFrame:cellFrame withRadius:self.radius upToSegment:self.segmentCount];
    for (int i =0 ;i < [self segmentCount]; i++) {
        [self setupLabels:i];
        [self drawSegment:i inFrame:cellFrame withView:controlView];
    }
//     NSLog(@"%ld segments: total=%4.f, frame width=%@", (long)self.segmentCount, [self totalWidthInFrame:cellFrame withRadius:radius upToSegment:self.segmentCount], NSStringFromRect(cellFrame));
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView {
    NSBezierPath *border = [NSBezierPath bezierPath];
    NSString *label = [self labelForSegment:segment];
    NSSize labelSize = [label sizeWithAttributes:self.labelAttributes];
    self.radius = NSHeight(frame) * 2.f/3.f;
    CGFloat totalWidth = [self totalWidthInFrame:frame withRadius:self.radius upToSegment:self.segmentCount];
    CGFloat overageWidth = (totalWidth - NSWidth(frame)) / self.segmentCount;
//    NSLog(@"Drawing segment %ld: total: %f, overage: %f (%@)", (long)segment, totalWidth, overageWidth, NSStringFromRect(frame));
    BOOL highlighted = segment == self.highlightedSegment;
    BOOL selected = [self isSelectedForSegment:segment];
    
    CGFloat offset = [self totalWidthInFrame:frame withRadius:self.radius upToSegment:segment];
    NSRect segmentFrame = frame;
    segmentFrame.origin.x = offset;
    segmentFrame.origin.y = NSMinY(frame) + 3;
    segmentFrame.size.width = labelSize.width + 2*self.radius - overageWidth;
    segmentFrame.size.height = NSHeight(frame) - 4;
    
    // Stroke
    [border moveToPoint:NSMakePoint(NSMinX(segmentFrame) + self.radius, NSMinY(segmentFrame))];
    // Right-mode segment has rounded rect on right
    if (segment < self.segmentCount-1) {
        [border lineToPoint:NSMakePoint(NSMaxX(segmentFrame), NSMinY(segmentFrame))];
        [border lineToPoint:NSMakePoint(NSMaxX(segmentFrame), NSMaxY(segmentFrame))];
    } else {
        [border lineToPoint:NSMakePoint(NSMaxX(segmentFrame) - self.radius, NSMinY(segmentFrame))];
        [border curveToPoint:NSMakePoint(NSMaxX(segmentFrame) - self.radius, NSMaxY(segmentFrame))
               controlPoint1:NSMakePoint(NSMaxX(segmentFrame), NSMinY(segmentFrame))
               controlPoint2:NSMakePoint(NSMaxX(segmentFrame), NSMaxY(segmentFrame))];
    }
    // Left-mode segment has rounded rect on left
    if (segment > 0) {
        [border lineToPoint:NSMakePoint(NSMinX(segmentFrame), NSMaxY(segmentFrame))];
        [border lineToPoint:NSMakePoint(NSMinX(segmentFrame), NSMinY(segmentFrame))];
    } else {
        [border lineToPoint:NSMakePoint(NSMinX(segmentFrame) + self.radius, NSMaxY(segmentFrame))];
        [border curveToPoint:NSMakePoint(NSMinX(segmentFrame) + self.radius, NSMinY(segmentFrame))
               controlPoint1:NSMakePoint(NSMinX(segmentFrame), NSMaxY(segmentFrame))
               controlPoint2:NSMakePoint(NSMinX(segmentFrame), NSMinY(segmentFrame))];
    }
    [border closePath];
    [border setLineWidth:1];
    [NSColorFromRGB(0xC2CBCE) set];
    [border stroke];
    
    // Fill
    BOOL selectMultiple = self.trackingMode == NSSegmentSwitchTrackingSelectAny;
    if ((highlighted && !selectMultiple && !selected) ||
        (highlighted && selectMultiple)) {
        [NSColorFromRGB(0xE5E6E8) set];
    } else if (selected) {
        [NSColorFromRGB(0xFFFFFF) set];
    } else {
        [NSColorFromRGB(0xF5F6F8) set];
    }
    [border fill];
    
    CGFloat textOffset;
    if (segment == self.segmentCount - 1) {
        textOffset = -1 * self.radius * 1.f/6.f;
    } else if (segment > 0) {
        textOffset = 0;
    } else {
        textOffset = self.radius * 1.f/6.f;
    }
    NSPoint textPoint = NSMakePoint(NSMinX(segmentFrame) + self.radius + textOffset - overageWidth/2,
                                    NSMidY(segmentFrame) - labelSize.height/2 - 1);
    [label drawAtPoint:textPoint withAttributes:self.labelAttributes];

    [super setWidth:[self widthForSegment:segment] forSegment:segment];
    
    if (segment < (self.segmentCount-1) &&
        [self isSelectedForSegment:(segment + 1)] &&
        ![self isSelectedForSegment:segment]) {
        NSRect rightFrame = NSMakeRect(NSMaxX(segmentFrame) - 4, NSMinY(segmentFrame), 4.0, NSHeight(segmentFrame));
        [self drawShadowInFrame:rightFrame inDirection:1];
    }
    if (segment > 0 &&
        [self isSelectedForSegment:(segment - 1)] &&
        ![self isSelectedForSegment:segment]) {
        NSRect leftFrame = NSMakeRect(NSMinX(segmentFrame), NSMinY(segmentFrame), 4.0, NSHeight(segmentFrame));
        [self drawShadowInFrame:leftFrame inDirection:-1];
    }
}

- (CGFloat)widthForSegment:(NSInteger)segment {
    NSString *label = [self labelForSegment:segment];
    NSSize labelSize = [label sizeWithAttributes:self.labelAttributes];
//    CGFloat radius =  * 2.f/3.f;
//    NSLog(@"Width for segment %ld: %f", (long)segment, labelSize.width + 2*radius);
    return labelSize.width + 2 * self.radius;
}

- (void)drawShadowInFrame:(NSRect)frame inDirection:(NSInteger)direction {
    [NSGraphicsContext saveGraphicsState];
    
    NSRect nsRect = frame;
    CGRect rect = *(CGRect*)&nsRect;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRect(context, *(CGRect*)&nsRect);
//    CGContextClipToMask(context, rect, [self maskForRectBottom:nsRect]);
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        0.315, 0.371, 0.450, direction > 0 ? 0.0 : 0.1,  // Right color
        0.315, 0.371, 0.450, direction > 0 ? 0.1 : 0.0  // Left color
    };
    
    CGGradientRef myGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    
    CGPoint myStartPoint = CGPointMake(NSMinX(rect), NSMinY(rect));
    CGPoint myEndPoint = CGPointMake(NSMaxX(rect), NSMinY(rect));
    
    CGContextDrawLinearGradient(context, myGradient, myStartPoint, myEndPoint, 0);
    
//    CGContextSetRGBFillColor(context, 0.315, 0.371, 0.450, 0.2);
//    CGContextFillRect(context, nsRect);
    
    CGColorSpaceRelease(colorSpace);
    
    [NSGraphicsContext restoreGraphicsState];
}

- (CGFloat)totalWidthInFrame:(NSRect)frame withRadius:(CGFloat)_radius upToSegment:(NSInteger)maxSegment {
    CGFloat totalWidth = 0;

    for (int s=0; s < maxSegment; s++) {
        totalWidth += [[self labelForSegment:s] sizeWithAttributes:self.labelAttributes].width;
        totalWidth += 2 * _radius;
    }
    
    return totalWidth;
}

- (void)setupLabels:(NSInteger)segment {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x808AA0);
    if ([self isSelectedForSegment:segment]) {
        textColor = NSColorFromRGB(0x303AA0);
    }
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSLeftTextAlignment];

    self.labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

- (void)_updateHighlightedSegment:(NSPoint)currentPoint
                           inView:(NSView *)controlView {
    [self setHighlightedSegment:-1];
    NSPoint loc = currentPoint;
    NSRect frame = controlView.frame;
    CGFloat totalWidth = [self totalWidthInFrame:frame withRadius:self.radius upToSegment:self.segmentCount];
    loc.x += frame.origin.x;
    loc.y += frame.origin.y;
    frame.origin.x += (NSWidth(frame)/2 - totalWidth/2);
    NSUInteger i = 0;
    while (i < self.segmentCount) {
        frame.size.width = [self widthForSegment:i];
        if (NSMouseInRect(loc, frame, NO)) {
            [self setHighlightedSegment:i];
            break;
        }
        frame.origin.x += frame.size.width;
        i++;
    }
    
    [controlView setNeedsDisplay:YES];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint
                 inView:(NSView *)controlView {
    [self _updateHighlightedSegment:startPoint inView:controlView];
    return [super startTrackingAt:startPoint inView:controlView];
}

- (BOOL)continueTracking:(NSPoint)lastPoint
                      at:(NSPoint)currentPoint
                  inView:(NSView *)controlView {
    [self _updateHighlightedSegment:currentPoint inView:controlView];
    return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint
                  at:(NSPoint)stopPoint
              inView:(NSView *)controlView
           mouseIsUp:(BOOL)flag {
    // Don't call super since we need to manually set selected based on highlight
//    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];

    if (self.highlightedSegment >= 0) {
        BOOL selectMultiple = self.trackingMode == NSSegmentSwitchTrackingSelectAny;
        if (selectMultiple) {
            [self setSelected:![self isSelectedForSegment:self.highlightedSegment] forSegment:self.highlightedSegment];
        } else {
            [self setSelected:YES forSegment:self.highlightedSegment];
        }
        if ([self.target respondsToSelector:self.action]) {
            // Lines below crash in release but not in debug, so using warning-suppression instead
//            IMP imp = [self.target methodForSelector:self.action];
//            void (*func)(id, SEL) = (void *)imp;
//            func(self.target, self.action);
            // Verbose above, but without warnings from line below
            //disable warning:"PerformSelector may cause a leak because its selector is unknown"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.action withObject:controlView];
#pragma clang diagnostic pop
        }
    }
    
    [self setHighlightedSegment:-1];
}

@end
