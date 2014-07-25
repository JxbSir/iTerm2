//
//  PSMMetalTabStyle.m
//  PSMTabBarControl
//
//  Created by John Pannell on 2/17/06.
//  Copyright 2006 Positive Spin Media. All rights reserved.
//

#import "PSMMetalTabStyle.h"
#import "PSMTabBarCell.h"
#import "PSMTabBarControl.h"

#define kPSMMetalObjectCounterRadius 7.0
#define kPSMMetalCounterMinWidth 20

@implementation PSMMetalTabStyle

- (NSString *)name
{
    return @"Metal";
}

#pragma mark -
#pragma mark Creation/Destruction

- (id)init {
    if ((self = [super init]))  {
        // Load close buttons 
        metalCloseButton = [[NSImage imageNamed:@"TabClose_Front"] retain];
        metalCloseButtonDown = [[NSImage imageNamed:@"TabClose_Front_Pressed"] retain];
        metalCloseButtonOver = [[NSImage imageNamed:@"TabClose_Front_Rollover"] retain];

        // Load "new tab" buttons
        _addTabButtonImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"TabNewMetal"]];
        _addTabButtonPressedImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"TabNewMetalPressed"]];
        _addTabButtonRolloverImage = [[NSImage alloc] initByReferencingFile:[[PSMTabBarControl bundle] pathForImageResource:@"TabNewMetalRollover"]];

        _objectCountStringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:11.0], NSFontAttributeName,
                                                                                    [[NSColor blackColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                                                                                    nil, nil];
    }
    return self;
}

- (void)dealloc {
    [metalCloseButton release];
    [metalCloseButtonDown release];
    [metalCloseButtonOver release];
    [_addTabButtonImage release];
    [_addTabButtonPressedImage release];
    [_addTabButtonRolloverImage release];

    [_objectCountStringAttributes release];

    [super dealloc];
}

#pragma mark - Control Specific

- (float)leftMarginForTabBarControl {
    return 0.0f;
}

- (float)rightMarginForTabBarControl {
    // Leaves space for overflow control.
    return 24.0f;
}

// For vertical orientation
- (float)topMarginForTabBarControl {
    return 0.0f;
}

#pragma mark - Add Tab Button

- (NSImage *)addTabButtonImage {
    return _addTabButtonImage;
}

- (NSImage *)addTabButtonPressedImage {
    return _addTabButtonPressedImage;
}

- (NSImage *)addTabButtonRolloverImage {
    return _addTabButtonRolloverImage;
}

#pragma mark - Cell Specific

- (NSRect)dragRectForTabCell:(PSMTabBarCell *)cell
                 orientation:(PSMTabBarOrientation)tabOrientation {
    NSRect dragRect = [cell frame];
    dragRect.size.width++;

    if ([cell tabState] & PSMTab_SelectedMask) {
        if (tabOrientation == PSMTabBarHorizontalOrientation) {
            dragRect.size.height -= 2.0;
        } else {
            dragRect.size.height += 1.0;
            dragRect.origin.y -= 1.0;
            dragRect.origin.x += 2.0;
            dragRect.size.width -= 3.0;
        }
    } else if (tabOrientation == PSMTabBarVerticalOrientation) {
        dragRect.origin.x--;
    }

    return dragRect;
}

- (NSRect)closeButtonRectForTabCell:(PSMTabBarCell *)cell {
    NSRect cellFrame = [cell frame];

    if ([cell hasCloseButton] == NO) {
        return NSZeroRect;
    }

    NSRect result;
    result.size = [metalCloseButton size];
    result.origin.x = cellFrame.origin.x + MARGIN_X;
    result.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;

    return result;
}

- (NSRect)iconRectForTabCell:(PSMTabBarCell *)cell {
    NSRect cellFrame = [cell frame];

    if ([cell hasIcon] == NO) {
        return NSZeroRect;
    }

    NSRect result;
    result.size = NSMakeSize(kPSMTabBarIconWidth, kPSMTabBarIconWidth);
    result.origin.x = cellFrame.origin.x + MARGIN_X;
    result.origin.y = cellFrame.origin.y + MARGIN_Y;

    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        result.origin.x += [metalCloseButton size].width + kPSMTabBarCellPadding;
    }

    return result;
}

- (NSRect)indicatorRectForTabCell:(PSMTabBarCell *)cell {
    NSRect cellFrame = [cell frame];

    if ([[cell indicator] isHidden]) {
        return NSZeroRect;
    }

    NSRect result;
    result.size = NSMakeSize(kPSMTabBarIndicatorWidth, kPSMTabBarIndicatorWidth);
    result.origin.x = cellFrame.origin.x + cellFrame.size.width - MARGIN_X - kPSMTabBarIndicatorWidth;
    result.origin.y = cellFrame.origin.y + MARGIN_Y;

    return result;
}

- (NSRect)objectCounterRectForTabCell:(PSMTabBarCell *)cell {
    NSRect cellFrame = [cell frame];

    if ([cell count] == 0) {
        return NSZeroRect;
    }

    float countWidth = [[self attributedObjectCountValueForTabCell:cell] size].width;
    countWidth += (2 * kPSMMetalObjectCounterRadius - 6.0);
    if (countWidth < kPSMMetalCounterMinWidth) {
        countWidth = kPSMMetalCounterMinWidth;
    }

    NSRect result;
    result.size = NSMakeSize(countWidth, 2 * kPSMMetalObjectCounterRadius); // temp
    result.origin.x = cellFrame.origin.x + cellFrame.size.width - MARGIN_X - result.size.width;
    result.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;

    if (![[cell indicator] isHidden]) {
        result.origin.x -= kPSMTabBarIndicatorWidth + kPSMTabBarCellPadding;
    }

    return result;
}


- (float)minimumWidthOfTabCell:(PSMTabBarCell *)cell {
    float resultWidth = 0.0;

    // left margin
    resultWidth = MARGIN_X;

    // close button?
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        resultWidth += [metalCloseButton size].width + kPSMTabBarCellPadding;
    }

    // icon?
    if ([cell hasIcon]) {
        resultWidth += kPSMTabBarIconWidth + kPSMTabBarCellPadding;
    }

    // the label
    resultWidth += kPSMMinimumTitleWidth;

    // object counter?
    if ([cell count] > 0) {
        resultWidth += [self objectCounterRectForTabCell:cell].size.width + kPSMTabBarCellPadding;
    }

    // indicator?
    if ([[cell indicator] isHidden] == NO) {
        resultWidth += kPSMTabBarCellPadding + kPSMTabBarIndicatorWidth;
    }

    // right margin
    resultWidth += MARGIN_X;

    return ceil(resultWidth);
}

- (float)desiredWidthOfTabCell:(PSMTabBarCell *)cell {
    float resultWidth = 0.0;

    // left margin
    resultWidth = MARGIN_X;

    // close button?
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        resultWidth += [metalCloseButton size].width + kPSMTabBarCellPadding;
    }

    // icon?
    if ([cell hasIcon]) {
        resultWidth += kPSMTabBarIconWidth + kPSMTabBarCellPadding;
    }

    // the label
    resultWidth += [[cell attributedStringValue] size].width;

    // object counter?
    if ([cell count] > 0) {
        resultWidth += [self objectCounterRectForTabCell:cell].size.width + kPSMTabBarCellPadding;
    }

    // indicator?
    if ([[cell indicator] isHidden] == NO) {
        resultWidth += kPSMTabBarCellPadding + kPSMTabBarIndicatorWidth;
    }

    // right margin
    resultWidth += MARGIN_X;

    return ceil(resultWidth);
}

#pragma mark - Cell Values

- (NSAttributedString *)attributedObjectCountValueForTabCell:(PSMTabBarCell *)cell {
    NSNumberFormatter *nf = [[[NSNumberFormatter alloc] init] autorelease];
    [nf setLocalizesFormat:YES];
    [nf setFormat:@"0"];
    [nf setHasThousandSeparators:YES];
    NSString *contents = [nf stringFromNumber:[NSNumber numberWithInt:[cell count]]];
    if ([cell count] < 9) {
        contents = [NSString stringWithFormat:@"%@%@", [cell modifierString], contents];
    } else if ([cell isLast]) {
        contents = [NSString stringWithFormat:@"%@9", [cell modifierString]];
    } else {
        contents = @"";
    }
    return [[[NSMutableAttributedString alloc] initWithString:contents
                                                   attributes:_objectCountStringAttributes]
               autorelease];
}

- (NSAttributedString *)attributedStringValueForTabCell:(PSMTabBarCell *)cell {
    NSMutableAttributedString *attrStr;
    NSString *contents = [cell stringValue];
    attrStr = [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
    NSRange range = NSMakeRange(0, [contents length]);

    NSColor *textColor;
    if (cell.state == NSOnState) {
        textColor = [NSColor blackColor];
    } else {
        textColor = [NSColor colorWithSRGBRed:101/255.0 green:100/255.0 blue:101/255.0 alpha:1];
    }
    // Add font attribute
    [attrStr addAttribute:NSFontAttributeName
                    value:[NSFont systemFontOfSize:11.0]
                    range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:textColor
                    range:range];

    // Paragraph Style for Truncating Long Text
    static NSMutableParagraphStyle *truncatingTailParagraphStyle = nil;
    if (!truncatingTailParagraphStyle) {
        truncatingTailParagraphStyle =
            [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] retain];
        [truncatingTailParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [truncatingTailParagraphStyle setAlignment:NSCenterTextAlignment];
    }
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:truncatingTailParagraphStyle
                    range:range];

    return attrStr;
}

#pragma mark - Drawing

- (NSColor *)topLineColorSelected:(BOOL)selected {
    if (selected) {
        return [NSColor colorWithSRGBRed:195/255.0 green:191/255.0 blue:195/255.0 alpha:1];
    } else {
        return [NSColor colorWithSRGBRed:182/255.0 green:179/255.0 blue:182/255.0 alpha:1];
    }
}

- (NSColor *)verticalLineColor {
    return [NSColor colorWithWhite:184/255.0 alpha:1];
}

- (NSColor *)bottomLineColorSelected:(BOOL)selected {
    if (selected) {
        return [NSColor colorWithSRGBRed:182/255.0 green:180/255.0 blue:182/255.0 alpha:1];
    } else {
        return [NSColor colorWithSRGBRed:170/255.0 green:167/255.0 blue:170/255.0 alpha:1];
    }
}

- (NSGradient *)backgroundGradientSelected:(BOOL)selected {
    if (selected) {
        return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithSRGBRed:222/255.0
                                                                              green:219/255.0
                                                                               blue:222/255.0
                                                                              alpha:1]
                                              endingColor:[NSColor colorWithSRGBRed:214/255.0
                                                                              green:211/255.0
                                                                               blue:214/255.0
                                                                              alpha:1]]
                   autorelease];
    } else {
        return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithSRGBRed:206/255.0
                                                                              green:204/255.0
                                                                               blue:206/255.0
                                                                              alpha:1]
                                              endingColor:[NSColor colorWithSRGBRed:199/255.0
                                                                              green:196/255.0
                                                                               blue:199/255.0
                                                                              alpha:1]]
                   autorelease];
    }
}

- (void)drawHorizontalLineInFrame:(NSRect)rect y:(CGFloat)y {
    NSRectFill(NSMakeRect(NSMinX(rect), y, rect.size.width + 1, 1));
}

- (void)drawVerticalLineInFrame:(NSRect)rect x:(CGFloat)x {
    NSRectFill(NSMakeRect(x, NSMinY(rect) + 1, 1, rect.size.height - 2));
}

- (void)drawCellBackgroundAndFrameHorizontallyOriented:(BOOL)horizontal
                                                inRect:(NSRect)cellFrame
                                              selected:(BOOL)selected
                                          withTabColor:(NSColor *)tabColor {
    CGFloat angle = horizontal ? 90 : 0;
    [[self backgroundGradientSelected:selected] drawInRect:cellFrame angle:angle];
    if (tabColor) {
        [[tabColor colorWithAlphaComponent:0.5] set];
        NSRectFill(cellFrame);
    }

    // Left line
    if (horizontal) {
        [[self verticalLineColor] set];
    } else {
        [[self topLineColorSelected:selected] set];
    }
    [self drawVerticalLineInFrame:cellFrame x:NSMinX(cellFrame)];

    // Right line
    if (horizontal) {
        [[self verticalLineColor] set];
    } else {
        [[self bottomLineColorSelected:selected] set];
    }
    [self drawVerticalLineInFrame:cellFrame x:NSMaxX(cellFrame)];

    // Top line
    if (horizontal) {
        [[self topLineColorSelected:selected] set];
    } else {
        [[self verticalLineColor] set];
    }
    [self drawHorizontalLineInFrame:cellFrame y:NSMinY(cellFrame)];

    // Bottom line
    if (horizontal) {
        [[self bottomLineColorSelected:selected] set];
    } else {
        [[self verticalLineColor] set];
    }
    [self drawHorizontalLineInFrame:cellFrame y:NSMaxY(cellFrame) - 1];
    
}

- (void)drawTabCell:(PSMTabBarCell *)cell {
    // TODO: Test hidden control, whose height is less than 2. Maybe it happens while dragging?
    [self drawCellBackgroundAndFrameHorizontallyOriented:(orientation == PSMTabBarHorizontalOrientation)
                                                  inRect:cell.frame
                                                selected:([cell state] == NSOnState)
                                            withTabColor:[cell tabColor]];

    [self drawInteriorWithTabCell:cell inView:[cell controlView]];
}


- (void)drawInteriorWithTabCell:(PSMTabBarCell *)cell inView:(NSView*)controlView {
    NSRect cellFrame = [cell frame];
    float labelPosition = cellFrame.origin.x + MARGIN_X;

    // close button
    if ([cell hasCloseButton] && ![cell isCloseButtonSuppressed]) {
        NSSize closeButtonSize = NSZeroSize;
        NSRect closeButtonRect = [cell closeButtonRectForFrame:cellFrame];
        NSImage *closeButton = nil;

        closeButton = metalCloseButton;
        if ([cell closeButtonOver]) {
            closeButton = metalCloseButtonOver;
        }
        if ([cell closeButtonPressed]) {
            closeButton = metalCloseButtonDown;
        }

        closeButtonSize = [closeButton size];
        if ([controlView isFlipped]) {
            closeButtonRect.origin.y += closeButtonRect.size.height;
        }

        [closeButton compositeToPoint:closeButtonRect.origin
                            operation:NSCompositeSourceOver
                             fraction:1.0];

        // scoot label over
        labelPosition += closeButtonSize.width + kPSMTabBarCellPadding;
    }

    // icon
    if ([cell hasIcon]) {
        NSRect iconRect = [self iconRectForTabCell:cell];
        NSImage *icon = [(id)[[cell representedObject] identifier] icon];

        if ([controlView isFlipped]) {
            iconRect.origin.y += iconRect.size.height;
        }
        // center in available space (in case icon image is smaller than kPSMTabBarIconWidth)
        if ([icon size].width < kPSMTabBarIconWidth) {
            iconRect.origin.x += (kPSMTabBarIconWidth - [icon size].width)/2.0;
        }
        if ([icon size].height < kPSMTabBarIconWidth) {
            iconRect.origin.y -= (kPSMTabBarIconWidth - [icon size].height)/2.0;
        }

        [icon compositeToPoint:iconRect.origin operation:NSCompositeSourceOver fraction:1.0];

        // scoot label over
        labelPosition += iconRect.size.width + kPSMTabBarCellPadding;
    }

    // object counter
    if ([cell count] > 0){
        NSRect myRect = [self objectCounterRectForTabCell:cell];

        // draw attributed string centered in area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectCountValueForTabCell:cell];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = myRect.origin.x + ((myRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = myRect.origin.y + ((myRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];
    }

    // label rect
    NSRect labelRect;
    labelRect.origin.x = labelPosition;
    labelRect.size.width = cellFrame.size.width - (labelRect.origin.x - cellFrame.origin.x) - kPSMTabBarCellPadding;
    labelRect.size.height = cellFrame.size.height;
    labelRect.origin.y = cellFrame.origin.y + MARGIN_Y + 1.0;

    if (![[cell indicator] isHidden]) {
        labelRect.size.width -= (kPSMTabBarIndicatorWidth + kPSMTabBarCellPadding);
    }

    if ([cell count] > 0) {
        labelRect.size.width -= ([self objectCounterRectForTabCell:cell].size.width + kPSMTabBarCellPadding);
    }

    // label
    [[cell attributedStringValue] drawInRect:labelRect];
}

- (void)drawBackgroundInRect:(NSRect)rect
                       color:(NSColor*)backgroundColor
                  horizontal:(BOOL)horizontal {
    if (orientation == PSMTabBarVerticalOrientation && [tabBar frame].size.width < 2) {
        return;
    }

    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];

    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
    NSRectFillUsingOperation(rect, NSCompositeSourceAtop);

    [[NSColor darkGrayColor] set];
    if (orientation == PSMTabBarHorizontalOrientation) {
        [NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x,
                                                      rect.origin.y + 0.5)
                                  toPoint:NSMakePoint(rect.origin.x + rect.size.width,
                                                      rect.origin.y + 0.5)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x,
                                                      rect.origin.y + rect.size.height - 0.5) 
                                  toPoint:NSMakePoint(rect.origin.x + rect.size.width,
                                                      rect.origin.y + rect.size.height - 0.5)];
    } else {
        [NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x,
             rect.origin.y + 0.5) toPoint:NSMakePoint(rect.origin.x,
                                                      rect.origin.y + rect.size.height + 0.5)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x + rect.size.width,
             rect.origin.y + 0.5) toPoint:NSMakePoint(rect.origin.x + rect.size.width,
                                                      rect.origin.y + rect.size.height + 0.5)];
    }

    [NSGraphicsContext restoreGraphicsState];
}

- (void)fillPath:(NSBezierPath*)path {
    [[NSColor windowBackgroundColor] set];
    [path fill];
    [[NSColor colorWithCalibratedWhite:0.0 alpha:0.2] set];
    [path fill];
    [[NSColor darkGrayColor] set];
    [path stroke];
}

- (void)drawTabBar:(PSMTabBarControl *)bar
            inRect:(NSRect)rect
        horizontal:(BOOL)horizontal {
    if (orientation != [bar orientation]) {
        orientation = [bar orientation];
    }

    if (tabBar != bar) {
        tabBar = bar;
    }

    [self drawBackgroundInRect:rect color:nil horizontal:horizontal];

    // no tab view == not connected
    if (![bar tabView]){
        NSRect labelRect = rect;
        labelRect.size.height -= 4.0;
        labelRect.origin.y += 4.0;
        NSString *contents = @"PSMTabBarControl";
        NSMutableAttributedString *attrStr =
            [[[NSMutableAttributedString alloc] initWithString:contents] autorelease];
        NSRange range = NSMakeRange(0, [contents length]);
        [attrStr addAttribute:NSFontAttributeName
                        value:[NSFont systemFontOfSize:11.0]
                        range:range];
        NSMutableParagraphStyle *centeredParagraphStyle =
            [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [centeredParagraphStyle setAlignment:NSCenterTextAlignment];
        [attrStr addAttribute:NSParagraphStyleAttributeName
                        value:centeredParagraphStyle
                        range:range];
        [attrStr drawInRect:labelRect];
        return;
    }

    // draw cells
    for (int i = 0; i < 2; i++) {
        NSInteger stateToDraw = (i == 0 ? NSOnState : NSOffState);
        for (PSMTabBarCell *cell in [bar cells]) {
            if (![cell isInOverflowMenu] && NSIntersectsRect([cell frame], rect)) {
                if (cell.state == stateToDraw) {
                    [cell drawWithFrame:[cell frame] inView:bar];
                    if (stateToDraw == NSOnState) {
                        // Can quit early since only one can be selected
                        break;
                    }
                }
            }
        }
    }
}

#pragma mark - Archiving

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeObject:metalCloseButton forKey:@"metalCloseButton"];
        [aCoder encodeObject:metalCloseButtonDown forKey:@"metalCloseButtonDown"];
        [aCoder encodeObject:metalCloseButtonOver forKey:@"metalCloseButtonOver"];
        [aCoder encodeObject:_addTabButtonImage forKey:@"addTabButtonImage"];
        [aCoder encodeObject:_addTabButtonPressedImage forKey:@"addTabButtonPressedImage"];
        [aCoder encodeObject:_addTabButtonRolloverImage forKey:@"addTabButtonRolloverImage"];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        if ([aDecoder allowsKeyedCoding]) {
            metalCloseButton = [[aDecoder decodeObjectForKey:@"metalCloseButton"] retain];
            metalCloseButtonDown = [[aDecoder decodeObjectForKey:@"metalCloseButtonDown"] retain];
            metalCloseButtonOver = [[aDecoder decodeObjectForKey:@"metalCloseButtonOver"] retain];
            _addTabButtonImage = [[aDecoder decodeObjectForKey:@"addTabButtonImage"] retain];
            _addTabButtonPressedImage = [[aDecoder decodeObjectForKey:@"addTabButtonPressedImage"] retain];
            _addTabButtonRolloverImage = [[aDecoder decodeObjectForKey:@"addTabButtonRolloverImage"] retain];
        }
    }
    return self;
}

@end
