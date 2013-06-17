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
#import "ARUtility.h"

#import "ARGenerator.h"
#import "ARDescriptor.h"
#import "ARParameter.h"

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
    { "define",           required_argument,  NULL,         'D' },  // define a property
    { "force",            no_argument,        NULL,         'f' },  // force overwrite
    { "debug",            no_argument,        NULL,         'd' },  // debug mode
    { "verbose",          no_argument,        NULL,         'v' },  // be more verbose
    { "help",             no_argument,        NULL,         'h' },  // display help info
    { NULL,               0,                  NULL,          0  }
  };
  
  int flag;
  while((flag = getopt_long(argc, (char **)argv, "D:fdvh", longopts, NULL)) != -1){
    switch(flag){
      
      case 'D':
        [config setPropertyWithKeyValueDescriptor:[NSString stringWithUTF8String:optarg]];
        break;
        
      case 'f':
        context.options |= kAROptionForce;
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
  
  if(argc < 2){
    ARUsage(stderr);
    goto error;
  }
  
  NSString *source = [NSString stringWithUTF8String:argv[0]];
  NSURL *sourceURL = [ARFetcher URLForResource:source];
  NSString *output = [NSString stringWithUTF8String:argv[1]];
  NSURL *outputURL = [NSURL fileURLWithPath:output];
  
  ARFetcher *fetcher;
  if((fetcher = [ARFetcher fetcherForURL:sourceURL]) == nil){
    ARLog(@"error: Resource type is not supported: %@", source);
    goto error;
  }
  
  BOOL exists, directory;
  if((exists = [[NSFileManager defaultManager] fileExistsAtPath:[outputURL path] isDirectory:&directory]) && (context.options & kAROptionForce) != kAROptionForce){
    ARLog(@"error: Output path exists. If you really intend to overwrite this path use the -f | --force option.");
    goto error;
  }else if(exists & !directory){
    ARLog(@"error: Output path exists but it is not a directory.");
    goto error;
  }else if(exists && ![[NSFileManager defaultManager] removeItemAtURL:outputURL error:&error]){
    ARErrorDisplayError(error, @"Could not create remove existing output directory");
    goto error;
  }else if(![[NSFileManager defaultManager] createDirectoryAtURL:outputURL withIntermediateDirectories:TRUE attributes:nil error:&error]){
    ARErrorDisplayError(error, @"Could not create output directory");
    goto error;
  }
  
  if((workingDirectory = ARPathMakeWorkingDirectory()) == nil){
    ARLog(@"error: Could not create working directory");
    goto error;
  }
  
  NSString *templateDirectory = [workingDirectory stringByAppendingPathComponent:@"template"];
  if(![fetcher fetchContentsOfURL:sourceURL destination:templateDirectory progress:NULL error:&error]){
    ARErrorDisplayError(error, @"Could not fetch archetype");
    goto error;
  }
  
  NSString *descriptorPath = [templateDirectory stringByAppendingPathComponent:kARDescriptorStandardResourcePath];
  if(![[NSFileManager defaultManager] fileExistsAtPath:descriptorPath]){
    ARLog(@"error: Archetype does not contain a descriptor named '%@'", kARDescriptorStandardResourcePath);
    goto error;
  }
  
  ARDescriptor *descriptor;
  if((descriptor = [ARDescriptor descriptorWithContentsOfURL:[NSURL fileURLWithPath:descriptorPath] error:&error]) == nil){
    ARErrorDisplayError(error, @"Could not load descriptor");
    goto error;
  }
  
  for(ARParameter *parameter in descriptor.parameters){
    NSString *value;
    if((value = [config propertyForKey:parameter.identifier]) == nil || [value length] < 1){
      [config collectPropertyForParameter:parameter];
    }
  }
  
  if((context.options & kAROptionDebug) == kAROptionDebug){
    for(id key in config.properties){
      ARLog(@"%@ = %@", key, [config propertyForKey:key]);
    }
  }
  
  ARGenerator *generator = [ARGenerator generatorWithDescriptor:descriptor configuration:config];
  if(![generator generateWithSourceURL:[NSURL fileURLWithPath:templateDirectory] outputURL:outputURL error:&error]){
    ARErrorDisplayError(error, @"Could not generate project");
    goto error;
  }
  
error:
  if(workingDirectory) ARPathDeleteWorkingDirectory(workingDirectory);
  
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
    "Usage: archetype [options] <url> <path>\n"
    " Help: man archetype\n"
    "\n"
    "Options:\n"
    " -D --define <key>=<value>     Define a configuration parameter.\n"
    " -f --force                    Overwrite the output path even if it exists.\n"
    " -v --verbose                  Be more verbose.\n"
    " -h --help                     Display this help information.\n"
    "\n"
    "Example:\n"
    " $ archetype git@github.com/user/project.git ./my_project\n"
    "\n"
  , stream);
}

