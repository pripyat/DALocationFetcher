//
//  DALocationFetcher.m
//
//  Created by David Schiefer on 04.09.11.
//  Copyright 2011 WriteIt! Studios. All rights reserved.
//  This class may be used in any project as long as you leave this header intact.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kDAErrorDomain @"DALocationFetcherErrorDomain"

typedef enum 
{
	kOperationErrorCancelled = 1,
	kOperationErrorLocationUnavailable = 2,
	kOperationErrorFormattedLocationUnavailable = 3
} DALocationFetcherErrorCodes;

@interface DALocationFetcher : NSObject <CLLocationManagerDelegate,MKReverseGeocoderDelegate>
{
	@private
	CLLocationManager *locationManager;
    CLLocation *currentLocation;
	MKReverseGeocoder *geoCoder;
	id _delegate;
}

- (void)setDelegate:(id)delegate;
/*!
 @method setDelegate:
 @param Your object that will act as the class's delegate.
 @abstract
 Sets the object as the class's delegate receiver.
 @discussion
 Sets the object as the class's delegate receiver.
 */
- (id)delegate;
/*!
 @method delegate
 @abstract
 Returns the current delegate.
 @discussion
 Returns the current delegate associated with this class. May return null if not set.
 */
- (void)locateDevice;
/*!
 @method locateDevice
 @abstract
 Starts the location process.
 @discussion
 Starts the location process. Will post didStartLookingForDeviceLocation: to its delegate after starting.
 */
- (void)cancel;
/*!
 @method cancel
 @abstract
 Cancels the location process.
 @discussion
 Cancels the location process. Will post didFailToDiscoverLocation:error: to its delegate if no location has been found already.
 */
@property (nonatomic, retain) CLLocation *currentLocation;
/*!
 @property currentLocation
 @abstract
 Returns the current location.
 @discussion
 Returns the current location as a CLLocation object.
 */
@end

@protocol DALocationFetcherDelegate

@required
- (void)didFindDeviceLocation:(DALocationFetcher *)fetcher location:(MKPlacemark *)location;

@optional
- (void)didStartLookingForDeviceLocation:(DALocationFetcher *)fetcher;
- (void)didFailToDiscoverLocation:(DALocationFetcher *)fetcher error:(NSError *)error;

@end
