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

#import "ARFileFetcher.h"
#import "ARUtility.h"

@implementation ARFileFetcher

/**
 * Fetch
 */
-(BOOL)fetchContentsOfURL:(NSURL *)url destination:(NSString *)destination progress:(ARFetcherProgressBlock)progress error:(NSError **)error {
  BOOL directory = FALSE;
  NSError *inner = nil;
  BOOL status = FALSE;
  
  if(![url isFileURL]){
    if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"%@ only supports file URLs", [self class]);
    goto error;
  }
  
  if(![[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&directory]){
    if(error) *error = NSERROR_WITH_URL(ARArchetypeErrorDomain, ARStatusError, url, @"Archetype directory does not exist");
    goto error;
  }else if(!directory){
    if(error) *error = NSERROR_WITH_URL(ARArchetypeErrorDomain, ARStatusError, url, @"Archetype path is not a directory");
    goto error;
  }
  
  if(![[NSFileManager defaultManager] copyItemAtPath:[url path] toPath:destination error:&inner]){
    if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not copy archetype directory to the working directory");
    goto error;
  }
  
  status = TRUE;
error:
  return status;
}

@end

