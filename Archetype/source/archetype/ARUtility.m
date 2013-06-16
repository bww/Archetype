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

#import "ARUtility.h"

/**
 * Create a working directory.
 */
NSString * ARPathMakeWorkingDirectory(void) {
  
  NSString *tempDirectory;
  if((tempDirectory = NSTemporaryDirectory()) == nil) tempDirectory = @"/tmp";
  NSString *tempTemplate = [tempDirectory stringByAppendingPathComponent: @"Archetype.XXXXXX"];
  
  char *cTempTemplate = strdup([tempTemplate UTF8String]);
  NSString *workingDirectory = [NSString stringWithUTF8String:mkdtemp(cTempTemplate)];
  if(cTempTemplate) free(cTempTemplate);
  
  return workingDirectory;
}

/**
 * Delete the working directory if it exists
 */
void ARPathDeleteWorkingDirectory(NSString *workingDirectory) {
  [[NSFileManager defaultManager] removeItemAtPath:workingDirectory error:nil];
}

