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
// THE SOFTWARE IS PROVIDED "AR IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
// 

#import "ARError.h"

/**
 * Display an error
 */
void ARErrorDisplayError(NSError *error, NSString *format, ...) {
  
  // display our message
  if(format != nil){
    va_list ap;
    va_start(ap, format);
    fputs("error: ", stderr);
    fputs([[[[NSString alloc] initWithFormat:format arguments:ap] autorelease] UTF8String], stderr);
    fputc('\n', stderr);
    va_end(ap);
  }
  
  // display the error backtrace
  ARErrorDisplayBacktrace(error);
  
}

/**
 * Display an error backtrace
 */
void ARErrorDisplayBacktrace(NSError *error) {
  
# if defined(__ARCHETYPE_DEBUG__)
  NSString *prettyFunction;
  if((prettyFunction = [[error userInfo] objectForKey:ARSourceFunctionErrorKey]) != nil){
    NSString *filename = [[error userInfo] objectForKey:ARSourceFileErrorKey];
    ARLog(@"       at: %@ (%@:%@)", prettyFunction, [filename lastPathComponent], [[error userInfo] objectForKey:ARSourceLineNumberErrorKey]);
  }
# endif
  
  // display the error message
  ARLog(@"  because: %@", [error localizedDescription]);
  
  // if the error has a related file, display it
  NSString *path;
  if((path = [[error userInfo] objectForKey:NSFilePathErrorKey]) != nil){
    ARLog(@"     file: %@", path);
  }
  
  // if the error has a related URL, display it
  NSURL *url;
  if((url = [[error userInfo] objectForKey:NSURLErrorKey]) != nil){
    if([url isFileURL]){
      ARLog(@"     file: %@", [url path]);
    }else{
      ARLog(@"      URL: %@", [url absoluteString]);
    }
  }
  
  // if the error has a cause, recurse
  NSError *cause;
  if((cause = [[error userInfo] objectForKey:NSUnderlyingErrorKey]) != nil && ![cause isEqual:error]){
    ARErrorDisplayBacktrace(cause);
  }
  
}


