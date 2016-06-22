//
//  SPDataEntryApi.h
//  StudentPortalDataEntry
//
//  Created by Han Htoo Zaw on 10/27/15.
//  Copyright © 2015 HHZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface SPDataEntryApi : NSObject

+ (instancetype)sharedInstance;

- (void)fetchCourses:(void(^)(NSArray *responseArray, NSError *error))completionBlock;
- (NSArray *)parseCourseTitleFromResponse:(NSArray *)responseArray;
- (void)addSubjectWithId:(NSString *)subjectId subjectTitle:(NSString *)subjectTitle courseTitle:(NSString *)courseTitle completion:(void(^)(BOOL success, NSError *error))completionBlock;
- (void)fetchSubjectsOfCourse:(NSString *)course completionBlock:(void(^)(NSArray *subjectArray, NSError *error))completionBlock;
- (NSArray *)parseSubjectTitleFromResponse:(NSArray *)subjectsArray;

- (void)addTeacherWithId:(NSString *)ID name:(NSString *)name phone:(NSString *)phone email:(NSString *)email nrc:(NSString *)nrc dateOfBirth:(NSDate *)dateOfBirth username:(NSString *)username password:(NSString *)password position:(NSString *)position department:(NSString *)department gender:(NSString *)gender subjectOne:(NSString *)subjectOne subjectTwo:(NSString *)subjectTwo completion:(void(^)(BOOL success, NSError *error))completionBlock;
- (void)fetchSectionsOfCourse:(NSString *)course completion:(void(^)(NSArray *sectionsArray, NSError *error))completionBlock;
- (NSArray *)parseSectionTitleFromResponse:(NSArray *)sectionsArray;
- (void)addNewSectionToCourse:(NSString *)course completion:(void(^)(BOOL success, PFObject *sectionObject, NSError *error))completionBlock;
- (void)registerNewStudent:(NSString *)studentId studentName:(NSString *)studentName contact:(NSString *)studentContactNumber studentEmail:(NSString *)studentEmail studentNRC:(NSString *)studentNRC studentDOB:(NSDate *)studentDOB studentAddress:(NSString *)studentAddress studentGender:(NSString *)studentGender studentSection:(NSString *)studentSection studentUsername:(NSString *)studentUsername studentPassword:(NSString *)studentPassword completion:(void(^)(BOOL success, NSError *error))completionBlock;
- (void)fetchTeachersOfSubject:(NSString *)subjectTitle completion:(void(^)(NSArray *responseTeachers, NSError *error))completionBlock;
- (NSArray *)parseTeachersFromResponse:(NSArray *)response;
- (void)fetchTeacherIDFromName:(NSString *)teacherName completion:(void(^)(NSArray *teacherArray, NSError *error))completionBlock;
- (NSArray *)parseTeacherIdFromResponse:(NSArray *)response;- (void)addScheduleForSection:(NSString *)sectionName WithTeacherID:(NSString *)teacherId AndSubjectTitle:(NSString *)subjectTitle day:(NSString *)day startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(BOOL sectionDuplicateSuccess, NSError *error))completionBlock;
- (void)fetchSubjectWithTitle:(NSString *)subjectTitle completion:(void(^)(PFObject *subject, NSError *error))completionBlock;
- (void)addNotice:(NSString *)title Location:(NSString *)location Date:(NSDate *)date StartTime:(NSString *)startTime EndTime:(NSString *)endTime Description:(NSString *)description image:(PFFile *)imageFile completion:(void(^)(BOOL isNotDuplicate, NSError *error))completionBlock;

@end
