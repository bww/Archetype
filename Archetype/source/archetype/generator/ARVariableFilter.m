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

#import "ARVariableFilter.h"

@implementation ARVariableFilter

/**
 * Filter content
 */
-(NSString *)filter:(NSString *)content configuration:(ARConfig *)config error:(NSError **)error {
  NSLog(@"==> %@", content);
  NSMutableString *output = [NSMutableString string];
  NSUInteger length = [content length];
  
  CFStringInlineBuffer buffer;
  CFStringInitInlineBuffer((CFStringRef)content, &buffer, CFRangeMake(0, length));
# define GETCHAR(i) CFStringGetCharacterFromInlineBuffer(&buffer, (i))
# define ADD_ESC(i) { for(NSUInteger e = 0; e < (i); e++){ CFStringAppendCharacters((CFMutableStringRef)output, &echar, 1); } }
  NSUInteger esc = 0;
  UniChar echar = '\\';
  
  for(NSUInteger i = 0; i < length; i++){
    UniChar c = GETCHAR(i);
    if(c == echar){
      esc++;
    }else if(c == '$' && (i + 1) < length && GETCHAR(i + 1) == '{'){
      if((esc & 2) == 0){
        if(esc > 0) ADD_ESC(esc / 2); esc = 0;
        
        NSUInteger v;
        for(v = i + 2; v < length; v++){ if(GETCHAR(v) == '}') break; }
        NSString *ident = [[content substringWithRange:NSMakeRange(i + 2 /* skip '${' */, v - i - 2 /* compensate */)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *value;
        if((value = [config propertyForKey:ident]) != nil){
          [output appendString:value];
        }else{
          if(error) *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Property '%@' is not defined in configuration. Did you mean to escape this property expression? Use '\\${ %@ }' for a the literal text '${'...", ident, ident);
          goto error;
        }
        
        i = v;
      }else{
        if(esc > 0) ADD_ESC((esc - 1) / 2); esc = 0;
        CFStringAppendCharacters((CFMutableStringRef)output, &c, 1);
      }
    }else{
      if(esc > 0) ADD_ESC(esc); esc = 0;
      CFStringAppendCharacters((CFMutableStringRef)output, &c, 1);
    }
  }
  
  return output;
error:
  return nil;
}

/**
 * Match ahead for a substring.
 */
-(BOOL)matchAhead:(NSString *)match contentBuffer:(CFStringInlineBuffer *)contentBuffer location:(NSUInteger)location length:(NSUInteger)length {
  
  NSUInteger matchLength;
  if((matchLength = [match length]) > (length - location)) return FALSE;
  
  CFStringInlineBuffer matchBuffer;
  CFStringInitInlineBuffer((CFStringRef)match, &matchBuffer, CFRangeMake(location, matchLength));
  
  for(NSUInteger i = 0; i < matchLength; i++){
    if(CFStringGetCharacterFromInlineBuffer(contentBuffer, location + i) != CFStringGetCharacterFromInlineBuffer(&matchBuffer, i)){
      return FALSE;
    }
  }
  
  return TRUE;
}

@end

