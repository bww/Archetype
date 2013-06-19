// 
// Copyright 2013 Brian William Wolter, All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
// 

#import "ARUTIMatcher.h"

@implementation ARUTIMatcher

@synthesize typeIdentifiers = _typeIdentifiers;

/**
 * Create a matcher with the standard set of UTIs
 */
+(ARUTIMatcher *)UTIMatcherWithStandardTypeIdentifiers {
  return [self UTIMatcherWithTypeIdentifiers:[NSSet setWithObjects:
    @"public.text",
    @"public.plain-text",
    @"public.source-code",
    @"public.script",
    @"public.shell-script",
    @"public.xml",
    nil
  ]];
}

/**
 * Create a matcher with UTIs
 */
+(ARUTIMatcher *)UTIMatcherWithTypeIdentifiers:(NSSet *)typeIdentifiers {
  return [[[self alloc] initWithTypeIdentifiers:typeIdentifiers] autorelease];
}

/**
 * Clean up
 */
-(void)dealloc {
  [_typeIdentifiers release];
  [super dealloc];
}

/**
 * Initialize
 */
-(id)initWithTypeIdentifiers:(NSSet *)typeIdentifiers {
  if((self = [super init]) != nil){
    _typeIdentifiers = [typeIdentifiers retain];
  }
  return self;
}

/**
 * Match a URL
 */
-(BOOL)matches:(NSURL *)url {
  BOOL result = FALSE;
  
  NSString *extension;
  if((extension = [url pathExtension]) != nil){
    CFStringRef uti;
    if((uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)extension, NULL)) != NULL){
      for(NSString *check in self.typeIdentifiers){
        if((result = UTTypeConformsTo(uti, (CFStringRef)check)) == TRUE) break;
      }
      CFRelease(uti);
    }
  }
  
  return result;
}

@end

