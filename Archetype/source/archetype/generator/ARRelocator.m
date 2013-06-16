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

#import "ARRelocator.h"

@implementation ARRelocator

@synthesize sourceBaseURL = _sourceBaseURL;
@synthesize outputBaseURL = _outputBaseURL;

+(ARRelocator *)relocatorWithSourceBaseURL:(NSURL *)sourceBaseURL outputBaseURL:(NSURL *)outputBaseURL {
  return [[[self alloc] initWithSourceBaseURL:sourceBaseURL outputBaseURL:outputBaseURL] autorelease];
}

-(void)dealloc {
  [_sourceBaseURL release];
  [_outputBaseURL release];
  [super dealloc];
}

-(id)initWithSourceBaseURL:(NSURL *)sourceBaseURL outputBaseURL:(NSURL *)outputBaseURL {
  if((self = [super init]) != nil){
    _sourceBaseURL = [[sourceBaseURL URLByResolvingSymlinksInPath] retain];
    _outputBaseURL = [[outputBaseURL URLByResolvingSymlinksInPath] retain];
  }
  return self;
}

-(NSURL *)outputURLForSourceURL:(NSURL *)sourceURL {
  return [self outputURLForSourceURL:sourceURL error:nil];
}

-(NSURL *)outputURLForSourceURL:(NSURL *)sourceURL error:(NSError **)error {
  NSURL *outputURL = nil;
  
  NSURL *outputBaseURL;
  if((outputBaseURL = self.outputBaseURL) == nil){
    if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Output base URL must not be null");
    goto error;
  }
  
  NSArray *sourceBaseComponents;
  if((sourceBaseComponents = [self.sourceBaseURL pathComponents]) == nil){
    if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Source base URL must not be null");
    goto error;
  }
  
  NSArray *sourceComponents;
  if((sourceComponents = [[sourceURL URLByResolvingSymlinksInPath] pathComponents]) == nil){
    if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Source URL must not be null");
    goto error;
  }
  
  if([sourceBaseComponents count] > [sourceComponents count]){
    if(error) *error = NSERROR_WITH_URL(ARArchetypeErrorDomain, ARStatusError, self.sourceBaseURL, @"Source URL does not exist under the source base URL");
    goto error;
  }
  
  for(int i = 0; i < [sourceBaseComponents count]; i++){
    if([[sourceBaseComponents objectAtIndex:i] caseInsensitiveCompare:[sourceComponents objectAtIndex:i]] != NSOrderedSame){
      if(i < 2 /* root '/' counts */){
        if(error) *error = NSERROR_WITH_URL(ARArchetypeErrorDomain, ARStatusError, self.sourceBaseURL, @"Source URL does not exist under the source base URL");
        goto error;
      }else{
        break;
      }
    }
  }
  
  // reletivize the source path
  NSString *relativeSourcePath = [[sourceComponents subarrayWithRange:NSMakeRange([sourceBaseComponents count], [sourceComponents count] - [sourceBaseComponents count])] componentsJoinedByString:@"/"];
  // relocate it under the output base
  outputURL = [self.outputBaseURL URLByAppendingPathComponent:relativeSourcePath];
  
error:
  return outputURL;
}

@end

