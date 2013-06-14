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

enum {
  kAROptionNone     = 0,
  kAROptionVerbose  = 1 << 0,
  kAROptionDebug    = 1 << 1
};

typedef unsigned int AROptions;

/**
 * Archetype context. A context defines the parameters for generating a project
 */
@interface ARContext : NSObject {
  
  NSString  * _outputPath;
  AROptions   _options;
  
}

+(id)context;

@property (readonly) NSString * outputPath;
@property (readonly) AROptions  options;

@end

/**
 * Mutable context
 */
@interface ARMutableContext : ARContext

-(void)setOutputPath:(NSString *)outputPath;
-(void)setOptions:(AROptions)options;

@end

