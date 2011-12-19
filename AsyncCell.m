//
//  AsyncCell.m
//  IOSBoilerplate
//
//  Copyright (c) 2011 Alberto Gimeno Brieba
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//  

#import "AsyncCell.h"
#import "DictionaryHelper.h"

#import "UIImageView+AFNetworking.h"

@implementation AsyncCell

@synthesize info;
@synthesize image;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
    {
		self.backgroundColor = [UIColor blackColor];
		self.opaque = YES;
    }
    return self;
}

- (void) prepareForReuse {
	[super prepareForReuse];
    self.image = nil;
}

static UIFont* system14 = nil;
static UIFont* bold14 = nil;

+ (void)initialize
{
	if(self == [AsyncCell class])
	{
		system14 = [UIFont systemFontOfSize:14];
		bold14 = [UIFont boldSystemFontOfSize:14];
	}
}



- (UIImage*)imageWithImage:(UIImage*)imageToResize scaledToSize:(CGSize)size
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(size);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [imageToResize drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

-(UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    //CGImageRelease(imageRef);
    
    return cropped;
}

- (void) drawContentView:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[[UIColor blackColor] set];
	CGContextFillRect(context, rect);
	
    //NSString* created = [NSString stringWithFormat:@"%@",[info objectForKey:@"created"]];
	NSString* text = [info stringForKey:@"text"];
	
	CGFloat widthr = self.frame.size.width - 70;

	[[UIColor grayColor] set];
	[text drawInRect:CGRectMake(63.0, 25.0, widthr, 20.0) withFont:system14 lineBreakMode:UILineBreakModeTailTruncation];
	
	if (self.image) {
        UIImage *imageToDisplay;
        imageToDisplay = self.image;
        imageToDisplay = [self imageWithImage:imageToDisplay scaledToSize:CGSizeMake(imageToDisplay.size.width / 1.5, imageToDisplay.size.height / 1.5)];
        imageToDisplay = [self imageByCropping:imageToDisplay toRect:CGRectMake(30, 0, 290, 270)];
        CGFloat width = imageToDisplay.size.width;
        CGFloat height = imageToDisplay.size.height;
        CGRect r;
        
        r = CGRectMake(5.0, 5.0, width, height);
        
		[imageToDisplay drawInRect:r];
        
        /*[[UIColor whiteColor] set];
        [created drawInRect:CGRectMake(10.0, 5.0, widthr, 20.0) withFont:system14 lineBreakMode:UILineBreakModeTailTruncation];*/
	}
}

- (void) updateCellInfo:(NSDictionary*)_info {
	self.info = _info;
    NSString *urlString = [info stringForKey:@"src_big"];
	if (urlString) {
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
            self.image = requestedImage;
            [self setNeedsDisplay];
        }];
        [operation start];
    }
}

@end
