//
//  SPDocumentUploadViewController.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 12/27/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "SPDocumentUploadViewController.h"
#import "SPDataEntryApi.h"
#import <Parse/PFFile.h>


@interface SPDocumentUploadViewController ()

@property (weak) IBOutlet NSPopUpButton *coursePopUp;
@property (weak) IBOutlet NSPopUpButton *subjectPopUp;
@property (weak) IBOutlet NSTextField *filePathTextField;

@property (strong, nonatomic) NSString *currentCourse;
@property (strong, nonatomic) NSString *selectedCourse;
@property (strong, nonatomic) NSData *data;

@property (weak) IBOutlet NSProgressIndicator *coursePopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *subjectPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *uploadProgressIndicator;

@end

@implementation SPDocumentUploadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
    NSColor *color = [NSColor colorWithDeviceRed:0.238f green:0.363f blue:0.438f alpha:1.0f];
    [self.view.layer setBackgroundColor:[color CGColor]];
    [self.coursePopUpIndicator startAnimation:self];
    self.subjectPopUpIndicator.hidden = YES;
    self.coursePopUp.enabled = NO;
    self.subjectPopUp.enabled = NO;
    self.uploadProgressIndicator.hidden = YES;
    [self.coursePopUp removeAllItems];
    [self.subjectPopUp removeAllItems];
    
    [self.coursePopUp addItemWithTitle:@"-- Choose Course --"];
    
    [[SPDataEntryApi sharedInstance] fetchCourses:^(NSArray *responseArray, NSError *error) {
        
        if (error) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"There was an error fetching the courses from the database. Please check your connection or try again later."];
            [alert runModal];
            
        } else {
        
            NSArray *courseItems = [[SPDataEntryApi sharedInstance] parseCourseTitleFromResponse:responseArray];
        
            [self.coursePopUp addItemsWithTitles:courseItems];
            self.coursePopUp.enabled = YES;
            [self.coursePopUpIndicator stopAnimation:self];
            self.coursePopUpIndicator.hidden = YES;
        }
    }];
}

- (IBAction)browseClicked:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setShowsHiddenFiles:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
    
        if (result == NSFileHandlingPanelOKButton) {
            
            NSURL *filePathUrl = [[panel URLs] objectAtIndex:0];
            self.data = [[NSFileManager defaultManager] contentsAtPath:[filePathUrl path]];
            NSString *unformattedFileDirectoryUrlString = [NSString stringWithFormat:@"%@", filePathUrl];
            NSArray *seperatedFileDirectories = [unformattedFileDirectoryUrlString componentsSeparatedByString:@"/"];
            NSString *unformattedFilePathUrlString = seperatedFileDirectories[seperatedFileDirectories.count - 1];
            NSString *formattedFilePathUrlString = [unformattedFilePathUrlString stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
            [self.filePathTextField setStringValue:formattedFilePathUrlString];
            
        }
    }];
}

- (IBAction)uploadClicked:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (self.coursePopUp.indexOfSelectedItem != 0 && self.subjectPopUp.indexOfSelectedItem != 00 && self.filePathTextField.stringValue.length > 0) {
    
            self.uploadProgressIndicator.hidden = NO;
            [self.uploadProgressIndicator startAnimation:self];
    
            [[SPDataEntryApi sharedInstance] fetchSubjectWithTitle:self.subjectPopUp.selectedItem.title completion:^(PFObject *subject, NSError *error) {
       
            if (error) {
                
                [self.uploadProgressIndicator stopAnimation:self];
                self.uploadProgressIndicator.hidden = YES;
        
                [alert setAlertStyle:NSCriticalAlertStyle];
                [alert setMessageText:@"Error"];
                [alert setInformativeText:@"There was an error uploading the file. Please check your connection or try againlater."];
                [alert runModal];
        
            } else {
        
                PFFile *file = [PFFile fileWithName:self.filePathTextField.stringValue data:self.data];
                [subject setValue:file forKey:@"slide"];
                [subject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
                    if (error) {
                        
                        [self.uploadProgressIndicator stopAnimation:self];
                        self.uploadProgressIndicator.hidden = YES;
                
                        [alert setAlertStyle:NSCriticalAlertStyle];
                        [alert setMessageText:@"Error"];
                        [alert setInformativeText:@"There was an error uploading the file. Please check your connection or try again later."];
                        [alert runModal];
                    
                    } else {
                    
                        [self.uploadProgressIndicator stopAnimation:self];
                        self.uploadProgressIndicator.hidden = YES;
                        
                        [alert setAlertStyle:NSInformationalAlertStyle];
                        [alert setMessageText:@"Success"];
                        [alert setInformativeText:@"File upload is succesful."];
                        [alert runModal];
                        
                        [self.coursePopUp selectItemAtIndex:0];
                        [self.subjectPopUp removeAllItems];
                        self.subjectPopUp.enabled = NO;
                        self.filePathTextField.stringValue = @"";
                    }
                }];
            }
        }];
        
    } else {
        
        [self checkMissingValues];
    }
}

- (IBAction)courseChosen:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (self.coursePopUp.indexOfSelectedItem == 0) {
        
        [self.subjectPopUp removeAllItems];
        
        [self.subjectPopUpIndicator stopAnimation:self];
        self.subjectPopUpIndicator.hidden = YES;
        self.subjectPopUp.enabled = NO;
        self.currentCourse = @"";
        
    } else {
        
        self.selectedCourse = self.coursePopUp.selectedItem.title;
        
        if (self.currentCourse) {
            
            if ([self.selectedCourse isNotEqualTo:self.currentCourse]) {
                
                self.subjectPopUpIndicator.hidden = NO;
                [self.subjectPopUpIndicator startAnimation:self];
                
                self.subjectPopUp.enabled = NO;
                self.coursePopUp.enabled = NO;
                
                [self.subjectPopUp removeAllItems];
                [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourse completionBlock:^(NSArray *subjectArray, NSError *error) {
                    
                    if (error) {
                        
                        [self.subjectPopUpIndicator stopAnimation:self];
                        self.subjectPopUpIndicator.hidden = YES;
                        self.subjectPopUp.enabled = NO;
                        
                        [alert setAlertStyle:NSCriticalAlertStyle];
                        [alert setMessageText:@"Error"];
                        [alert setInformativeText:@"There was an error fetching the subjects from the database. Please check your connection or try again later."];
                        [alert runModal];

                        
                    } else {
                        
                        [self.subjectPopUpIndicator stopAnimation:self];
                        self.subjectPopUpIndicator.hidden = YES;
                        NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                        self.subjectPopUp.enabled = YES;
                        [self.subjectPopUp addItemsWithTitles:subjects];
                        self.currentCourse = self.selectedCourse;
                        self.coursePopUp.enabled = YES;
                    }
                }];
            }
        } else {
            
            self.subjectPopUpIndicator.hidden = NO;
            [self.subjectPopUpIndicator startAnimation:self];
            
            self.subjectPopUp.enabled = NO;
            self.coursePopUp.enabled = NO;
            
            [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourse completionBlock:^(NSArray *subjectArray, NSError *error) {
                
                if (error) {
                    
                    [self.subjectPopUpIndicator stopAnimation:self];
                    self.subjectPopUpIndicator.hidden = YES;
                    self.subjectPopUp.enabled = NO;
                    
                    [alert setAlertStyle:NSCriticalAlertStyle];
                    [alert setMessageText:@"Error"];
                    [alert setInformativeText:@"There was an error fetching the subjects from the database. Please check your connection or try again later."];
                    [alert runModal];

                } else {
                    
                    [self.subjectPopUpIndicator stopAnimation:self];
                    self.subjectPopUpIndicator.hidden = YES;
                    NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                    self.subjectPopUp.enabled = YES;
                    [self.subjectPopUp addItemsWithTitles:subjects];
                    self.currentCourse = self.selectedCourse;
                    self.coursePopUp.enabled = YES;
                }
            }];
        }
    }
}

- (void)checkMissingValues {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (self.coursePopUp.indexOfSelectedItem == 0 && self.filePathTextField.stringValue.length > 0) {
        
        [self.uploadProgressIndicator stopAnimation:self];
        self.uploadProgressIndicator.hidden = YES;
        
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Course and subject info required"];
        [alert setInformativeText:@"Please choose the course and subject for the file"];
        [alert runModal];
        
    } else if (self.coursePopUp.indexOfSelectedItem > 0 && self.filePathTextField.stringValue.length == 0){
        
        [self.uploadProgressIndicator stopAnimation:self];
        self.uploadProgressIndicator.hidden = YES;
        
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"File directory required"];
        [alert setInformativeText:@"Please provide a valid directory of the file you wish to upload"];
        [alert runModal];
        
    } else {
        
        [self.uploadProgressIndicator stopAnimation:self];
        self.uploadProgressIndicator.hidden = YES;
        
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Course info and file path required"];
        [alert setInformativeText:@"Please choose the course and provide the file path to upload the file"];
        [alert runModal];
    }
}

@end
