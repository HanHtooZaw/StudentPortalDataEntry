//
//  SPDataEntryApi.m
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 10/27/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import "SPDataEntryApi.h"
#import <Parse/Parse.h>

static NSString *timeSeperator = @":";

@implementation SPDataEntryApi

+ (instancetype)sharedInstance {
    
    static SPDataEntryApi *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SPDataEntryApi alloc] init];
    });
    return instance;
}

- (void)checkDuplicateSubject:(NSString *)subjectId completion:(void(^)(BOOL success, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Subject"];
    [query whereKey:@"subjectId" equalTo:subjectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error) {
            
            completionBlock(NO, error);
            
        } else if (objects.count > 0) {
            
            completionBlock(NO, nil);
            
        } else {
            
            completionBlock(YES, nil);
        }
    }];
}

- (void)fetchCourses:(void(^)(NSArray *responseArray, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Course"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
        } else {
            completionBlock(objects, nil);
            
        }
    }];
}

- (NSArray *)parseCourseTitleFromResponse:(NSArray *)responseArray {
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (PFObject *course in responseArray) {
        [tempArray addObject:[course objectForKey:@"courseTitle"]];
    }
    return [tempArray copy];
}

- (void)fetchCourseWithTitle:(NSString *)courseTitle subjectId:(NSString *)subjectId completion:(void(^)(BOOL success, PFObject *course, NSError *error))completionBlock {
    
    [self checkDuplicateSubject:subjectId completion:^(BOOL success, NSError *error) {
        if (error) {
            
            completionBlock(NO, nil, error);
            
        } else if (!success) {
            
            completionBlock(NO, nil, nil);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Course"];
            [query whereKey:@"courseTitle" equalTo:courseTitle];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
               
                if (error) {
                    
                    completionBlock(YES, nil, error);
                    
                } else {
                    
                    completionBlock(YES, object, nil);
                }
            }];
        }
    }];
}

- (void)addSubjectWithId:(NSString *)subjectId subjectTitle:(NSString *)subjectTitle courseTitle:(NSString *)courseTitle completion:(void(^)(BOOL success, NSError *error))completionBlock {
    
    [self fetchCourseWithTitle:courseTitle subjectId:subjectId completion:^(BOOL success, PFObject *course, NSError *error) {
        
        if (error) {
            
            completionBlock(NO, error);
            
        } else if (!success) {
            
            completionBlock(NO, nil);
            
        } else {
            
            PFObject *subject = [PFObject objectWithClassName:@"Subject"];
            [subject setValue:subjectId forKey:@"subjectId"];
            [subject setValue:subjectTitle forKey:@"subjectTitle"];
            [subject setValue:[PFObject objectWithoutDataWithClassName:@"Course" objectId:course.objectId] forKey:@"parentCourse"];
            [subject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
              
                if (error) {
                    
                    completionBlock(YES, error);
                    
                } else {
                    
                    completionBlock(YES, nil);
                }
            }];
        }
    }];
}

- (void)fetchSubjectsToSave:(NSString *)subjectOneTitle subjectTwo:(NSString *)subjectTwoTitle completion:(void(^)(NSArray *enteredSubjects, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Subject"];
    NSArray *subjects = @[subjectOneTitle, subjectTwoTitle];
    [query whereKey:@"subjectTitle" containedIn:subjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error) {
            
            completionBlock(nil, error);
            
        } else {
            
            completionBlock(objects, nil);
        }
    }];
}

- (void)checkDuplicateTeacher:(NSString *)teacherId subjectOne:(NSString *)subjectOneTitle subjectTwo:(NSString *)subjectTwoTitle completion:(void(^)(NSArray *enteredSubjects, BOOL success, NSError *error))completionBlock{
    
    
    [self fetchSubjectsToSave:subjectOneTitle subjectTwo:subjectTwoTitle completion:^(NSArray *enteredSubjects, NSError *error) {
        
        if (error) {
            
            completionBlock(nil, NO, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Teacher"];
            [query whereKey:@"teacherId" equalTo:teacherId];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                if (error) {
                    
                    completionBlock(enteredSubjects, YES, error);
                    
                } else if (objects.count > 0) {
                    
                    completionBlock(enteredSubjects, NO, nil);
                    
                } else {
                    
                    completionBlock(enteredSubjects, YES, nil);
                    
                }
            }];
        }
    }];
}

- (void)addTeacherWithId:(NSString *)ID name:(NSString *)name phone:(NSString *)phone email:(NSString *)email nrc:(NSString *)nrc dateOfBirth:(NSDate *)dateOfBirth username:(NSString *)username password:(NSString *)password position:(NSString *)position department:(NSString *)department gender:(NSString *)gender subjectOne:(NSString *)subjectOne subjectTwo:(NSString *)subjectTwo completion:(void(^)(BOOL success, NSError *error))completionBlock {
    
    [self checkDuplicateTeacher:ID subjectOne:subjectOne subjectTwo:subjectTwo completion:^(NSArray *enteredSubjects, BOOL success, NSError *error) {
        
        if (error) {
            
            completionBlock(YES, error);
             
        } else if (!success) {
            
            completionBlock(NO, nil);
            
        } else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                PFObject *subjectOne = enteredSubjects[0];
                PFObject *subjectTwo = enteredSubjects[1];
                
                PFObject *object = [PFObject objectWithClassName:@"Teacher"];
                [object setValue:ID forKey:@"teacherId"];
                [object setValue:name forKey:@"teacherName"];
                [object setValue:phone forKey:@"teacherPhone"];
                [object setValue:email forKey:@"teacherEmail"];
                [object setValue:nrc forKey:@"teacherNRC"];
                [object setValue:dateOfBirth forKey:@"teacherDOB"];
                [object setValue:username forKey:@"teacherUsername"];
                [object setValue:password forKey:@"teacherPassword"];
                [object setValue:position forKey:@"teacherPosition"];
                [object setValue:department forKey:@"teacherDepartment"];
                [object setValue:gender forKey:@"Gender"];
                
                PFRelation *relation = [object relationForKey:@"subjects"];
                [relation addObject:subjectOne];
                [relation addObject:subjectTwo];
                
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (error) {
                            completionBlock(YES, error);
                        } else {
                            completionBlock(YES, nil);
                        }
                    });
                }];
            });
        }
    }];
}

- (void)fetchCourse:(NSString *)course completion:(void(^)(NSString *courseObjectId, NSString *coursePrefix, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Course"];
    [query whereKey:@"courseTitle" equalTo:course];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if (error) {
            
            completionBlock(nil,nil, error);
            
        } else {
            
            completionBlock(object.objectId,[object objectForKey:@"coursePrefix"] , nil);
        }
    }];
}

- (void)fetchSubjectsOfCourse:(NSString *)course completionBlock:(void(^)(NSArray *subjectArray, NSError *error))completionBlock {
    
    [self fetchCourse:course completion:^(NSString *courseObjectId, NSString* coursePrefix, NSError *error) {
      
        if (error) {
            
            completionBlock(nil, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Subject"];
            [query whereKey:@"parentCourse" equalTo:[PFObject objectWithoutDataWithClassName:@"Course" objectId:courseObjectId]];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                if (error) {
                    
                    completionBlock(nil, error);
                    
                } else {
                    
                    completionBlock(objects, nil);
                }
                
            }];
        }
    }];
}

- (NSArray *)parseSubjectTitleFromResponse:(NSArray *)subjectsArray {
    
    NSMutableArray *tempSubArray = [[NSMutableArray alloc] init];
    for (PFObject *subject in subjectsArray) {
        
        [tempSubArray addObject:[subject objectForKey:@"subjectTitle"]];
    }
    return [tempSubArray copy];
}

- (void)fetchSectionsOfCourse:(NSString *)course completion:(void(^)(NSArray *sectionsArray, NSError *error))completionBlock {
    
    [self fetchCourse:course completion:^(NSString *courseObjectId, NSString *coursePrefix, NSError *error) {
        
        if (error) {
            
            completionBlock(nil, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Section"];
            [query whereKey:@"parentCourse" equalTo:[PFObject objectWithoutDataWithClassName:@"Course" objectId:courseObjectId]];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                
                if (error) {
                    
                    completionBlock(nil, error);
                    
                } else {
                    
                    completionBlock(objects, nil);
                }
                
            }];
        }
    }];
}

- (NSArray *)parseSectionTitleFromResponse:(NSArray *)sectionsArray {
    
    NSMutableArray *tempSecArray = [[NSMutableArray alloc] init];
    for (PFObject *section in sectionsArray) {
        
        [tempSecArray addObject:[section objectForKey:@"sectionName"]];
    }
    return [tempSecArray copy];
}

- (void)checkSectionOfCourse:(NSString *)course completion:(void(^)(BOOL isEmpty, PFObject *responseObject, NSString *courseId, NSString *coursePrefix, NSError *error))completionBlock {
    
    [self fetchCourse:course completion:^(NSString *courseObjectId, NSString *coursePrefix, NSError *error) {
    
        if (error) {
            
            completionBlock(NO , nil, nil, nil, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Section"];
            [query whereKey:@"parentCourse" equalTo:[PFObject objectWithoutDataWithClassName:@"Course" objectId:courseObjectId]];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
               
                if (error) {
                    
                    completionBlock(NO, nil, nil, nil, error);
                    
                } else if (objects.count == 0) {
                    
                    completionBlock(YES, nil, courseObjectId, coursePrefix, nil);
                    
                } else {
                    
                    completionBlock(NO, objects[objects.count - 1], courseObjectId, coursePrefix, nil);
                }
            }];
        }
    }];
}

- (void)addNewSectionToCourse:(NSString *)course completion:(void(^)(BOOL success, PFObject *sectionObject, NSError *error))completionBlock {
    
    [self checkSectionOfCourse:course completion:^(BOOL isEmpty, PFObject *responseObject, NSString *courseId, NSString *coursePrefix, NSError *error) {
       
        if (error) {
            
            completionBlock(NO, nil, error);
            
        } else if (isEmpty) {
            
            PFObject *object = [PFObject objectWithClassName:@"Section"];
            [object setValue:[PFObject objectWithoutDataWithClassName:@"Course" objectId:courseId] forKey:@"parentCourse"];
            [object setValue:@1 forKey:@"sectionNumber"];
            [object setValue:[NSString stringWithFormat:@"%@ - 1",coursePrefix] forKey:@"sectionName"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    completionBlock(NO, nil, error);
                } else {
                    completionBlock(YES, object, nil);
                }
            }];

        } else {
            
            PFObject *object = [PFObject objectWithClassName:@"Section"];
            [object setValue:[PFObject objectWithoutDataWithClassName:@"Course" objectId:courseId] forKey:@"parentCourse"];
            NSNumber *previousSectionNumber = [responseObject objectForKey:@"sectionNumber"];
            NSNumber *currentSectionNumber = @([previousSectionNumber integerValue] + 1);
            [object setValue:currentSectionNumber forKey:@"sectionNumber"];
            [object setValue:[NSString stringWithFormat:@"%@ - %@", coursePrefix, currentSectionNumber] forKey:@"sectionName"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    completionBlock(NO, nil, error);
                    
                } else {
                    
                    completionBlock(YES, object, nil);
                }
            }];
        }
    }];
}

- (void)checkDuplicateStudentWithId:(NSString *)studentId completion:(void(^)(BOOL success, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Student"];
    [query whereKey:@"studentId" equalTo:studentId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
       
        if (error) {
            
            completionBlock(NO, error);
            
        } else if (objects.count > 0) {
            
            completionBlock(NO, nil);
            
        } else {
            
            completionBlock(YES, nil);
        }
    }];
}

- (void)fetchSection:(NSString *)sectionName WithStudentId:(NSString *)studentId completion:(void(^)(PFObject *section, BOOL success, NSError *error))completionBlock {
    
    [self checkDuplicateStudentWithId:studentId completion:^(BOOL success, NSError *error) {
       
        if (error) {
            
            completionBlock(nil, NO, error);
            
        } else if (!success) {
            
            completionBlock(nil, NO, nil);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Section"];
            [query whereKey:@"sectionName" equalTo:sectionName];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
               
                if (error) {
                 
                    completionBlock(nil, YES, error);
                    
                } else {
                    
                    completionBlock(object, YES, nil);
                }
            }];
        }
    }];
}

- (void)registerNewStudent:(NSString *)studentId studentName:(NSString *)studentName contact:(NSString *)studentContactNumber studentEmail:(NSString *)studentEmail studentNRC:(NSString *)studentNRC studentDOB:(NSDate *)studentDOB studentAddress:(NSString *)studentAddress studentGender:(NSString *)studentGender studentSection:(NSString *)studentSection studentUsername:(NSString *)studentUsername studentPassword:(NSString *)studentPassword completion:(void(^)(BOOL success, NSError *error))completionBlock {
    
    [self fetchSection:studentSection WithStudentId:studentId completion:^(PFObject *section, BOOL success, NSError *error) {
       
        if (error) {
            
            completionBlock(NO, error);
            
        } else if (!success) {
            
            completionBlock(NO, nil);
            
        } else {
            
            PFObject *student = [PFObject objectWithClassName:@"Student"];
            [student setValue:studentId forKey:@"studentId"];
            [student setValue:studentName forKey:@"studentName"];
            [student setValue:studentContactNumber forKey:@"studentPhone"];
            [student setValue:studentEmail forKey:@"studentEmail"];
            [student setValue:studentNRC forKey:@"studentNRC"];
            [student setValue:studentDOB forKey:@"studentDOB"];
            [student setValue:studentAddress forKey:@"studentAddress"];
            [student setValue:studentGender forKey:@"studentGender"];
            [student setValue:section forKey:@"studentSection"];
            [student setValue:studentUsername forKey:@"studentUsername"];
            [student setValue:studentPassword forKey:@"studentPassword"];
            [student saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               
                if (error) {
                    
                    completionBlock(NO, error);
                    
                } else {
                    
                    completionBlock(YES, nil);
                }
            }];
        }
    }];
}

- (void)fetchSubjectWithTitle:(NSString *)subjectTitle completion:(void(^)(PFObject *subject, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Subject"];
    [query whereKey:@"subjectTitle" equalTo:subjectTitle];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
       
        if (error) {
            
            completionBlock(nil, error);
            
        } else {
            
            completionBlock(object, nil);
        }
    }];
}

- (void)fetchTeachersOfSubject:(NSString *)subjectTitle completion:(void(^)(NSArray *responseTeachers, NSError *error))completionBlock {
    
    [self fetchSubjectWithTitle:subjectTitle completion:^(PFObject *subject, NSError *error) {
       
        if (error) {
            
            completionBlock(nil, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Teacher"];
            [query whereKey:@"subjects" equalTo:subject];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                

                if (objects.count == 0) {
                    
                    completionBlock(nil, error);
                    
                } else {
                    completionBlock(objects, nil);
                    
                }
            }];
        }
    }];
}

- (NSArray *)parseTeachersFromResponse:(NSArray *)response {
    
    NSMutableArray *tempTeacherArray = [[NSMutableArray alloc] init];
    for (PFObject *teachers in response) {
        
        [tempTeacherArray addObject:[teachers objectForKey:@"teacherName"]];
    }
    return [tempTeacherArray copy];
}

- (void)fetchTeacherIDFromName:(NSString *)teacherName completion:(void(^)(NSArray *teacherArray, NSError *error))completionBlock {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Teacher"];
    [query whereKey:@"teacherName" equalTo:teacherName];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error) {
            
            completionBlock(nil, error);
            
        } else {
            
            completionBlock(objects, nil);
        }
    }];
}

- (NSArray *)parseTeacherIdFromResponse:(NSArray *)response {
    
    NSMutableArray *tempIdArray = [[NSMutableArray alloc] init];
    for (PFObject *teacher in response) {
        
        [tempIdArray addObject:[teacher objectForKey:@"teacherId"]];
    }
    return [tempIdArray copy];
}

- (void)fetchSectionOfName:(NSString *)sectionName subjectTitle:(NSString *)subjectTitle completion:(void(^)(PFObject *section, PFObject *subject, NSError *error))completionBlock {
    
    [self fetchSubjectWithTitle:subjectTitle completion:^(PFObject *subject, NSError *error) {
        
        if (error) {
            
            completionBlock(nil, nil, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Section"];
            [query whereKey:@"sectionName" equalTo:sectionName];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                
                if (error) {
                    
                    completionBlock(nil, nil, error);
                    
                } else {
                    
                    completionBlock(object, subject, nil);
                }
            }];
        }
    }];
}


- (void)fetchTeacherFromID:(NSString *)teacherID WithSectionName:(NSString *)sectionName AndSubjectTitle:(NSString *)subjectTitle completion:(void(^)(PFObject *section, PFObject *subject, PFObject *teacher, NSError *error))completionBlock {
    
    [self fetchSectionOfName:sectionName subjectTitle:subjectTitle completion:^(PFObject *section, PFObject *subject, NSError *error) {
       
        if (error) {
            
            completionBlock(nil, nil, nil, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Teacher"];
            [query whereKey:@"teacherId" equalTo:teacherID];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
               
                if (error) {
                    
                    completionBlock(nil, nil, nil, error);
                    
                } else {
                    
                    completionBlock(section, subject, object, nil);
                }
            }];
        }
    }];
}

- (void)checkDuplicateScheduleOfSection:(NSString *)sectionName WithTeacherID:(NSString *)teacherId AndSubjectTitle:(NSString *)subjectTitle day:(NSString *)day startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(PFObject *section, PFObject *subject, PFObject *teacher, BOOL sectionDuplicateSuccess, NSError *error))completionBlock {
    
    [self fetchTeacherFromID:teacherId WithSectionName:sectionName AndSubjectTitle:subjectTitle completion:^(PFObject *section, PFObject *subject, PFObject *teacher, NSError *error) {
       
        if (error) {
            
            completionBlock(section, subject, teacher, NO, error);
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"ClassSchedules"];
            [query whereKey:@"Section" equalTo:section];
            [query whereKey:@"Day" equalTo:day];
            [query whereKey:@"startTime" equalTo:startTime];
            [query whereKey:@"endTime" equalTo:endTime];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
               
                if (error) {
                    
                    completionBlock(section, subject, teacher, NO, error);
                    
                } else if (objects.count > 0) {
                    
                    completionBlock(section, subject, teacher, NO, nil);
                    
                } else {
                    
                    completionBlock(section, subject, teacher, YES, nil);
                }
            }];
        }
    }];
}

- (void)addScheduleForSection:(NSString *)sectionName WithTeacherID:(NSString *)teacherId AndSubjectTitle:(NSString *)subjectTitle day:(NSString *)day startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(BOOL sectionDuplicateSuccess, NSError *error))completionBlock {
    
    [self checkDuplicateScheduleOfSection:sectionName WithTeacherID:teacherId AndSubjectTitle:subjectTitle day:day startTime:startTime endTime:endTime completion:^(PFObject *section, PFObject *subject, PFObject *teacher, BOOL sectionDuplicateSuccess, NSError *error) {
       
        if (error) {
            
            completionBlock(NO, error);
            
        } else if (!sectionDuplicateSuccess) {
            
            completionBlock(NO, nil);
            
        } else {
            
            PFObject *schedule = [PFObject objectWithClassName:@"ClassSchedules"];
            [schedule setValue:day forKey:@"Day"];
            [schedule setValue:section forKey:@"Section"];
            [schedule setValue:subject forKey:@"Subject"];
            [schedule setValue:teacher forKey:@"Teacher"];
            [schedule setValue:startTime forKey:@"startTime"];
            [schedule setValue:endTime forKey:@"endTime"];
            [schedule setValue:subjectTitle forKey:@"subjectTitle"];
            [schedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
               
                if (error) {
                    
                    completionBlock(YES, error);
                    
                } else {
                    
                    completionBlock(YES, nil);
                }
            }];
        }
    }];
}

- (void)addNotice:(NSString *)title Location:(NSString *)location Date:(NSDate *)date StartTime:(NSString *)startTime EndTime:(NSString *)endTime Description:(NSString *)description image:(PFFile *)imageFile completion:(void(^)(BOOL isNotDuplicate, NSError *error))completionBlock {
    
    PFQuery *duplicateNotice = [PFQuery queryWithClassName:@"Noticeboard"];
    [duplicateNotice whereKey:@"location" equalTo:location];
    [duplicateNotice whereKey:@"date" equalTo:date];
    [duplicateNotice whereKey:@"startTime" equalTo:startTime];
    [duplicateNotice whereKey:@"endTime" equalTo:endTime];
    [duplicateNotice findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
       
        if (error) {
            
            completionBlock(NO, error);
            
        } else if (objects.count > 0) {
            
            completionBlock(NO , nil);
            
        } else {
            
            PFObject *notice = [PFObject objectWithClassName:@"Noticeboard"];
            [notice setValue:title forKey:@"title"];
            [notice setValue:location forKey:@"location"];
            [notice setValue:date forKey:@"date"];
            [notice setValue:startTime forKey:@"startTime"];
            [notice setValue:endTime forKey:@"endTime"];
            [notice setValue:description forKey:@"description"];
            [notice setValue:imageFile forKey:@"image"];
            [notice saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (error) {
                    
                    completionBlock(YES, error);
                    
                } else {
                    
                    completionBlock(YES, nil);
                }
            }];
        }
    }];
}

@end
