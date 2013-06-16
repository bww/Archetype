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

#import "ARGenerator.h"
#import "ARRelocator.h"

@implementation ARGenerator

@synthesize descriptor = _descriptor;
@synthesize config = _config;

/**
 * Create a generator
 */
+(ARGenerator *)generatorWithDescriptor:(ARDescriptor *)descriptor configuration:(ARConfig *)config {
  return [[[self alloc] initWithDescriptor:descriptor configuration:config] autorelease];
}

/**
 * Clean up
 */
-(void)dealloc {
  [_descriptor release];
  [_config release];
  [super dealloc];
}

/**
 * Initialize
 */
-(id)initWithDescriptor:(ARDescriptor *)descriptor configuration:(ARConfig *)config {
  if((self = [super init]) != nil){
    _descriptor = [descriptor retain];
    _config = [config retain];
  }
  return self;
}

/**
 * Generate a project
 */
-(BOOL)generateWithSourceURL:(NSURL *)sourceURL outputURL:(NSURL *)outputURL error:(NSError **)error {
  ARRelocator *relocator = [ARRelocator relocatorWithSourceBaseURL:sourceURL outputBaseURL:outputURL];
  NSError *inner = nil;
  BOOL status = FALSE;
  
  __block NSError *enumError = nil;
  NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:sourceURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^ BOOL (NSURL *url, NSError *blockError) {
    enumError = [blockError copy];
    return FALSE;
  }];
  
  for(NSURL *url in enumerator){
    ARDebug(@"==> %@", [url path]);
    
    NSString *name;
    if(![url getResourceValue:&name forKey:NSURLNameKey error:&inner]){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not obtain URL resource");
      goto error;
    }
    
    if([name caseInsensitiveCompare:kARDescriptorStandardResourcePath] == NSOrderedSame){
      // skip the archetype descriptor file, obviously
      continue;
    }
    
    NSNumber *directory;
    if(![url getResourceValue:&directory forKey:NSURLIsDirectoryKey error:&inner]){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not obtain URL resource");
      goto error;
    }
    
    NSURL *destURL;
    if((destURL = [relocator outputURLForSourceURL:url error:&inner]) == nil){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not relocate file");
      goto error;
    }
    
  }
  
  if(enumError != nil){
    if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, enumError, @"Could not read directory");
    [enumError release]; enumError = nil;
    goto error;
  }
  
  status = TRUE;
error:
  return status;
}

@end

