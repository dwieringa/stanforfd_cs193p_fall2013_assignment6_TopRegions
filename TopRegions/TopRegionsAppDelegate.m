//
//  TopRegionsAppDelegate.m
//  TopRegions
//
//  Created by David Wieringa on 4/17/14.
//  Copyright (c) 2014 Userwise Solutions. All rights reserved.
//

#import "TopRegionsAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@end

// name of the Flickr fetching background download session
#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"

// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

// how long we'll wait for a Flickr fetch to return when we're in the background
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@implementation TopRegionsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Obtain UIManagedContext (via UIManagedDocument)
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSString *documentName = @"MyDocument";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"couldn't open document at %@", url);
        }];
    } else {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            else NSLog(@"couldn't create document at %@", url);
        }];
    }

    
    // Override point for customization after application launch.
    return YES;
}

- (void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        self.photoDatabaseContext = self.document.managedObjectContext;
        [self startPhotoFetch];
    } else {
        NSLog(@"trouble in documentIsReady. Check/handle document states");
    }
}

- (void)startPhotoFetch
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // start the spinner
    NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSData *jsonResult = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResult
                                                                            options:0
                                                                              error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Flickr results = %@", propertyListResults);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // stop the spinner
            [Photo loadPhotosFromFlickrArray:[propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS]
                    intoManagedObjectContext:self.photoDatabaseContext];
        });
    });
}

- (void)startPhotoFetch:(NSTimer *)timer
{
    [self startPhotoFetch];
}

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    
    // every time the context changes, we'll restart our timer
    // so kill (invalidate) the current one
    // (we didn't get to this line of code in lecture, sorry!)
    [self.flickrForegroundFetchTimer invalidate];
    self.flickrForegroundFetchTimer = nil;
    
    if (self.photoDatabaseContext) {
        // this timer will fire only when we are in the foreground
        self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                                                           target:self
                                                                         selector:@selector(startPhotoFetch:)
                                                                         userInfo:nil
                                                                          repeats:YES];
    }
    
    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}


#pragma mark BACKGROUND FETCHING

// this is called occasionally by the system WHEN WE ARE NOT THE FOREGROUND APPLICATION
// in fact, it will LAUNCH US if necessary to call this method
// the system has lots of smarts about when to do this, but it is entirely opaque to us

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"BACKGROUND FETCH: performFetchWithCompHndlr");
    if (self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                          completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                              if (error) {
                                                  NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                  completionHandler(UIBackgroundFetchResultNoData);
                                              } else {
                                                  NSLog(@"BACKGROUND FETCH: download complete");
                                                  [self loadFlickrPhotosFromLocalURL:localFile
                                                                         intoContext:self.photoDatabaseContext
                                                                 andThenExecuteBlock:^{
                                                                     completionHandler(UIBackgroundFetchResultNewData);
                                                                     NSLog(@"BACKGROUND FETCH: completed with NewData");
                                                                 }
                                                   ];
                                              }
                                          }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData);
        NSLog(@"BACKGROUND FETCH: completed with NOData (no context)");
    }
}

// gets the Flickr photo dictionaries out of the url and puts them into Core Data
// this was moved here after lecture to give you an example of how to declare a method that takes a block as an argument
// and because we now do this both as part of our background session delegate handler and when background fetch happens
- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                         intoContext:(NSManagedObjectContext *)context
                 andThenExecuteBlock:(void(^)())whenDone
{
    NSLog(@"BACKGROUND FETCH: loading local file");
    if (context) {
        NSDictionary *flickrPropertyList;
        NSData *flickrJSONData = [NSData dataWithContentsOfURL:localFile];  // will block if url is not local!
        if (flickrJSONData) {
            flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                 options:0
                                                                   error:NULL];
        }
        NSArray *photos = [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
}

#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    NSLog(@"BACKGROUND FETCH:URLSession: downloadTask: didFinishDownloadingToURL:");
    // we shouldn't assume we're the only downloading going on ...
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        // ... but if this is the Flickr fetching, then process the returned data
        [self loadFlickrPhotosFromLocalURL:localFile
                               intoContext:self.photoDatabaseContext
                       andThenExecuteBlock:^{
                           [self flickrDownloadTasksMightBeComplete];
                       }
         ];
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

// not required by the protocol, but we should definitely catch errors here
// so that we can avoid crashes
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"BACKGROUND FETCH: URLsession didCompleteWithError");
    if (error && (session == self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
    }
}

// this is "might" in case some day we have multiple downloads going on at once

- (void)flickrDownloadTasksMightBeComplete
{
    NSLog(@"BACKGROUND FETCH: mightBeComplete");
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
            if (![downloadTasks count]) {  // any more Flickr downloads left?
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}


@end
