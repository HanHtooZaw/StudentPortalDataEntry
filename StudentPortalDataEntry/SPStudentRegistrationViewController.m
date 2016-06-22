//
//  SPStudentRegistrationViewController.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 10/31/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "SPStudentRegistrationViewController.h"
#import "SPDataEntryApi.h"


static NSString *const chooseCourse = @"-- Choose course --";
static NSTimeInterval const timeDifference = 504910816.00;

@interface SPStudentRegistrationViewController ()

@property (weak) IBOutlet NSTextField *studentIdTextField;
@property (weak) IBOutlet NSTextField *studentNRCTextField;
@property (weak) IBOutlet NSTextField *studentNameTextField;
@property (weak) IBOutlet NSDatePicker *studentDOBDatePicker;
@property (weak) IBOutlet NSTextField *studentContactNumberTextField;
@property (weak) IBOutlet NSTextField *studentUsernameTextField;
@property (weak) IBOutlet NSTextField *studentEmailTextField;
@property (weak) IBOutlet NSTextField *studentPasswordTextField;
@property (weak) IBOutlet NSTextField *studentAddressTextField;
@property (weak) IBOutlet NSPopUpButton *studentGenderPopUp;
@property (weak) IBOutlet NSPopUpButton *coursePopUp;
@property (weak) IBOutlet NSPopUpButton *studentSectionPopUp;
@property (weak) IBOutlet NSProgressIndicator *studentCoursePopUpIndicator;

@property (weak) IBOutlet NSProgressIndicator *sectionPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *registerStudentProgressIndicator;


@property (strong, nonatomic) NSString *currentCourse;
@property (strong, nonatomic) NSString *selectedCourse;

@end

@implementation SPStudentRegistrationViewController

- (void)viewDidLoad {
    
    [self.view setWantsLayer:YES];
    NSColor *color = [NSColor colorWithDeviceRed:0.238f green:0.363f blue:0.438f alpha:1.0f];
    [self.view.layer setBackgroundColor:[color CGColor]];
    
    [super viewDidLoad];
    
    [self.studentSectionPopUp removeAllItems];
    
    [self.studentGenderPopUp removeAllItems];
    [self.studentGenderPopUp addItemsWithTitles:@[@"-- Choose gender --",@"Male", @"Female", @"Others"]];
    
    [self.coursePopUp removeAllItems];
    [self.coursePopUp addItemWithTitle:chooseCourse];
    
    
    self.registerStudentProgressIndicator.hidden = YES;
    self.sectionPopUpIndicator.hidden = YES;
    
    self.studentSectionPopUp.enabled = NO;
    self.coursePopUp.enabled = NO;
    

    self.studentCoursePopUpIndicator.hidden = NO;
    [self.studentCoursePopUpIndicator startAnimation:self];
    
    [[SPDataEntryApi sharedInstance] fetchCourses:^(NSArray *responseArray, NSError *error) {
       
        if (error) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Couldn't fetch courses";
            alert.informativeText = @"There was an error fetching courses from the server. Please try again later.";
            alert.alertStyle = NSCriticalAlertStyle;
            [alert runModal];
            
            [self.studentCoursePopUpIndicator stopAnimation:self];
            self.studentCoursePopUpIndicator.hidden = YES;
            
        } else {
            
            NSArray *courses = [[SPDataEntryApi sharedInstance] parseCourseTitleFromResponse:responseArray];
            [self.coursePopUp addItemsWithTitles:courses];
            
            [self.studentCoursePopUpIndicator stopAnimation:self];
            self.studentCoursePopUpIndicator.hidden = YES;
            self.coursePopUp.enabled = YES;
        }
        
    }];
}

- (IBAction)coursePopUpClicked:(id)sender {
    
    if (self.coursePopUp.indexOfSelectedItem == 0) {
        
        [self.studentSectionPopUp removeAllItems];
        self.studentSectionPopUp.enabled = NO;
        
    } else {
        
        self.selectedCourse = self.coursePopUp.selectedItem.title;
        
        if (self.currentCourse) {
            
            if ([self.selectedCourse isNotEqualTo:self.currentCourse]) {
                
                [self.studentSectionPopUp removeAllItems];
                self.studentSectionPopUp.enabled = NO;
                self.sectionPopUpIndicator.hidden = NO;
                [self.sectionPopUpIndicator startAnimation:self];

                [[SPDataEntryApi sharedInstance] fetchSectionsOfCourse:self.selectedCourse completion:^(NSArray *sectionsArray, NSError *error) {
                        
                    if (error) {
                        
                        [self.sectionPopUpIndicator stopAnimation:self];
                        self.sectionPopUpIndicator.hidden = YES;
                        
                        NSAlert *alert = [[NSAlert alloc] init];
                        alert.messageText = @"Couldn't fetch courses";
                        alert.informativeText = @"There was an error fetching the courses from server. Please try again later.";
                        alert.alertStyle = NSCriticalAlertStyle;
                        [alert runModal];
                            
                    } else {
                            
                        NSArray *sections = [[SPDataEntryApi sharedInstance] parseSectionTitleFromResponse:sectionsArray];
                        [self.studentSectionPopUp addItemsWithTitles:sections];
                        self.currentCourse = self.selectedCourse;
                        
                        [self.sectionPopUpIndicator stopAnimation:self];
                        self.sectionPopUpIndicator.hidden = YES;
                        self.studentSectionPopUp.enabled = YES;
                    }
                }];
            }
        
        } else {
            
            self.sectionPopUpIndicator.hidden = NO;
            [self.sectionPopUpIndicator startAnimation:self];
            
            [[SPDataEntryApi sharedInstance] fetchSectionsOfCourse:self.selectedCourse completion:^(NSArray *sectionsArray, NSError *error) {
                
                if (error) {
                    
                    [self.sectionPopUpIndicator stopAnimation:self];
                    self.sectionPopUpIndicator.hidden = YES;
                    
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = @"Couldn't fetch courses";
                    alert.informativeText = @"There was an error fetching the courses from server. Please try again later.";
                    alert.alertStyle = NSCriticalAlertStyle;
                    [alert runModal];
                    
                } else {
                    
                    NSArray *sections = [[SPDataEntryApi sharedInstance] parseSectionTitleFromResponse:sectionsArray];
                    [self.studentSectionPopUp addItemsWithTitles:sections];
                    self.currentCourse = self.selectedCourse;
                    
                    [self.sectionPopUpIndicator stopAnimation:self];
                    self.sectionPopUpIndicator.hidden = YES;
                    self.studentSectionPopUp.enabled = YES;
                }
            }];
        }
    }
}

- (IBAction)saveClicked:(id)sender {
    
    NSString *studentId = self.studentIdTextField.stringValue;
    NSString *studentName = self.studentNameTextField.stringValue;
    NSString *studentContactNumber = self.studentContactNumberTextField.stringValue;
    NSString *studentEmail = self.studentEmailTextField.stringValue;
    NSString *studentNRC = self.studentNRCTextField.stringValue;
    NSDate *studentDOB = self.studentDOBDatePicker.dateValue;
    NSString *studentGender = self.studentGenderPopUp.selectedItem.title;
    NSString *studentAddress = self.studentAddressTextField.stringValue;
    NSString *section = self.studentSectionPopUp.selectedItem.title;
    NSString *studentUsername = self.studentUsernameTextField.stringValue;
    NSString *studentPassword = self.studentPasswordTextField.stringValue;
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (![self checkTextField]) {
        
        alert.messageText = @"Insufficient info";
        alert.informativeText = @"One or more required fields are missing. Please check again.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self checkAgeValidity]) {
        
        alert.messageText = @"Invalid age";
        alert.informativeText = @"The student msut be 16 years or older to attend this course.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self checkEmailValidity]) {
        
        alert.messageText = @"Invalid email";
        alert.informativeText = @"A valid email is required for registration.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self checkPhoneValidity])  {
        
        alert.messageText = @"Invalid contact number";
        alert.informativeText = @"A valid number is required for registration.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else {
        
        self.registerStudentProgressIndicator.hidden = NO;
        [self.registerStudentProgressIndicator startAnimation:self];
        
        [[SPDataEntryApi sharedInstance] registerNewStudent:studentId studentName:studentName contact:studentContactNumber studentEmail:studentEmail studentNRC:studentNRC studentDOB:studentDOB studentAddress:studentAddress studentGender:studentGender studentSection:section studentUsername:studentUsername studentPassword:studentPassword completion:^(BOOL success, NSError *error) {
            
            if (error) {
                
                [self.registerStudentProgressIndicator stopAnimation:self];
                self.registerStudentProgressIndicator.hidden = YES;
                
                alert.messageText = @"Error";
                alert.informativeText = @"Server error. Please try again later.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else if (!success ) {
                
                [self.registerStudentProgressIndicator stopAnimation:self];
                self.registerStudentProgressIndicator.hidden = YES;
                
                alert.messageText = @"Error";
                alert.informativeText = @"A student with this ID already exists in the database. Please check the information you entered again.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            }else {
                
                [self.registerStudentProgressIndicator stopAnimation:self];
                self.registerStudentProgressIndicator.hidden = YES;
                
                alert.messageText = @"Success";
                alert.informativeText = @"A New Student has been registered.";
                alert.alertStyle = NSInformationalAlertStyle;
                [alert runModal];
            }
        }];
    }
}

- (IBAction)clearClicked:(id)sender {

    [self clearForm];
    
}

- (IBAction)addNewSectionTapped:(id)sender {
    
    [[SPDataEntryApi sharedInstance] addNewSectionToCourse:self.coursePopUp.selectedItem.title completion:^(BOOL success, PFObject *sectionObject, NSError *error) {
       
        NSAlert *alert = [[NSAlert alloc] init];
        self.sectionPopUpIndicator.hidden = NO;
        [self.sectionPopUpIndicator startAnimation:self];
        self.studentSectionPopUp.enabled = NO;
        self.coursePopUp.enabled = NO;
        
        if (error) {
            
            [self.sectionPopUpIndicator stopAnimation:self];
            self.sectionPopUpIndicator.hidden = YES;
            self.studentSectionPopUp.enabled = YES;
            self.coursePopUp.enabled = YES;
            
            alert.messageText = @"Error";
            alert.informativeText = @"There was an error adding a new section. Please try again later";
            alert.alertStyle = NSCriticalAlertStyle;
            [alert runModal];
            
        } else {
            
            [self.sectionPopUpIndicator stopAnimation:self];
            self.sectionPopUpIndicator.hidden = YES;
            
            alert.messageText = @"Success";
            alert.informativeText = [NSString stringWithFormat:@"A new section %@ has been added", [sectionObject objectForKey:@"sectionName"]];
            [alert beginSheetModalForWindow:[[NSApplication sharedApplication] keyWindow] completionHandler:^(NSModalResponse returnCode) {
                
                [self.studentSectionPopUp addItemWithTitle:[sectionObject objectForKey:@"sectionName"]];
                self.studentSectionPopUp.enabled = YES;
                self.coursePopUp.enabled = YES;
            }];
        }
    }];
}

- (BOOL)checkTextField {
    
    NSString *studentId = self.studentIdTextField.stringValue;
    NSString *studentName = self.studentNameTextField.stringValue;
    NSString *studentContactNumber = self.studentContactNumberTextField.stringValue;
    NSString *studentEmail = self.studentEmailTextField.stringValue;
    NSString *studentNRC = self.studentNRCTextField.stringValue;
    NSString *studentAddress = self.studentAddressTextField.stringValue;
    NSString *studentUsername = self.studentUsernameTextField.stringValue;
    NSString *studentPassword = self.studentPasswordTextField.stringValue;
    
    if (studentId.length == 0 || studentName.length == 0 || studentContactNumber == 0 || studentEmail.length == 0 || studentNRC.length == 0 || studentAddress.length == 0 || studentUsername.length == 0 || studentPassword == 0 ||self.coursePopUp.indexOfSelectedItem == 0 || self.studentGenderPopUp.indexOfSelectedItem == 0) {
        
        return NO;
        
    } else {
        
        return YES;
    }
    
    
}

- (BOOL)checkAgeValidity {
    
    NSDate *dob = self.studentDOBDatePicker.dateValue;
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeIntervalSinceDOB = [currentDate timeIntervalSinceDate:dob];
    
    if (timeIntervalSinceDOB >= timeDifference) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

- (BOOL)checkEmailValidity {
    
    NSString *regexPatternString = @"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,9}";
    
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:regexPatternString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSUInteger numberOfMatches = [expression numberOfMatchesInString:self.studentEmailTextField.stringValue
                                                             options:0
                                                               range:NSMakeRange(0, self.studentEmailTextField.stringValue.length)];
    
    if (numberOfMatches == 1) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

- (BOOL)checkPhoneValidity {
    
    NSString *studentContact = self.studentContactNumberTextField.stringValue;
    
    NSString *validPhoneRegexPattern = @"^[0-9]*$";
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:validPhoneRegexPattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:studentContact
                                                         options:0
                                                           range:NSMakeRange(0, studentContact.length)];
    if (studentContact.length < 8 || studentContact.length > 11 || numberOfMatches == 0) {
        
        return NO;
        
    } else {
        
        return YES;
    }
}

- (void)clearForm {
    
    self.studentIdTextField.stringValue = @"";
    self.studentNameTextField.stringValue = @"";
    self.studentNRCTextField.stringValue = @"";
    self.studentContactNumberTextField.stringValue = @"";
    self.studentEmailTextField.stringValue = @"";
    self.studentUsernameTextField.stringValue = @"";
    self.studentPasswordTextField.stringValue = @"";
    self.studentAddressTextField.stringValue = @"";
}

@end