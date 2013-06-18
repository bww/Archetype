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

#import "ARDescriptor.h"
#import "ARParameter.h"
#import "JSONKit.h"

NSString * const kARDescriptorStandardResourcePath = @"archetype.json";

@implementation ARDescriptor

@synthesize name = _name;
@synthesize parameters = _parameters;

/**
 * Create a descriptor from the provided resource
 */
+(ARDescriptor *)descriptorWithContentsOfURL:(NSURL *)url error:(NSError **)error {
  return [[(ARDescriptor *)[self alloc] initWithContentsOfURL:url error:error] autorelease];
}

/**
 * Clean up
 */
-(void)dealloc {
  [_descriptor release];
  [_parameters release];
  [super dealloc];
}

/**
 * Initialize
 */
-(id)initWithContentsOfURL:(NSURL *)url error:(NSError **)error {
  if((self = [super init]) != nil){
    NSError *inner = nil;
    
    NSData *data;
    if((data = [NSData dataWithContentsOfURL:url options:0 error:&inner]) == nil){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not read archetype descriptor");
      goto error;
    }
    
    NSDictionary *descriptor;
    if((descriptor = [data objectFromJSONDataWithParseOptions:JKParseOptionNone error:&inner]) == nil){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not parse archetype descriptor");
      goto error;
    }else if(![descriptor isKindOfClass:[NSDictionary class]]){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Archetype descriptor must be an object");
      goto error;
    }
    
    NSString *name;
    if((name = [descriptor objectForKey:@"name"]) == nil || ![name isKindOfClass:[NSString class]] || [name length] < 1){
      if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Archetype descriptor property 'name' is required and must be a string");
      goto error;
    }
    
    NSArray *parameters;
    if((parameters = [self parametersFromDescriptor:descriptor error:&inner]) == nil){
      if(error) *error = NSERROR_WITH_CAUSE(ARArchetypeErrorDomain, ARStatusError, inner, @"Could not load archetype parameters");
      goto error;
    }
    
    _name = [name retain];
    _parameters = [parameters retain];
    _descriptor = [descriptor retain];
    
  }
  return self;
error:
  [self release]; return nil;
}

/**
 * Obtain parameters from the provided descriptor
 */
-(NSArray *)parametersFromDescriptor:(NSDictionary *)descriptor error:(NSError **)error {
  NSMutableArray *parameters = [NSMutableArray array];
  
  NSArray *parameterDescriptors;
  if((parameterDescriptors = [descriptor objectForKey:@"parameters"]) != nil){
    for(NSDictionary *parameterDescriptor in parameterDescriptors){
      NSString *identifier = nil, *name = nil;
      ARParameterOptions options = kARParameterOptionNone;
      id value;
      
      if(![parameterDescriptor isKindOfClass:[NSDictionary class]]){
        if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Parameter descriptor must be an object with the properties: 'id', 'name'");
        return nil;
      }
      
      if((identifier = [parameterDescriptor objectForKey:@"id"]) == nil || ![identifier isKindOfClass:[NSString class]] || [identifier length] < 1){
        if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Parameter descriptor property 'id' is required and must be a string");
        return nil;
      }
      
      if((name = [parameterDescriptor objectForKey:@"name"]) == nil || ![name isKindOfClass:[NSString class]] || [name length] < 1){
        if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Parameter descriptor property 'name' is required and must be a string");
        return nil;
      }
      
      if((value = [parameterDescriptor objectForKey:@"secure"]) != nil){
        if([value isKindOfClass:[NSNumber class]]){
          options |= kARParameterOptionSecure;
        }else if([value boolValue]){
          if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Parameter descriptor property 'secure' must be a boolean");
          return nil;
        }
      }
      
      [parameters addObject:[ARParameter parameterWithIdentifier:identifier name:name options:options]];
    }
  }
  
  return parameters;
}

@end

