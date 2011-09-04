//
//  DALocationFetcher.m
//
//  Created by David Schiefer on 04.09.11.
//  Copyright 2011 WriteIt! Studios. All rights reserved.
//  This class may be used in any project as long as you leave this header intact.

#import "DALocationFetcher.h"

@interface DALocationFetcher (Private)

- (void)_stopSearching;
- (BOOL)_locationKnown;

@end

@implementation DALocationFetcher

@synthesize currentLocation;

- (id)init 
{
    if (self = [super init]) 
	{
        self.currentLocation = [[CLLocation alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [self locateDevice];
    }
	
    return self;
}

- (void)locateDevice 
{
    [locationManager startUpdatingLocation];
	
	if ([[self delegate] respondsToSelector:@selector(didStartLookingForDeviceLocation:)])
	{
		[[self delegate] didStartLookingForDeviceLocation:self];
	}
}

- (void)cancel
{
	[self _stopSearching];
	
	if ([self _locationKnown] == NO)
	{
		if ([[self delegate] respondsToSelector:@selector(didFailToDiscoverLocation:error:)])
		{
			[[self delegate] didFailToDiscoverLocation:self error:[NSError errorWithDomain:kDAErrorDomain code:kOperationErrorCancelled userInfo:[NSDictionary dictionaryWithObject:@"The operation was cancelled with no results." forKey:NSLocalizedDescriptionKey]]];
		}
	}	
}
		 		 
		
- (void)_stopSearching 
{
    [locationManager stopUpdatingLocation];
}

- (BOOL)_locationKnown 
{ 
	if (round(currentLocation.speed) == -1)
	{
		return NO;
	}
	else
	{
		return YES; 
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //if the time interval returned from core location is more than two minutes we ignore it because it might be from an old session
    if ( abs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 120) {     
        self.currentLocation = newLocation;
		
		geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
		geoCoder.delegate = self;
		[geoCoder start];
    }
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	if ([[self delegate] respondsToSelector:@selector(didFindDeviceLocation:location:)])
	{
		[[self delegate] didFindDeviceLocation:self location:placemark];
	}
	else
	{
		//this delegate is required - so we'll raise an exception
		[NSException exceptionWithName:@"didFindDeviceLocation:location_MISSING" reason:@"didFindDeviceLocation:location is not implemented!" userInfo:nil];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{    
	if ([[self delegate] respondsToSelector:@selector(didFailToDiscoverLocation:error:)])
	{
		[[self delegate] didFailToDiscoverLocation:self error:[NSError errorWithDomain:kDAErrorDomain code:kOperationErrorLocationUnavailable userInfo:[NSDictionary dictionaryWithObject:[error localizedDescription] forKey:NSLocalizedDescriptionKey]]];
	}
}
	
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([[self delegate] respondsToSelector:@selector(didFailToDiscoverLocation:error:)])
	{
		[[self delegate] didFailToDiscoverLocation:self error:[NSError errorWithDomain:kDAErrorDomain code:kOperationErrorFormattedLocationUnavailable userInfo:[NSDictionary dictionaryWithObject:[error localizedDescription] forKey:NSLocalizedDescriptionKey]]];
	}
}
	 
- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
	[_delegate retain];
}

- (id)delegate
{
	return _delegate;
}

-(void) dealloc 
{
	[geoCoder cancel];
	[geoCoder setDelegate:nil];
	[geoCoder release];
	
	self.currentLocation = nil;
	
	[locationManager setDelegate:nil];
    [locationManager release];
	
    [currentLocation release];
	[_delegate release];
    [super dealloc];
}

@end
