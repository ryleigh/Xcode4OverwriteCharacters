#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

static IMP original_insertText = nil;

@interface XCode4OverwriteCharacters : NSObject
@end

@implementation XCode4OverwriteCharacters
static void insertText( id self_, SEL _cmd, id aString )
{
    NSTextView *self = (NSTextView *)self_;
    NSString *text = self.string;
    
    NSString *inputChar = (NSString *)aString;
    
    NSRange selectedRange = [[[self selectedRanges] lastObject] rangeValue];
    if(selectedRange.length == 0) // only replace chars if nothing is selected
    {
        if([inputChar isEqualToString:@")"] ||
           [inputChar isEqualToString:@"\""] ||
           [inputChar isEqualToString:@";"])
        {
            // if the same char exists to the right of the cursor, delete it
            NSRange nextCharRange = NSMakeRange(selectedRange.location, 1);
            NSString *nextChar = [text substringWithRange:nextCharRange];
            if([inputChar isEqualToString:nextChar])
            {
                [self setSelectedRange:nextCharRange];
                [self delete:nil];
            }
        }
    }
    

   return ((void (*)(id, SEL, id))original_insertText)(self_, _cmd, (id)aString);
}

+ (void) pluginDidLoad:(NSBundle *)plugin
{
    Class class = nil;
    Method originalMethod = nil;
    
    NSLog(@"%@ initializing...", NSStringFromClass([self class]));
    
    if (!(class = NSClassFromString(@"DVTSourceTextView")))
        goto failed;
    
    if (!(originalMethod = class_getInstanceMethod(class, @selector(insertText:))))
        goto failed;
    
    if (!(original_insertText = method_setImplementation(originalMethod, (IMP)&insertText)))
        goto failed;
    
    NSLog(@"%@ complete!", NSStringFromClass([self class]));
    return;
    
failed:
    NSLog(@"%@ failed. :(", NSStringFromClass([self class]));
}
@end
