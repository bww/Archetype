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

#import <Git2/git2.h>
#import <pwd.h>

#import "ARGitFetcher.h"

typedef struct {
  ARFetcherProgressBlock  progress_block;
  git_transfer_progress   fetch_progress;
  size_t                  completed_steps;
  size_t                  total_steps;
  const char            * path;
} ARGitProgressInfo;

/**
 * Display progress
 */
static void ARGitFetcherReportProgress(const ARGitProgressInfo *info) {
  if(info->progress_block != NULL){
    double network_percent = (double)info->fetch_progress.received_objects / (double)info->fetch_progress.total_objects;
    double index_percent = (double)info->fetch_progress.indexed_objects / (double)info->fetch_progress.total_objects;
    double checkout_percent = info->total_steps > 0 ? (double)info->completed_steps / (double)info->total_steps : 0.0f;
    info->progress_block((index_percent + checkout_percent) / 2.0, info->fetch_progress.received_bytes);
  }
}

/**
 * Checkout progress
 */
static void ARGitFetcherCheckoutProgressCallBack(const char *path, size_t current, size_t total, void *data) {
  ARGitProgressInfo *info = (ARGitProgressInfo*)data;
  info->completed_steps = current;
  info->total_steps = total;
  info->path = path;
  ARGitFetcherReportProgress(info);
}

/**
 * Fetch progress
 */
static int ARGitFetcherFetchProgressCallBack(const git_transfer_progress *stats, void *data) {
  ARGitProgressInfo *info = (ARGitProgressInfo*)data;
  info->fetch_progress = *stats;
  ARGitFetcherReportProgress(info);
  return 0;
}

/**
 * Credentials
 */
static int ARGitFetcherAcquireCredentialsCallBack(git_cred **credentials, const char *url, const char *username_from_url, unsigned int allowed_types, void *data) {
  printf("Credentials are required for: %s\n", url);
  
  int maxlen = _PASSWORD_LEN;
  char username[maxlen + 1], *password;
  
  if(username_from_url){
    printf("Username [%s]: ", username_from_url);
  }else{
    printf("Username: ");
  }
  
  if(fgets(username, maxlen, stdin) == NULL){
    return -1;
  }
  
  if(strlen(username) < 2 /* one character plus newline */){
    if(username_from_url != NULL && strlen(username_from_url) < maxlen){
      strcpy(username, username_from_url);
    }else{
      return -1;
    }
  }else{
    username[strlen(username) - 1] = 0; // trim off '\n'
  }
  
  if((password = getpass("Password: ")) == NULL || strlen(password) < 1){
    return -1;
  }
  
  return git_cred_userpass_plaintext_new(credentials, username, password);
}

@implementation ARGitFetcher

/**
 * Fetch
 */
-(BOOL)fetchContentsOfURL:(NSURL *)url destination:(NSString *)destination progress:(ARFetcherProgressBlock)progress error:(NSError **)error {
  git_repository *clone = NULL;
  BOOL status = FALSE;
  int z;
  
  git_clone_options clone_opts = GIT_CLONE_OPTIONS_INIT;
  git_checkout_opts checkout_opts = GIT_CHECKOUT_OPTS_INIT;
  
  ARGitProgressInfo info;
  bzero(&info, sizeof(ARGitProgressInfo));
  info.progress_block = progress;
  
  checkout_opts.checkout_strategy = GIT_CHECKOUT_SAFE_CREATE;
  checkout_opts.progress_cb = ARGitFetcherCheckoutProgressCallBack;
  checkout_opts.progress_payload = &info;
  
  clone_opts.checkout_opts = checkout_opts;
  clone_opts.fetch_progress_cb = ARGitFetcherFetchProgressCallBack;
  clone_opts.fetch_progress_payload = &info;
  clone_opts.cred_acquire_cb = ARGitFetcherAcquireCredentialsCallBack;
  
  fputs("Fetching archetype...\n", stdout);
  
  if((z = git_clone(&clone, [[url absoluteString] UTF8String], [destination UTF8String], &clone_opts)) != 0){
    const git_error *giterr = giterr_last();
    if(error){
      if(giterr){
        *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Could not checkout repository: %s", giterr->message);
      }else{
        *error = NSERROR(ARArchetypeErrorDomain, ARStatusError, @"Could not checkout repository");
      }
    }
    goto error;
  }
  
  fputc('\n', stdout);
  
  status = TRUE;
error:
  if(clone) git_repository_free(clone);
  
  return status;
}

@end

