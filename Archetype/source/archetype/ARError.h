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

typedef enum {
  ARStatusOk            =  0,
  ARStatusError         = -1,
  ARStatusCount
} ARStatus;

#define ARArchetypeException        @"ARArchetypeException"
#define ARArchetypeErrorDomain      @"ARArchetypeErrorDomain"

#define ARSourceFunctionErrorKey    @"ARSourceFunctionErrorKey"
#define ARSourceFileErrorKey        @"ARSourceFileErrorKey"
#define ARSourceLineNumberErrorKey  @"ARSourceLineNumberErrorKey"

/** Create an NSError the easy way */
#if !defined(NSERROR)
#define NSERROR(d, c, m...) \
  [NSError errorWithDomain:(d) code:(c) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:  \
    [NSString stringWithFormat:m],                        NSLocalizedDescriptionKey,          \
    [NSString stringWithUTF8String:__PRETTY_FUNCTION__],  ARSourceFunctionErrorKey,           \
    [NSString stringWithUTF8String:__FILE__],             ARSourceFileErrorKey,               \
    [NSNumber numberWithInt:__LINE__],                    ARSourceLineNumberErrorKey,         \
    nil]]
#endif

/** Create an NSError the easy way */
#if !defined(NSERROR_WITH_FILE)
#define NSERROR_WITH_FILE(d, c, p, m...) \
  [NSError errorWithDomain:(d) code:(c) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:  \
    [NSString stringWithFormat:m],                        NSLocalizedDescriptionKey,          \
    (p),                                                  NSFilePathErrorKey,                 \
    [NSString stringWithUTF8String:__PRETTY_FUNCTION__],  ARSourceFunctionErrorKey,           \
    [NSString stringWithUTF8String:__FILE__],             ARSourceFileErrorKey,               \
    [NSNumber numberWithInt:__LINE__],                    ARSourceLineNumberErrorKey,         \
    nil]]
#endif

/** Create an NSError the easy way */
#if !defined(NSERROR_WITH_URL)
#define NSERROR_WITH_URL(d, c, u, m...) \
  [NSError errorWithDomain:(d) code:(c) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:  \
    [NSString stringWithFormat:m],                        NSLocalizedDescriptionKey,          \
    (u),                                                  NSURLErrorKey,                      \
    [NSString stringWithUTF8String:__PRETTY_FUNCTION__],  ARSourceFunctionErrorKey,           \
    [NSString stringWithUTF8String:__FILE__],             ARSourceFileErrorKey,               \
    [NSNumber numberWithInt:__LINE__],                    ARSourceLineNumberErrorKey,         \
    nil]]
#endif

/** Create an NSError the easy way */
#if !defined(NSERROR_WITH_CAUSE)
#define NSERROR_WITH_CAUSE(d, c, r, m...) \
  [NSError errorWithDomain:(d) code:(c) userInfo:[NSDictionary dictionaryWithObjectsAndKeys:  \
    [NSString stringWithFormat:m],                        NSLocalizedDescriptionKey,          \
    (r),                                                  NSUnderlyingErrorKey,               \
    [NSString stringWithUTF8String:__PRETTY_FUNCTION__],  ARSourceFunctionErrorKey,           \
    [NSString stringWithUTF8String:__FILE__],             ARSourceFileErrorKey,               \
    [NSNumber numberWithInt:__LINE__],                    ARSourceLineNumberErrorKey,         \
    nil]]
#endif

void ARErrorDisplayError(NSError *error, NSString *format, ...);
void ARErrorDisplayBacktrace(NSError *error);

