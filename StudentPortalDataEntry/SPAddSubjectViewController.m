//
//  SPAddSubjectViewController.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 10/27/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "SPAddSubjectViewController.h"
#import "SPDataEntryApi.h"

@interface SPAddSubjectViewController ()

@property (weak) IBOutlet NSTextField *subjectIdTextField;
@property (weak) IBOutlet NSTextField *subjectTitleTextField;
@property (weak) IBOutlet NSPopUpButton *coursePopUp;
@property (weak) IBOutlet NSProgressIndicator *courseLoadIndicator;
@property (weak) IBOutlet NSProgressIndicator *saveSubjectProgressIndicator;

@end

@implementation SPAddSubjectViewController

- (void)viewDidLoad {
    
    [self.view setWantsLayer:YES];
    NSColor *color = [NSColor colorWithDeviceRed:0.238f green:0.363f blue:0.438f alpha:1.0f];
    [self.view.layer setBackgroundColor:[color CGColor]];

    [self.coursePopUp removeAllItems];
    self.coursePopUp.enabled = NO;
    [self.courseLoadIndicator startAnimation:self];
    self.saveSubjectProgressIndicator.hidden = YES;
    [[SPDataEntryApi sharedInstance]fetchCourses:^(NSArray *responseArray, NSError *error) {
        
        if (error) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"There was a problem getting the courses from the server. Please check your connection or try again later"];
            [alert runModal];

        } else {
            
            NSArray *courseItems = [[SPDataEntryApi sharedInstance] parseCourseTitleFromResponse:responseArray];
            for (NSInteger i = 0; i < courseItems.count;i++) {
                
                [self.coursePopUp insertItemWithTitle:courseItems[i] atIndex:i];
            }
            
            [self.courseLoadIndicator stopAnimation:self];
            self.coursePopUp.enabled = YES;
        }
    }];
    [super viewDidLoad];
    
}

- (IBAction)addSubjectTapped:(id)sender {
    
    NSString *subjectId = self.subjectIdTextField.stringValue;
    NSString *subjectTitle = self.subjectTitleTextField.stringValue;
    
    if (subjectId.length > 0 && subjectTitle.length) {
        
        self.saveSubjectProgressIndicator.hidden = NO;
        [self.saveSubjectProgressIndicator startAnimation:self];
        
        [[SPDataEntryApi sharedInstance] addSubjectWithId:subjectId subjectTitle:subjectTitle courseTitle:self.coursePopUp.selectedItem.title completion:^(BOOL success, NSError *error) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            
            if (error) {
                
                [self.saveSubjectProgressIndicator stopAnimation:self];
                self.saveSubjectProgressIndicator.hidden = YES;
                
                [alert setAlertStyle:NSCriticalAlertStyle];
                [alert setMessageText:@"Error"];
                [alert setInformativeText:@"Could not connect to the server. Please try again later."];
                [alert runModal];
                
                
            } else if (!success) {

                [self.saveSubjectProgressIndicator stopAnimation:self];
                self.saveSubjectProgressIndicator.hidden = YES;
                
                [alert setAlertStyle:NSCriticalAlertStyle];
                [alert setMessageText:@"Duplicate subjects"];
                [alert setInformativeText:@"Subject with that ID is already registered. Please check your subject ID again."];
                [alert runModal];
                
            } else {
                
                [self.saveSubjectProgressIndicator stopAnimation:self];
                self.saveSubjectProgressIndicator.hidden = YES;
                
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert setMessageText:@"Success"];
                [alert setInformativeText:@"Subject registration is succesful."];
                [alert runModal];
            }
        }];
        
    } else {
        
        [self checkTextField];
    }
}
- (IBAction)clearClicked:(id)sender {
    
    self.subjectIdTextField.stringValue = @"";
    self.subjectTitleTextField.stringValue = @"";
    [self.coursePopUp selectItemAtIndex:0];
}

- (void)checkTextField {
    
    NSString *subjectId = self.subjectIdTextField.stringValue;
    NSString *subjectTitle = self.subjectTitleTextField.stringValue;
    NSAlert *alert = [[NSAlert alloc] init];
    if (subjectId.length == 0 && subjectTitle == 0) {
        
        [self.saveSubjectProgressIndicator stopAnimation:self];
        self.saveSubjectProgressIndicator.hidden = YES;
        
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Insufficient info"];
        [alert setInformativeText:@"Please enter subject ID and title."];
        [alert runModal];

        
    } else if (subjectId.length > 0 && subjectTitle.length == 0) {
        
        [self.saveSubjectProgressIndicator stopAnimation:self];
        self.saveSubjectProgressIndicator.hidden = YES;

        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Insufficient info"];
        [alert setInformativeText:@"Please enter subject title."];
        [alert runModal];
        
    } else {
        
        [self.saveSubjectProgressIndicator stopAnimation:self];
        self.saveSubjectProgressIndicator.hidden = YES;
        
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert setMessageText:@"Insufficient info"];
        [alert setInformativeText:@"Please enter subject ID."];
        [alert runModal];
    }
}

@end