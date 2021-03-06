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

#import "ARExtensionMatcher.h"

@implementation ARExtensionMatcher

@synthesize pathExtensions = _pathExtensions;

/**
 * Create a matcher with UTIs
 */
+(ARExtensionMatcher *)extensionMatcherWithPathExtensions:(NSSet *)pathExtensions {
  return [[[self alloc] initWithPathExtensions:pathExtensions] autorelease];
}

/**
 * Clean up
 */
-(void)dealloc {
  [_pathExtensions release];
  [super dealloc];
}

/**
 * Initialize
 */
-(id)initWithPathExtensions:(NSSet *)pathExtensions {
  if((self = [super init]) != nil){
    _pathExtensions = [pathExtensions retain];
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
    for(NSString *check in self.pathExtensions){
      if((result = ([extension caseInsensitiveCompare:check] == NSOrderedSame)) == TRUE) break;
    }
  }
  
  return result;
}

@end

