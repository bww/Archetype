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

#import "ARFetcher.h"
#import "ARFileFetcher.h"
#import "ARGitFetcher.h"

@implementation ARFetcher

/**
 * Figure out a URL for the provided resource
 */
+(NSURL *)URLForResource:(NSString *)pathOrURL {
  NSRange range;
  if((range = [pathOrURL rangeOfString:@"://"]).location != NSNotFound){
    return [NSURL URLWithString:pathOrURL];
  }else if((range = [pathOrURL rangeOfString:@"git"]).location == 0){
    return [NSURL URLWithString:[NSString stringWithFormat:@"ssh://%@", pathOrURL]];
  }else{
    return [NSURL fileURLWithPath:pathOrURL];
  }
}

/**
 * Obtain a fetcher suitable for the provided resource
 */
+(ARFetcher *)fetcherForURL:(NSURL *)url {
  NSString *scheme = url.scheme;
  
  if([scheme caseInsensitiveCompare:@"ssh"] == NSOrderedSame){
    return [ARGitFetcher fetcher];
  }else if([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame && [[url pathExtension] caseInsensitiveCompare:@"git"] == NSOrderedSame){
    return [ARGitFetcher fetcher];
  }else if([scheme caseInsensitiveCompare:@"https"] == NSOrderedSame && [[url pathExtension] caseInsensitiveCompare:@"git"] == NSOrderedSame){
    return [ARGitFetcher fetcher];
  }else if([scheme caseInsensitiveCompare:@"file"] == NSOrderedSame && [[url pathExtension] caseInsensitiveCompare:@"git"] == NSOrderedSame){
    return [ARGitFetcher fetcher];
  }else if([scheme caseInsensitiveCompare:@"git"] == NSOrderedSame){
    return [ARGitFetcher fetcher];
  }else if([url isFileURL]){
    return [ARFileFetcher fetcher];
  }
  
  return nil;
}

/**
 * Create a new fetcher
 */
+(id)fetcher {
  return [[[self alloc] init] autorelease];
}

/**
 * Fetch
 */
-(BOOL)fetchContentsOfURL:(NSURL *)url destination:(NSString *)destination progress:(ARFetcherProgressBlock)progress error:(NSError **)error {
  return TRUE;
}

@end

