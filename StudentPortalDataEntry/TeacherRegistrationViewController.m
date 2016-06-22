//
//  TeacherRegistrationViewController.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 10/28/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "TeacherRegistrationViewController.h"
#import "SPDataEntryApi.h"
#import <Parse/Parse.h>

static NSString *const chooseCourse = @"-- Choose course --";
static NSTimeInterval const timeDifference = 568024668.00; //18 years in seconds

@interface TeacherRegistrationViewController () <NSMenuDelegate>

@property (weak) IBOutlet NSTextField *teacherIdTextField;
@property (weak) IBOutlet NSTextField *teacherNameTextField;
@property (weak) IBOutlet NSTextField *teacherContactNumberTextField;
@property (weak) IBOutlet NSTextField *teacherEmailTextField;
@property (weak) IBOutlet NSTextField *teacherAddressTextField;
@property (weak) IBOutlet NSTextField *teacherNRCTextField;
@property (weak) IBOutlet NSDatePicker *teacherDOBDatePicker;
@property (weak) IBOutlet NSPopUpButton *teacherGenderPopUp;
@property (weak) IBOutlet NSTextField *teacherDepartmentTextField;
@property (weak) IBOutlet NSTextField *teacherPositionTextField;
@property (weak) IBOutlet NSTextField *teacherUsernameTextField;
@property (weak) IBOutlet NSTextField *teacherPasswordTextField;

@property (weak) IBOutlet NSPopUpButton *courseOnePopUp;
@property (weak) IBOutlet NSPopUpButton *subjectOnePopUp;
@property (weak) IBOutlet NSPopUpButton *courseTwoPopUp;
@property (weak) IBOutlet NSPopUpButton *subjectTwoPopUp;

@property (weak) IBOutlet NSProgressIndicator *courseOnePopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *subjectOnePopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *courseTwoPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *subjectTwoPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *registerTeacherProgressIndicator;
 
@property (strong, nonatomic) NSString *currentCourse;
@property (strong, nonatomic) NSString *selectedCourse;
@property (strong, nonatomic) NSString *currentCourseTwo;
@property (strong, nonatomic) NSString *selectedCourseTwo;

@end

@implementation TeacherRegistrationViewController

- (void)viewDidLoad {
    
    [self.view setWantsLayer:YES];
    NSColor *color = [NSColor colorWithDeviceRed:0.238f green:0.363f blue:0.438f alpha:1.0f];
    [self.view.layer setBackgroundColor:[color CGColor]];
    
    self.registerTeacherProgressIndicator.hidden = YES;
    
    [self.courseOnePopUp removeAllItems];
    [self.courseTwoPopUp removeAllItems];
    [self.subjectOnePopUp removeAllItems];
    [self.subjectTwoPopUp removeAllItems];
    [self.teacherGenderPopUp removeAllItems];
    
    [self.teacherGenderPopUp addItemsWithTitles:@[@"-- Choose gender --",@"Male", @"Female", @"Others"]];
    
    self.courseOnePopUp.enabled = NO;
    self.courseTwoPopUp.enabled = NO;
    self.subjectOnePopUp.enabled = NO;
    self.subjectTwoPopUp.enabled = NO;
    
    [self.courseOnePopUp addItemWithTitle:chooseCourse];
    [self.courseTwoPopUp addItemWithTitle:chooseCourse];
    
    self.subjectOnePopUpIndicator.hidden = YES;
    self.subjectTwoPopUpIndicator.hidden = YES;
    
    [self.courseOnePopUpIndicator startAnimation:self];
    [self.courseTwoPopUpIndicator startAnimation:self];
    
    
    
    [super viewDidLoad];
    
}

- (void)viewWillAppear {
    
    [self loadCourses];
    
}

- (void)loadCourses {

    [[SPDataEntryApi sharedInstance] fetchCourses:^(NSArray *responseArray, NSError *error) {
       
        if (error) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"Couldn't fetch courses";
            alert.informativeText = @"There was an error fetching courses from the server. Please try again later.";
            alert.alertStyle = NSCriticalAlertStyle;
            [alert runModal];
            
            [self.courseOnePopUpIndicator stopAnimation:self];
            self.courseOnePopUpIndicator.hidden = YES;
            
            [self.courseTwoPopUpIndicator stopAnimation:self];
            self.courseTwoPopUpIndicator.hidden = YES;
            
        } else {
            
            NSArray *courses = [[SPDataEntryApi sharedInstance] parseCourseTitleFromResponse:responseArray];
            [self.courseOnePopUp addItemsWithTitles:courses];
            [self.courseTwoPopUp addItemsWithTitles:courses];
            
            [self.courseOnePopUpIndicator stopAnimation:self];
            self.courseOnePopUpIndicator.hidden = YES;
            
            [self.courseTwoPopUpIndicator stopAnimation:self];
            self.courseTwoPopUpIndicator.hidden = YES;
            
            self.courseOnePopUp.enabled = YES;
            self.courseTwoPopUp.enabled = YES;
        }
        
    }];
}

- (IBAction)saveButtonClicked:(id)sender {
    
    if (![self checkTextField]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Insufficient info";
        alert.informativeText = @"One or more required fields are missing. Pleas check again.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self checkAgeLimitation]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid date of birth";
        alert.informativeText = @"The teacher must be 18 years or older.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self checkEmailValidity]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid email address";
        alert.informativeText = @"A valid email address is needed.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (![self checkPhoneValidity]) {
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Invalid contact number";
        alert.informativeText = @"A valid contact number is needed.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else {
        
        self.registerTeacherProgressIndicator.hidden = NO;
        [self.registerTeacherProgressIndicator startAnimation:self];
        
        [[SPDataEntryApi sharedInstance] addTeacherWithId:self.teacherIdTextField.stringValue name:self.teacherNameTextField.stringValue phone:self.teacherContactNumberTextField.stringValue email:self.teacherEmailTextField.stringValue nrc:self.teacherNRCTextField.stringValue dateOfBirth:self.teacherDOBDatePicker.dateValue username:self.teacherUsernameTextField.stringValue password:self.teacherPasswordTextField.stringValue position:self.teacherPositionTextField.stringValue department:self.teacherDepartmentTextField.stringValue gender:self.teacherGenderPopUp.selectedItem.title subjectOne:self.subjectOnePopUp.selectedItem.title subjectTwo:self.subjectTwoPopUp.selectedItem.title completion:^(BOOL success, NSError *error) {
            
            if (error) {
                
                [self.registerTeacherProgressIndicator stopAnimation:self];
                self.registerTeacherProgressIndicator.hidden = YES;
                
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Error";
                alert.informativeText = @"Server error. Please try again later.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else if (!success) {
                
                [self.registerTeacherProgressIndicator stopAnimation:self];
                self.registerTeacherProgressIndicator.hidden = YES;

                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Duplicate teacher";
                alert.informativeText = @"A teacher with that ID is already registered. Please check again.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else {
                
                [self.registerTeacherProgressIndicator stopAnimation:self];
                self.registerTeacherProgressIndicator.hidden = YES;
                
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Success";
                alert.informativeText = @"Teacher registration successful.";
                [alert runModal];
            }
        }];
    }
}

- (IBAction)clearButtonClicked:(id)sender {
    
    [self.teacherIdTextField setStringValue:@""];
    [self.teacherNameTextField setStringValue:@""];
    [self.teacherContactNumberTextField setStringValue:@""];
    [self.teacherEmailTextField setStringValue:@""];
    [self.teacherAddressTextField setStringValue:@""];
    [self.teacherNRCTextField setStringValue:@""];
    [self.teacherDepartmentTextField setStringValue:@""];
    [self.teacherPositionTextField setStringValue:@""];
    [self.teacherUsernameTextField setStringValue:@""];
    [self.teacherPasswordTextField setStringValue:@""];

}

- (IBAction)courseOneItemChanged:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (self.courseOnePopUp.indexOfSelectedItem == 0) {
        
        [self.subjectOnePopUp removeAllItems];
        self.subjectOnePopUp.enabled = NO;
        
    } else {
        
        self.selectedCourse = self.courseOnePopUp.selectedItem.title;
        
        if (self.currentCourse) {
            
            if ([self.selectedCourse isNotEqualTo:self.currentCourse]) {
                
                [self.subjectOnePopUp removeAllItems];
                self.subjectOnePopUp.enabled = NO;
                self.subjectOnePopUpIndicator.hidden = NO;
                self.courseOnePopUp.enabled = NO;
                [self.subjectOnePopUpIndicator startAnimation:self];
                
                [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourse completionBlock:^(NSArray *subjectArray, NSError *error) {
                   
                    if (error) {
                        
                        [self.subjectOnePopUpIndicator stopAnimation:self];
                        self.subjectOnePopUpIndicator.hidden = YES;
                        self.courseOnePopUp.enabled = YES;
                        
                        alert.messageText = @"Couldn't fetch subjects";
                        alert.informativeText = @"There was an error fetching subjects from the server. Please try again later.";
                        alert.alertStyle = NSCriticalAlertStyle;
                        [alert runModal];

                    } else {
                        
                        NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                        [self.subjectOnePopUp addItemsWithTitles:subjects];
                        self.currentCourse = self.selectedCourse;
                        
                        [self.subjectOnePopUpIndicator stopAnimation:self];
                        self.subjectOnePopUpIndicator.hidden = YES;
                        self.subjectOnePopUp.enabled = YES;
                        self.courseOnePopUp.enabled = YES;
                    }
                }];
            }
            
        } else {
            
            self.subjectOnePopUp.enabled = NO;
            self.courseOnePopUp.enabled = NO;
            self.subjectOnePopUpIndicator.hidden = NO;
            [self.subjectOnePopUpIndicator startAnimation:self];
            
            [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourse completionBlock:^(NSArray *subjectArray, NSError *error) {
               
                if (error) {
                    
                    [self.subjectOnePopUpIndicator stopAnimation:self];
                    self.subjectOnePopUpIndicator.hidden = YES;
                    self.courseOnePopUp.enabled = YES;
                    
                    alert.messageText = @"Couldn't fetch subjects";
                    alert.informativeText = @"There was an error fetching the subjects from the server. Please try agian later.";
                    alert.alertStyle = NSCriticalAlertStyle;
                    [alert runModal];
                    
                } else {
                    
                    NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                    [self.subjectOnePopUp addItemsWithTitles:subjects];
                    self.currentCourse = self.selectedCourse;
                    
                    [self.subjectOnePopUpIndicator stopAnimation:self];
                    self.subjectOnePopUpIndicator.hidden = YES;
                    self.subjectOnePopUp.enabled = YES;
                    self.courseOnePopUp.enabled = YES;
                }
            }];
        }
    }
}

- (IBAction)courseTwoItemChanged:(id)sender {
    
    NSAlert *alert = [[NSAlert alloc] init];
    
    if (self.courseTwoPopUp.indexOfSelectedItem == 0) {
        
        [self.subjectTwoPopUp removeAllItems];
        self.subjectTwoPopUp.enabled = NO;
        
    } else {
        
        self.selectedCourseTwo = self.courseTwoPopUp.selectedItem.title;
        
        if (self.currentCourseTwo) {
            
            if ([self.selectedCourseTwo isNotEqualTo:self.currentCourseTwo]) {
                
                [self.subjectTwoPopUp removeAllItems];
                self.subjectTwoPopUp.enabled = NO;
                self.courseTwoPopUp.enabled = NO;
                self.subjectTwoPopUpIndicator.hidden = NO;
                [self.subjectTwoPopUpIndicator startAnimation:self];
                
                [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourseTwo completionBlock:^(NSArray *subjectArray, NSError *error) {
                    
                    if (error) {
                        
                        [self.subjectTwoPopUpIndicator stopAnimation:self];
                        self.subjectTwoPopUpIndicator.hidden = YES;
                        self.courseTwoPopUp.enabled = YES;
                        
                        alert.messageText = @"Couldn't fetch subjects";
                        alert.informativeText = @"There was an error fetching the subjects from the server. Please try agian later.";
                        alert.alertStyle = NSCriticalAlertStyle;
                        [alert runModal];
                        
                    } else {
                        
                        NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                        [self.subjectTwoPopUp addItemsWithTitles:subjects];
                        self.currentCourseTwo = self.selectedCourseTwo;
                        
                        [self.subjectTwoPopUpIndicator stopAnimation:self];
                        self.subjectTwoPopUpIndicator.hidden = YES;
                        self.subjectTwoPopUp.enabled = YES;
                        self.courseTwoPopUp.enabled = YES;
                    }
                }];
            }
            
        } else {
            
            self.subjectTwoPopUp.enabled = NO;
            self.courseTwoPopUp.enabled = NO;
            self.subjectTwoPopUpIndicator.hidden = NO;
            [self.subjectTwoPopUpIndicator startAnimation:self];
            
            [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourseTwo completionBlock:^(NSArray *subjectArray, NSError *error) {
                
                if (error) {
                    
                    [self.subjectTwoPopUpIndicator stopAnimation:self];
                    self.subjectTwoPopUpIndicator.hidden = YES;
                    self.courseTwoPopUp.enabled = YES;
                    
                    alert.messageText = @"Couldn't fetch subjects";
                    alert.informativeText = @"There was an error fetching the subjects from the server. Please try agian later.";
                    alert.alertStyle = NSCriticalAlertStyle;
                    [alert runModal];
                    
                } else {
                    
                    NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                    [self.subjectTwoPopUp addItemsWithTitles:subjects];
                    self.currentCourseTwo = self.selectedCourseTwo;
                    
                    [self.subjectTwoPopUpIndicator stopAnimation:self];
                    self.subjectTwoPopUpIndicator.hidden = YES;
                    self.subjectTwoPopUp.enabled = YES;
                    self.courseTwoPopUp.enabled = YES;
                }
            }];
        }
    }
}

- (BOOL)checkTextField {
    
    NSUInteger idLength = self.teacherIdTextField.stringValue.length;
    NSUInteger nameLength = self.teacherNameTextField.stringValue.length;
    NSUInteger contactNumberLength = self.teacherContactNumberTextField.stringValue.length;
    NSUInteger emailLength = self.teacherEmailTextField.stringValue.length;
    NSUInteger addressLength = self.teacherAddressTextField.stringValue.length;
    NSUInteger nrcLength = self.teacherNRCTextField.stringValue.length;
    NSInteger indexOfSelectedGender = self.teacherGenderPopUp.indexOfSelectedItem;
    NSUInteger departmentLength = self.teacherDepartmentTextField.stringValue.length;
    NSUInteger positionLength = self.teacherPositionTextField.stringValue.length;
    NSUInteger usernameLength = self.teacherUsernameTextField.stringValue.length;
    NSUInteger passwordLength = self.teacherPasswordTextField.stringValue.length;
    NSInteger indexOfCourseOne = self.courseOnePopUp.indexOfSelectedItem;
    NSInteger indexOfCourseTwo = self.courseTwoPopUp.indexOfSelectedItem;
    
    if (idLength > 0 && nameLength > 0 && contactNumberLength > 0 && emailLength > 0 && addressLength > 0 && nrcLength > 0 && indexOfSelectedGender > 0 && departmentLength > 0 && positionLength > 0 && usernameLength > 0 && passwordLength > 0 && indexOfCourseOne > 0 && indexOfCourseTwo > 0) {
        
        return YES;
        
    } else {
        
        return NO;
    }
    return NO;
}

- (BOOL)checkAgeLimitation {
    
    NSDate *dob = self.teacherDOBDatePicker.dateValue;
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
    
    NSUInteger numberOfMatches = [expression numberOfMatchesInString:self.teacherEmailTextField.stringValue
                                                             options:0
                                                               range:NSMakeRange(0, self.teacherEmailTextField.stringValue.length)];
    
    if (numberOfMatches == 1) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

- (BOOL)checkPhoneValidity {
    
    NSString *teacherContact = self.teacherContactNumberTextField.stringValue;
    
    NSString *validPhoneRegexPattern = @"^[0-9]*$";
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:validPhoneRegexPattern
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:teacherContact
                                                        options:0
                                                          range:NSMakeRange(0, teacherContact.length)];
    if (teacherContact.length < 8 || teacherContact.length > 11 || numberOfMatches == 0) {
        
        return NO;
        
    } else {
        
        return YES;
    }
}

@end