//
//  SPClassScheduleViewController.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 11/6/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "SPClassScheduleViewController.h"
#import "SPDataEntryApi.h"

@interface SPClassScheduleViewController ()

@property (weak) IBOutlet NSPopUpButton *coursePopUp;
@property (weak) IBOutlet NSPopUpButton *sectionPopUp;
@property (weak) IBOutlet NSPopUpButton *subjectPopUp;
@property (weak) IBOutlet NSPopUpButton *teacherPopUp;
@property (weak) IBOutlet NSPopUpButton *teacherIdPopUp;
@property (weak) IBOutlet NSPopUpButton *dayPopUp;
@property (weak) IBOutlet NSPopUpButton *startTimeIntervalPopUp;
@property (weak) IBOutlet NSPopUpButton *endTimeIntervalPopUp;

@property (strong, nonatomic) NSString *currentCourse;
@property (strong, nonatomic) NSString *selectedCourse;

@property (weak) IBOutlet NSTextField *startTimeHourTextField;
@property (weak) IBOutlet NSTextField *startTimeMinuteTextField;
@property (weak) IBOutlet NSTextField *startTimeLabel;

@property (weak) IBOutlet NSTextField *endTimeHourTextField;
@property (weak) IBOutlet NSTextField *endTimeMinuteTextField;
@property (weak) IBOutlet NSTextField *endTimeLabel;

@property (weak) IBOutlet NSProgressIndicator *coursePopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *sectionPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *subjectPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *teacherPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *teacherIdPopUpIndicator;
@property (weak) IBOutlet NSProgressIndicator *addScheduleProgressIndicator;

@end

@implementation SPClassScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    NSColor *color = [NSColor colorWithDeviceRed:0.238f green:0.363f blue:0.438f alpha:1.0f];
    [self.view.layer setBackgroundColor:[color CGColor]];
    
    [self.coursePopUp removeAllItems];
    [self.sectionPopUp removeAllItems];
    [self.subjectPopUp removeAllItems];
    [self.teacherPopUp removeAllItems];
    [self.teacherIdPopUp removeAllItems];
    [self.dayPopUp removeAllItems];
    [self.startTimeIntervalPopUp removeAllItems];
    [self.endTimeIntervalPopUp removeAllItems];
    
    self.coursePopUp.enabled = NO;
    self.sectionPopUp.enabled = NO;
    self.subjectPopUp.enabled = NO;
    self.teacherPopUp.enabled = NO;
    self.teacherIdPopUp.enabled = NO;
    
    self.sectionPopUpIndicator.hidden = YES;
    self.subjectPopUpIndicator.hidden = YES;
    self.teacherPopUpIndicator.hidden = YES;
    self.teacherIdPopUpIndicator.hidden = YES;
    self.addScheduleProgressIndicator.hidden = YES;
    
    [self.coursePopUp addItemWithTitle:@"-- Choose course --"];
    [self.subjectPopUp addItemWithTitle:@"-- Choose subject --"];
    [self.teacherPopUp addItemWithTitle:@"-- Choose teacher--"];
    [self.dayPopUp addItemsWithTitles:@[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"]];
    [self.startTimeIntervalPopUp addItemsWithTitles:@[@"AM", @"PM"]];
    [self.endTimeIntervalPopUp addItemsWithTitles:@[@"AM", @"PM"]];
}

- (void)viewWillAppear {
    
    [self.coursePopUpIndicator startAnimation:self];
    
    [[SPDataEntryApi sharedInstance] fetchCourses:^(NSArray *responseArray, NSError *error) {
        
        if (error) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            
            alert.messageText = @"Couldn't fetch courses";
            alert.informativeText = @"There was an error fetching the list of courses from server. Please try again later.";
            alert.alertStyle = NSCriticalAlertStyle;
            [alert runModal];
            
            [self.coursePopUpIndicator stopAnimation:self];
            self.coursePopUpIndicator.hidden = YES;
            
        } else {
            
            NSArray *courseItems = [[SPDataEntryApi sharedInstance] parseCourseTitleFromResponse:responseArray];
            
            [self.coursePopUp addItemsWithTitles:courseItems];
            self.coursePopUp.enabled = YES;
            [self.coursePopUpIndicator stopAnimation:self];
            self.coursePopUpIndicator.hidden = YES;
        }
    }];
}

- (IBAction)chooseCourseTapped:(id)sender {
    
    if (self.coursePopUp.indexOfSelectedItem == 0) {
        
        [self.sectionPopUp removeAllItems];
        self.sectionPopUp.enabled = NO;
        
        [self.teacherPopUp removeAllItems];
        [self.teacherPopUp addItemWithTitle:@"-- Choose teacher--"];
        self.teacherPopUp.enabled = NO;
        
        [self.teacherIdPopUp removeAllItems];
        self.teacherIdPopUp.enabled = NO;
        
        self.currentCourse = @"";
        
    } else {
        
        self.sectionPopUpIndicator.hidden = NO;
        [self.sectionPopUpIndicator startAnimation:self];
        
        self.coursePopUp.enabled = NO;
        
        [self.teacherPopUp removeAllItems];
        [self.teacherPopUp addItemWithTitle:@"-- Choose teacher--"];
        self.teacherPopUp.enabled = NO;
        
        [self.teacherIdPopUp removeAllItems];
        self.teacherIdPopUp.enabled = NO;
        
        self.selectedCourse = self.coursePopUp.selectedItem.title;
        
        if (self.currentCourse) {
            
            if ([self.selectedCourse isNotEqualTo:self.currentCourse]) {
                
                [self.sectionPopUp removeAllItems];
                [[SPDataEntryApi sharedInstance] fetchSectionsOfCourse:self.selectedCourse completion:^(NSArray *sectionsArray, NSError *error) {
                    
                    if (error) {
                        
                        NSAlert *alert = [[NSAlert alloc] init];
                        
                        alert.messageText = @"Couldn't fetch sections";
                        alert.informativeText = @"There was an error fetching the sections of the course from server. Please try again later.";
                        alert.alertStyle = NSCriticalAlertStyle;
                        [alert runModal];
                        
                        [self.sectionPopUpIndicator stopAnimation:self];
                        self.sectionPopUpIndicator.hidden = YES;
                        self.sectionPopUp.enabled = NO;
                        self.coursePopUp.enabled = YES;
                        
                    } else {
                        
                        NSArray *sections = [[SPDataEntryApi sharedInstance] parseSectionTitleFromResponse:sectionsArray];
                        [self.sectionPopUp addItemsWithTitles:sections];
                        self.currentCourse = self.selectedCourse;
                        [self.sectionPopUpIndicator stopAnimation:self];
                        self.sectionPopUpIndicator.hidden = YES;
                        self.sectionPopUp.enabled = YES;
                        self.coursePopUp.enabled = YES;
                    }
                }];
            }
            
        } else {
            
            [[SPDataEntryApi sharedInstance] fetchSectionsOfCourse:self.selectedCourse completion:^(NSArray *sectionsArray, NSError *error) {
                
                if (error) {
                    
                    NSAlert *alert = [[NSAlert alloc] init];
                    
                    alert.messageText = @"Couldn't fetch sections";
                    alert.informativeText = @"There was an error fetching the sections of the course from server. Please try again later.";
                    alert.alertStyle = NSCriticalAlertStyle;
                    [alert runModal];
                    
                    [self.sectionPopUpIndicator stopAnimation:self];
                    self.sectionPopUpIndicator.hidden = YES;
                    self.sectionPopUp.enabled = NO;
                    self.coursePopUp.enabled = YES;
                    
                } else {
                    
                    NSArray *sections = [[SPDataEntryApi sharedInstance] parseSectionTitleFromResponse:sectionsArray];
                    [self.sectionPopUp addItemsWithTitles:sections];
                    self.currentCourse = self.selectedCourse;
                    [self.sectionPopUpIndicator stopAnimation:self];
                    self.sectionPopUpIndicator.hidden = YES;
                    self.sectionPopUp.enabled = YES;
                    self.coursePopUp.enabled = YES;
                }
                
            }];
        }
    }
    
    if (self.coursePopUp.indexOfSelectedItem == 0) {
        
        [self.subjectPopUp removeAllItems];
        [self.subjectPopUp addItemWithTitle:@"-- Choose subject --"];
        self.subjectPopUp.enabled = NO;
        
    } else {
        
        self.subjectPopUpIndicator.hidden = NO;
        [self.subjectPopUpIndicator startAnimation:self];
        self.subjectPopUp.enabled = NO;
        
        self.selectedCourse = self.coursePopUp.selectedItem.title;
        
        if (self.currentCourse) {
            
            if ([self.selectedCourse isNotEqualTo:self.currentCourse]) {
                
                [self.subjectPopUp removeAllItems];
                [self.subjectPopUp addItemWithTitle:@"-- Choose subject --"];
                [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourse completionBlock:^(NSArray *subjectArray, NSError *error) {
                    
                    if (error) {
                        
                        NSAlert *alert = [[NSAlert alloc] init];
                        
                        alert.messageText = @"Couldn't fetch subjects";
                        alert.informativeText = @"There was an error fetching the subjects list from server. Please try again later.";
                        alert.alertStyle = NSCriticalAlertStyle;
                        [alert runModal];
                        
                        [self.subjectPopUpIndicator stopAnimation:self];
                        self.subjectPopUpIndicator.hidden = YES;
                        self.subjectPopUp.enabled = NO;
                        self.coursePopUp.enabled = YES;
                        
                    } else {
                        
                        NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                        [self.subjectPopUp addItemsWithTitles:subjects];
                        self.currentCourse = self.selectedCourse;
                        
                        [self.subjectPopUpIndicator stopAnimation:self];
                        self.subjectPopUpIndicator.hidden = YES;
                        self.subjectPopUp.enabled = YES;
                        self.coursePopUp.enabled = YES;
                        
                    }
                }];
            } else {
                
                self.coursePopUp.enabled = YES;
                self.subjectPopUp.enabled = YES;
            }
            
        } else {
            
            [[SPDataEntryApi sharedInstance] fetchSubjectsOfCourse:self.selectedCourse completionBlock:^(NSArray *subjectArray, NSError *error) {
                
                if (error) {
                    
                    NSAlert *alert = [[NSAlert alloc] init];
                    
                    alert.messageText = @"Couldn't fetch subjects";
                    alert.informativeText = @"There was an error fetching the subjects list from server. Please try again later.";
                    alert.alertStyle = NSCriticalAlertStyle;
                    [alert runModal];
                    
                    [self.subjectPopUpIndicator stopAnimation:self];
                    self.subjectPopUpIndicator.hidden = YES;
                    self.subjectPopUp.enabled = NO;
                    self.coursePopUp.enabled = YES;
                    
                } else {
                    
                    NSArray *subjects = [[SPDataEntryApi sharedInstance] parseSubjectTitleFromResponse:subjectArray];
                    [self.subjectPopUp addItemsWithTitles:subjects];
                    self.currentCourse = self.selectedCourse;
                    
                    [self.subjectPopUpIndicator stopAnimation:self];
                    self.subjectPopUpIndicator.hidden = YES;
                    self.subjectPopUp.enabled = YES;
                    self.coursePopUp.enabled = YES;
                }
            }];
        }
    }
}

- (IBAction)chooseSubjectClicked:(id)sender {
    
    if (self.subjectPopUp.indexOfSelectedItem == 0) {
        
        [self.teacherPopUp removeAllItems];
        [self.teacherPopUp addItemWithTitle:@"-- Choose teacher--"];
        self.teacherPopUp.enabled = NO;
        
        [self.teacherIdPopUp removeAllItems];
        self.teacherIdPopUp.enabled = NO;
        
    } else {
    
        self.teacherPopUpIndicator.hidden = NO;
        [self.teacherPopUpIndicator startAnimation:self];
        
        [self.teacherPopUp removeAllItems];
        [self.teacherPopUp addItemWithTitle:@"-- Choose teacher--"];
        
        [self.teacherIdPopUp removeAllItems];
        self.teacherIdPopUp.enabled = NO;
        
        self.subjectPopUp.enabled = NO;
        self.coursePopUp.enabled = NO;
        self.teacherPopUp.enabled = NO;
        
        [[SPDataEntryApi sharedInstance] fetchTeachersOfSubject:self.subjectPopUp.selectedItem.title completion:^(NSArray * responseTeachers, NSError *error) {
            
            if (error) {
                
                [self.teacherPopUpIndicator stopAnimation:self];
                self.teacherPopUpIndicator.hidden = YES;
                self.teacherPopUp.enabled = NO;
                self.subjectPopUp.enabled = YES;
                self.coursePopUp.enabled = YES;
                self.teacherIdPopUp.enabled = NO;
                
                NSAlert *alert = [[NSAlert alloc] init];
                
                alert.messageText = @"Couldn't fetch teachers";
                alert.informativeText = @"There was an error fetching the teachers list from server. Please try again later.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
            
            } else {
            
                NSArray *teachers = [[SPDataEntryApi sharedInstance] parseTeachersFromResponse:responseTeachers];
                [self.teacherPopUp addItemsWithTitles:teachers];
            
                [self.teacherPopUpIndicator stopAnimation:self];
                self.teacherPopUpIndicator.hidden = YES;
                self.teacherPopUp.enabled = YES;
                self.subjectPopUp.enabled = YES;
                self.coursePopUp.enabled = YES;
                self.teacherIdPopUp.enabled = NO;
            }
        }];
    }
}

- (IBAction)chooseTeacherClicked:(id)sender {
    
    if (self.teacherPopUp.indexOfSelectedItem == 0) {
        
        [self.teacherIdPopUp removeAllItems];
        self.teacherIdPopUp.enabled = NO;
        
    } else {
        
        self.teacherIdPopUpIndicator.hidden = NO;
        [self.teacherIdPopUpIndicator startAnimation:self];
        
        self.coursePopUp.enabled = NO;
        self.subjectPopUp.enabled = NO;
        self.teacherPopUp.enabled = NO;
        
        [[SPDataEntryApi sharedInstance] fetchTeacherIDFromName:self.teacherPopUp.selectedItem.title completion:^(NSArray *teacherArray, NSError *error) {
       
            if (error) {
            
                [self.teacherIdPopUpIndicator stopAnimation:self];
                self.teacherIdPopUpIndicator.hidden = YES;
                self.teacherIdPopUp.enabled = NO;
                self.teacherPopUp.enabled = YES;
                self.coursePopUp.enabled = YES;
                self.subjectPopUp.enabled = YES;
                
                NSAlert *alert = [[NSAlert alloc] init];
                
                alert.messageText = @"Couldn't fetch IDs";
                alert.informativeText = @"There was an error getting the IDs of teachers with this name. Please try again later.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else {
            
                NSArray *teacherId = [[SPDataEntryApi sharedInstance] parseTeacherIdFromResponse:teacherArray];
                
                [self.teacherIdPopUp addItemsWithTitles:teacherId];
            
                [self.teacherIdPopUpIndicator stopAnimation:self];
                self.teacherIdPopUpIndicator.hidden = YES;
                self.teacherIdPopUp.enabled = YES;
                self.teacherPopUp.enabled = YES;
                self.coursePopUp.enabled = YES;
                self.subjectPopUp.enabled = YES;
            }
        }];
    }
}

- (IBAction)addScheduleClicked:(id)sender {

    NSAlert *alert = [[NSAlert alloc] init];
    self.addScheduleProgressIndicator.hidden = NO;
    [self.addScheduleProgressIndicator startAnimation:self];
    
    NSString *startTimeHour = self.startTimeHourTextField.stringValue;
    NSString *startTimeMinute = self.startTimeMinuteTextField.stringValue;
    NSString *endTimeHour = self.endTimeHourTextField.stringValue;
    NSString *endTimeMinute = self.endTimeMinuteTextField.stringValue;
    
    if (startTimeHour.intValue > 12 || startTimeMinute.intValue > 59 || endTimeHour.intValue > 12 || endTimeMinute.intValue > 59 || startTimeHour.length > 2 || startTimeMinute.length > 2 || endTimeHour.length > 2 || endTimeMinute.length > 2 || startTimeHour.intValue <= 0 || endTimeHour.intValue <= 0 || startTimeMinute.intValue < 0 || endTimeMinute.intValue < 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Invalid time format entered";
        alert.informativeText = @"A valid time format is needed to create a schedule. Please check the time you entered again.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.coursePopUp.indexOfSelectedItem == 0 && self.subjectPopUp.indexOfSelectedItem > 0 && self.teacherPopUp.indexOfSelectedItem > 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Course required";
        alert.informativeText = @"Please choose the course.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.teacherPopUp.indexOfSelectedItem == 0 && self.coursePopUp.indexOfSelectedItem > 0 && self.subjectPopUp.indexOfSelectedItem > 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Teacher required";
        alert.informativeText = @"Please choose the teacher.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.subjectPopUp.indexOfSelectedItem == 0 && self.coursePopUp.indexOfSelectedItem > 0 && self.teacherPopUp.indexOfSelectedItem > 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Subject required";
        alert.informativeText = @"Please choose the subject of the schedule you want to add.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.coursePopUp.indexOfSelectedItem == 0 && self.subjectPopUp.indexOfSelectedItem == 0 && self.teacherPopUp.indexOfSelectedItem > 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Course and subject required.";
        alert.informativeText = @"Please choose the course and subject of the scheudle.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.coursePopUp.indexOfSelectedItem == 0 && self.subjectPopUp.indexOfSelectedItem > 0 && self.teacherPopUp.indexOfSelectedItem == 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Course and teacher required";
        alert.informativeText = @"Pleaes choose the course and teacher of the schedule.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.coursePopUp.indexOfSelectedItem > 0 && self.subjectPopUp.indexOfSelectedItem == 0 && self.teacherPopUp.indexOfSelectedItem == 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Subject and teacher required";
        alert.informativeText = @"Please choose the subject and teacher of the schedule.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else if (self.coursePopUp.indexOfSelectedItem == 0 && self.subjectPopUp.indexOfSelectedItem == 0 && self.teacherPopUp.indexOfSelectedItem == 0) {
        
        [self.addScheduleProgressIndicator stopAnimation:self];
        self.addScheduleProgressIndicator.hidden = YES;
        
        alert.messageText = @"Course, subject and teacher required";
        alert.informativeText = @"Please choose the course, subject and teacher of the schedule.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
        
    } else {
        
        if ([self.startTimeIntervalPopUp.selectedItem.title isEqualToString:@"PM"]) {
            
            startTimeHour = [NSString stringWithFormat:@"%d", startTimeHour.intValue + 12 ];
        } 
        
        if ([self.endTimeIntervalPopUp.selectedItem.title isEqualToString:@"PM"]) {
            
            endTimeHour = [NSString stringWithFormat:@"%d", endTimeHour.intValue + 12];
        }
        
        NSString *startTime = [NSString stringWithFormat:@"%@%@%@",startTimeHour, self.startTimeLabel.stringValue, startTimeMinute];
        NSString *endTime = [NSString stringWithFormat:@"%@%@%@", endTimeHour, self.endTimeLabel.stringValue, endTimeMinute];
        
        [[SPDataEntryApi sharedInstance] addScheduleForSection:self.sectionPopUp.selectedItem.title WithTeacherID:self.teacherIdPopUp.selectedItem.title AndSubjectTitle:self.subjectPopUp.selectedItem.title day:self.dayPopUp.selectedItem.title startTime:startTime endTime:endTime completion:^(BOOL sectionDuplicateSuccess, NSError *error) {
           
            if (error) {
                
                [self.addScheduleProgressIndicator stopAnimation:self];
                self.addScheduleProgressIndicator.hidden = YES;
                
                alert.messageText = @"Error";
                alert.informativeText = @"Server error.Please try again later.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else if (!sectionDuplicateSuccess) {
                
                [self.addScheduleProgressIndicator stopAnimation:self];
                self.addScheduleProgressIndicator.hidden = YES;
                
                alert.messageText = @"Schedule Duplication";
                alert.informativeText = @"There is already a class scheduled at the entered period. Please check the information you entered again.";
                alert.alertStyle = NSCriticalAlertStyle;
                [alert runModal];
                
            } else {
                
                NSLog(@"Schedule Added");
                [self.addScheduleProgressIndicator stopAnimation:self];
                self.addScheduleProgressIndicator.hidden = YES;
                
                alert.messageText = @"Success";
                alert.informativeText = @"A new schedule has been added.";
                alert.alertStyle = NSInformationalAlertStyle;
                [alert runModal];
                
                [self resetAfterSaving];
            }
        }];
    }
}
- (IBAction)clearClicked:(id)sender {
    
    [self clearForm];
}

- (void)clearForm {
    
    [self.coursePopUp selectItemAtIndex:0];
    [self.sectionPopUp removeAllItems];
    self.sectionPopUp.enabled = NO;
    [self.subjectPopUp removeAllItems];
    [self.subjectPopUp addItemWithTitle:@"-- Choose subject --"];
    self.subjectPopUp.enabled = NO;
    [self.teacherPopUp removeAllItems];
    [self.teacherPopUp addItemWithTitle:@"-- Choose teacher--"];
    self.teacherPopUp.enabled = NO;
    [self.teacherIdPopUp removeAllItems];
    self.teacherIdPopUp.enabled = NO;
    [self.startTimeHourTextField setStringValue:@""];
    [self.startTimeMinuteTextField setStringValue:@""];
    [self.endTimeHourTextField setStringValue:@""];
    [self.endTimeMinuteTextField setStringValue:@""];   
}

- (void)resetAfterSaving {
    
    [self.startTimeHourTextField setStringValue:@""];
    [self.startTimeMinuteTextField setStringValue:@""];
    [self.endTimeHourTextField setStringValue:@""];
    [self.endTimeMinuteTextField setStringValue:@""];
    
}

@end