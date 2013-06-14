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

#import <getopt.h>

#import "ARContext.h"

int   ARRun(int argc, const char * argv[]);
void  ARUsage(FILE *stream);

/**
 * Main.
 */
int main(int argc, const char * argv[]) {
  @autoreleasepool {
    ARRun(argc, argv);
  }
  return 0;
}

/**
 * Run Archetype.
 */
int ARRun(int argc, const char * argv[]) {
  ARMutableContext *context = [ARMutableContext context];
  
  static struct option longopts[] = {
    { "output",           required_argument,  NULL,         'o' },  // base path for output
    { "debug",            no_argument,        NULL,         'D' },  // debug mode
    { "verbose",          no_argument,        NULL,         'v' },  // be more verbose
    { "help",             no_argument,        NULL,         'h' },  // display help info
    { NULL,               0,                  NULL,          0  }
  };
  
  int flag;
  while((flag = getopt_long(argc, (char **)argv, "o:Dvh", longopts, NULL)) != -1){
    switch(flag){
      
      case 'o':
        context.outputPath = [NSString stringWithUTF8String:optarg];
        break;
        
      case 'D':
        context.options |= kAROptionDebug;
        break;
        
      case 'v':
        context.options |= kAROptionVerbose;
        break;
        
      case 'h':
        ARUsage(stderr);
        return 0;
        
      default:
        ARUsage(stderr);
        return 0;
        
    }
  }
  
  argv += optind;
  argc -= optind;
  
  if(argc < 1){
    ARUsage(stderr);
    return 0;
  }
  
  return 0;
}

/**
 * Display brief usage information
 */
void ARUsage(FILE *stream) {
  fputs(
    "Archetype - a parameterized project template generator\n"
    "Copyright 2013 Brian William Wolter\n"
    "\n"
    "Usage: archetype [options] <url>\n"
    " Help: man archetype\n"
    "\n"
    "Options:\n"
    " -o --output <path>            Specify the output directory for the generated project.\n"
    " -v --verbose                  Be more verbose.\n"
    " -h --help                     Display this help information.\n"
    "\n"
    "Example:\n"
    " $ archetype -o my_project git@github.com/user/project.git\n"
    "\n"
  , stream);
}

