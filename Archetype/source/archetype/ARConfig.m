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

#import "ARConfig.h"

@implementation ARConfig

@synthesize archetype = _archetype;
@synthesize properties = _properties;

/**
 * Create a configuration
 */
+(ARConfig *)config {
  return [[[self alloc] init] autorelease];
}

/**
 * Clean up
 */
-(void)dealloc {
  [_archetype release];
  [_properties release];
  [super dealloc];
}

/**
 * Initialize
 */
-(id)init {
  if((self = [super init]) != nil){
    _properties = [[NSMutableDictionary alloc] init];
  }
  return self;
}

/**
 * Obtain a configuration property for the provided key
 */
-(NSString *)propertyForKey:(NSString *)key {
  return [_properties objectForKey:key];
}

/**
 * Set a configuration property for the provided key
 */
-(void)setProperty:(NSString *)value forKey:(NSString *)key {
  [_properties setObject:value forKey:key];
}

/**
 * Set a configuration property with a key/value pair. The provided string
 * is formatted as "key=value". Whitespace surrounding the key and value is
 * trimmed off.
 */
-(void)setPropertyWithKeyValueDescriptor:(NSString *)pair {
  NSRange range;
  if((range = [pair rangeOfString:@"="]).location != NSNotFound && range.location > 0){
    [self setProperty:[[pair substringWithRange:NSMakeRange(range.location + range.length, [pair length] - range.location - range.length)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:[[pair substringWithRange:NSMakeRange(0, range.location)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
  }else{
    [self removePropertyForKey:pair];
  }
}

/**
 * Remove the property for the provided key
 */
-(void)removePropertyForKey:(NSString *)key {
  [_properties removeObjectForKey:key];
}

@end

