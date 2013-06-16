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
#import "ARConfig.h"
#import "ARFetcher.h"
#import "ARDescriptor.h"
#import "ARUtility.h"

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
  NSString *workingDirectory = nil;
  ARConfig *config = [ARConfig config];
  NSError *error = nil;
  
  static struct option longopts[] = {
    { "output",           required_argument,  NULL,         'o' },  // base path for output
    { "define",           required_argument,  NULL,         'D' },  // define a property
    { "debug",            no_argument,        NULL,         'd' },  // debug mode
    { "verbose",          no_argument,        NULL,         'v' },  // be more verbose
    { "help",             no_argument,        NULL,         'h' },  // display help info
    { NULL,               0,                  NULL,          0  }
  };
  
  int flag;
  while((flag = getopt_long(argc, (char **)argv, "o:D:dvh", longopts, NULL)) != -1){
    switch(flag){
      
      case 'o':
        context.outputPath = [NSString stringWithUTF8String:optarg];
        break;
        
      case 'D':
        [config setPropertyWithKeyValueDescriptor:[NSString stringWithUTF8String:optarg]];
        break;
        
      case 'd':
        context.options |= kAROptionDebug;
        __ARSetLogLevel(MAX(__ARGetLogLevel(), kARLogLevelDebug));
        break;
        
      case 'v':
        context.options |= kAROptionVerbose;
        __ARSetLogLevel(MAX(__ARGetLogLevel(), kARLogLevelVerbose));
        break;
        
      case 'h':
        ARUsage(stderr);
        goto error;
        
      default:
        ARUsage(stderr);
        goto error;
        
    }
  }
  
  argv += optind;
  argc -= optind;
  
  if(argc < 1){
    ARUsage(stderr);
    goto error;
  }
  
  NSString *source = [NSString stringWithUTF8String:argv[0]];
  NSURL *url = [ARFetcher URLForResource:source];
  
  ARFetcher *fetcher;
  if((fetcher = [ARFetcher fetcherForURL:url]) == nil){
    ARLog(@"error: Resource type is not supported: %@", source);
    goto error;
  }
  
  if((workingDirectory = ARPathMakeWorkingDirectory()) == nil){
    ARLog(@"error: Could not create working directory");
    goto error;
  }
  
  NSString *templateDirectory = [workingDirectory stringByAppendingPathComponent:@"template"];
  if(![fetcher fetchContentsOfURL:url destination:templateDirectory progress:NULL error:&error]){
    ARErrorDisplayError(error, @"Could not fetch archetype");
    goto error;
  }
  
  NSString *descriptorPath = [templateDirectory stringByAppendingPathComponent:@"archetype.json"];
  if(![[NSFileManager defaultManager] fileExistsAtPath:descriptorPath]){
    ARLog(@"error: Archetype does not contain a descriptor named 'archetype.json'");
    goto error;
  }
  
  ARDescriptor *descriptor;
  if((descriptor = [ARDescriptor descriptorWithContentsOfURL:[NSURL fileURLWithPath:descriptorPath] error:&error]) == nil){
    ARErrorDisplayError(error, @"Could not load descriptor");
    goto error;
  }
  
  ARLog(@"%@", descriptor.name);
  
  for(ARParameter *parameter in descriptor.parameters){
    [config collectPropertyForParameter:parameter];
  }
  
error:
  if(workingDirectory) NSLog(@"WORKING: %@", workingDirectory); //ARPathDeleteWorkingDirectory(workingDirectory);
  
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

