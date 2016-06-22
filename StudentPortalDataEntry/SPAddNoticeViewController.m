//
//  SPAddNoticeViewController.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 1/24/16.
//  Copyright © 2016 HHZ. All rights reserved.
//

#import "SPAddNoticeViewController.h"
#import "SPDataEntryApi.h"

@interface SPAddNoticeViewController ()

@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *locationTextField;
@property (weak) IBOutlet NSTextField *startTimeHourTextField;
@property (weak) IBOutlet NSTextField *startTimeMinuteTextField;
@property (weak) IBOutlet NSTextField *endTimeHourTextField;
@property (weak) IBOutlet NSTextField *endTimeMinuteTextField;

@property (weak) IBOutlet NSPopUpButton *startTimeIntervalPopUp;
@property (weak) IBOutlet NSPopUpButton *endTimeIntervalPopUp;

@property (weak) IBOutlet NSTextField *descriptionTextField;
@property (weak) IBOutlet NSProgressIndicator *addNoticeProgressIndicator;
@property (weak) IBOutlet NSTextField *startTImeSeperator;
@property (weak) IBOutlet NSTextField *endTimeSeperator;
@property (weak) IBOutlet NSTextField *timeRange;
@property (weak) IBOutlet NSDatePicker *date;
@property (weak) IBOutlet NSTextField *imageNameTextField;
@property (strong, nonatomic) NSData *imageData;
@property (strong, nonatomic) NSString *fileExtension;

@end

@implementation SPAddNoticeViewController

- (void)viewDidLoad {
     
    [self.view setWantsLayer:YES];
    NSColor *color = [NSColor colorWithDeviceRed:0.238f green:0.363f blue:0.438f alpha:1.0f];
    [self.view.layer setBackgroundColor:[color CGColor]];
    [self.startTimeIntervalPopUp removeAllItems];
    [self.endTimeIntervalPopUp removeAllItems];
    
    [self.startTimeIntervalPopUp addItemsWithTitles:@[@"AM", @"PM"]];
    [self.endTimeIntervalPopUp addItemsWithTitles:@[@"AM", @"PM"]];
    
    self.addNoticeProgressIndicator.hidden = YES;
}

- (IBAction)saveClicked:(id)sender {
    
    NSString *title = self.titleTextField.stringValue;
    NSString *location = self.locationTextField.stringValue;
    NSDate *date = self.date.dateValue;
    NSString *startTime = [NSString stringWithFormat:@"%@%@%@", self.startTimeHourTextField.stringValue, self.startTImeSeperator.stringValue, self.startTimeMinuteTextField.stringValue];
    NSString *endTime = [NSString stringWithFormat:@"%@%@%@", self.endTimeHourTextField.stringValue, self.endTimeSeperator.stringValue, self.endTimeMinuteTextField.stringValue];
    NSString *description = self.descriptionTextField.stringValue;
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (![self checkTextFieldError]) {
        
        alert.messageText = @"Missing info";
        alert.informativeText = @"One or more required fields are missing. Please enter all the required information.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self isValidDate:self.date.dateValue]) {
        
        alert.messageText = @"Invalid date";
        alert.informativeText = @"Invalid date is entered. Please check the date entered again.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self isValidTime]) {
        
        alert.messageText = @"Invalid time format";
        alert.informativeText = @"Invalid time format is enterd. Please check the time entered again.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self isValidImageType]) {
        
        alert.messageText = @"Invalid image type";
        alert.informativeText = @"Please choose an image of png or jpg file type.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else {
        
        self.addNoticeProgressIndicator.hidden = NO;
        [self.addNoticeProgressIndicator startAnimation:self];
        
        PFFile *image = [PFFile fileWithName:self.imageNameTextField.stringValue data:self.imageData];
        
        [[SPDataEntryApi sharedInstance] addNotice:title Location:location Date:date StartTime:startTime EndTime:endTime Description:description image:image completion:^(BOOL isNotDuplicate, NSError *error) {
            
            if (error) {
                
                [self.addNoticeProgressIndicator stopAnimation:self];
                self.addNoticeProgressIndicator.hidden = YES;
                
                alert.messageText = @"Error";
                alert.informativeText = @"There was a problem adding the notice. Please try again later.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else if (!isNotDuplicate) {
                
                [self.addNoticeProgressIndicator stopAnimation:self];
                self.addNoticeProgressIndicator.hidden = YES;
                
                alert.messageText = @"Schedule Overlap";
                alert.informativeText = @"There is already an event scheduled for the provided time and date. Please check the information you entered again.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            }else {
                
                [self.addNoticeProgressIndicator stopAnimation:self];
                self.addNoticeProgressIndicator.hidden = YES;
                
                alert.messageText = @"Success";
                alert.informativeText = @"A new notice has been added.";
                alert.alertStyle = NSInformationalAlertStyle;
                [alert runModal];
            }
        }];
    }
}
- (IBAction)browseClicked:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setShowsHiddenFiles:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
       
        if (result == NSFileHandlingPanelOKButton) {
            
            NSURL *imageUrl = [[panel URLs] objectAtIndex:0];
            self.imageData = [[NSFileManager defaultManager] contentsAtPath:[imageUrl path]];
            NSString *unformattedFileDirectoryUrlString = [NSString stringWithFormat:@"%@", imageUrl];
            NSArray *seperatedFileDirectories = [unformattedFileDirectoryUrlString componentsSeparatedByString:@"/"];
            NSString *unformattedFilePathUrlString = seperatedFileDirectories[seperatedFileDirectories.count - 1];
            NSString *formattedFilePathUrlString = [unformattedFilePathUrlString stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            [self.imageNameTextField setStringValue:formattedFilePathUrlString];
            self.fileExtension = [formattedFilePathUrlString componentsSeparatedByString:@"."][1];
            NSLog(@"asdfads");
        }
    }];
}

- (IBAction)clearClicked:(id)sender {
    
    self.titleTextField.stringValue = @"";
    self.locationTextField.stringValue = @"";
    self.startTimeHourTextField.stringValue = @"";
    self.startTimeMinuteTextField.stringValue = @"";
    self.endTimeHourTextField.stringValue = @"";
    self.endTimeMinuteTextField.stringValue = @"";
    self.descriptionTextField.stringValue = @"";
}

- (BOOL)checkTextFieldError {
    
    if (self.titleTextField.stringValue.length == 0 || self.locationTextField.stringValue.length == 0 || self.startTimeHourTextField.stringValue.length == 0 || self.startTimeMinuteTextField.stringValue.length == 0 || self.endTimeHourTextField.stringValue.length == 0 || self.endTimeMinuteTextField.stringValue.length == 0 || self.descriptionTextField.stringValue.length == 0) {
        
        return NO;
        
    } else {
        
        return YES;
    }
}

- (BOOL)isValidDate:(NSDate *)receivedDate {
    
    NSDate *currentDate = [NSDate date];
    if ([receivedDate isEqual:[currentDate earlierDate:receivedDate]]) {
        
        return NO;
        
    } else {
        
        return YES;
    }
}

- (BOOL)isValidTime {
    
    NSString *startTimeHour = self.startTimeHourTextField.stringValue;
    NSString *startTimeMinute = self.startTimeMinuteTextField.stringValue;
    NSString *endTimeHour = self.endTimeHourTextField.stringValue;
    NSString *endTimeMinute = self.endTimeMinuteTextField.stringValue;
    NSString *startTimeSeperator = self.startTImeSeperator.stringValue;
    NSString *endTimeSeperator = self.endTimeSeperator.stringValue;
    
    NSString *startTime = [NSString stringWithFormat:@"%@%@%@", startTimeHour, startTimeSeperator, startTimeMinute];
    NSString *endTime = [NSString stringWithFormat:@"%@%@%@", endTimeHour, endTimeSeperator, endTimeMinute];
    
    NSString *regularExpressionPatternString = @"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$";
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:regularExpressionPatternString
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
    
    NSUInteger startTimeMatches = [regularExpression numberOfMatchesInString:startTime
                                                                     options:0
                                                                       range:NSMakeRange(0, startTime.length)];
    
    NSUInteger endTimeMatches = [regularExpression numberOfMatchesInString:endTime
                                                                   options:0
                                                                     range:NSMakeRange(0, endTime.length)];
    
    if (startTimeHour.intValue > 12 || startTimeMinute.intValue > 60 || endTimeHour.intValue > 12 || endTimeMinute.intValue > 60 || startTimeHour.intValue == 0 || endTimeHour.intValue == 0) {
        
        return NO;
        
    } else if (startTimeMatches == 1 && endTimeMatches == 1) {
        
        return YES;
    }
    
    else {
        
        return NO;
    }
}

- (BOOL)isValidImageType {
    
    if ([self.fileExtension isEqualToString:@"png"]) {
        
        return YES;
        
    } else if ([self.fileExtension isEqualToString:@"jpg"]) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

@end
