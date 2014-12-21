---
title: "README"
author: "Brian Carlton"
date: "12/20/2014"
output: html_document
---


Greetings! This is my introduction to the Coursera - Getting and Cleaning Data course project.  My name is Brian Carlton, and I am the author of the work that you are reviewing.  This readme file serves to summarize the nature of the course project and to give some detail in how I went about accomplishing the goal of said project. I hope the day finds you well, and, furthermore, I hope that you enjoy my work!


##**Summary**
The course project aims for students to apply their knowledge to take some data that may be otherwise considered untidy and transform it into a coherent and well-structured data set according to the principles of tidy data. 

We'll be working with data from a study performed on human activity recognition (HAR) by the Nonlinear Complex Systems Laboratory at the Università degli Studi di Genova in Genoa, Italy.  As this will be published on GitHub, I shall reference the publication of their research now:

>Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. *"Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine."* International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

The data was obtained from the following link as placed on the course project page itself: <https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

The scope of this document is to explain how I accomplished the goals of the project.  However, the HAR dataset goes into more detail about the nature of their experimentation, so I advise interested readers to consult the readme.txt file included with their dataset. As such, I will only discuss the details of the experiment minimally.

##**Objective 1: Merge the training and the test sets to create one data set.**

The researchers randomly divided their 30 subjects into two groups: a test data set and a train data set.  Each subject was recorded doing 6 different activities, and from their data, the HAR team from Genoa calculated 561 distinct variables fo each subject. To create one full data set, I needed to assemble the following:

The Subject ID (an integer value from 1 to 30)  
A test or train ID (character value containing either "test" or "train") 
The activity ID (an integer from 1 to 6)  
The activity description (One of six character values matching the corresponding activity ID: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)   
The 561 measured variables corresponding to each subject, activity and group  

Readers curious about the individual variables should again be directed to the original dataset. The document titled features_info.txt describes the nature of each of the variables.  I will be going into some detail in the codebook file that accompanies the data frame being submitted as part of this project.

To begin to assemble this single data frame, I first established the names of all variables in a single vector.  I hand coded the name of the first 4 variables as "subjectID", "testOrTrainID", "activityID" and "activityDescription".  Then, I retrieved the names of all 561 variables by reading in the features.txt file from the dataset, as indicated by the study's readme file. I put the handcoded variables and the feature variable names together to form a name vector.

After assembling all the names together, I went to work assembling the actual data. My strategy was to read the data into placeholder variables from the test and train sets first. Afterward, I assembled all corresponding variables from the test and train sets into single vectors/data frames to be assembled into one giant data frame.  You can read the breakdown of the steps here:

1. Read in the reference file that mapped the activity ID number to the name of the activity itself.  That information is found in the activity_labels.txt file.  I read that information into its own data frame to be referenced later after getting the activity IDs.

2. The data for the test and train sets are found within directories naturally titled 'test' and 'train'.  From the test directory, I read in the subjectIDs for each observation from the file called subject_test.txt.  This file contained one column of data in which each row represented the subject ID for that particular observation.  The data were stored in a placeholder vector to be combined with the subject IDs from the train set.

3. As I was working with test data first, all values in the testOrTrainID needed to be set to 'test'.  I made a vector that matched the length of the subjectID vector from the previous step with nothing but the value 'test' in each cell.

4. The activity IDs are found in a file called 'y_test.txt'. Like the subjectID information, this file contained a single column of integers in which each row was the activityID for that particular instance. Again, I stored these in a placeholder vector.

5. From the activityIDs in step 4 and the activity labels in step 1, I created another vector that translated the activityID numbers to more human readable text.  This again was store in a placeholder.

6. The final piece, the feature set, was contained in a file called 'X_test.txt'.  Each row corresponded to the same instance that the subject_test.txt and y_text.txt reference. Thus, I read these 561 variables into a placeholder data frame to be combined with the train data.

Steps 1 through 6 were repeated again for the train data found in the train directory.  The files were labeled the same except for the fact that wherever the fact that train was swapped for test (i.e. subject_test.txt -> subject_train.txt)  Placeholders for all of the train data were created, and then each corresponding placeholder from the test and train data were combined into one vector/data frame.  In the run_analysis.R script code, said combinations are denoted by containing the word 'All' in their definitions.

Finally, when all of the placeholders were combined from the test and train sets, I assembled all information into one data frame, named masterDataFrame.  These placeholders were combined in order that they were listed above: subjectID, testOrTrainID, activityID, activityDescription, and the 561 features.  Then using the namevector created initially, I assigned that to the names of the data frame.  Afterward, I cleaned the names of the variables using grep functions to remove unnecessary parentheses and hyphens.

The assembly of masterDataFrame completed objective 1.


##**Objective 2: Extract only the measurements on the mean and standard deviation for each measurement.**

A large variety of aggregate data was included in the 561 feature set, such as means, minimums, maximums and other custom measurements.  As the objective only required concerning ourselves with mean and standard deviation, I learned from the features_info.txt file that said measurements would end with mean() and std().  Furthermore, there was a custom measurement related to specific data called meanFreq (mean frequency).  This meanFreq is a weighted average of specific data, and, as there was no explicit instruction to filter it, I have included it with this dataset.

A subset of the masterDataFrame was taken using the grep functions and saved into a dataframe called meanAndStdDF.

##**Objective 3: Use descriptive activity names to name the activities in the data set.**

Objective 3 has been satisfied by adding the 'activityDescription' column to the initial data frame assembly.  All descriptions have been applied programmatically from matching the activity ID with the corresponding description from the 'activity_labels.txt' file included with the original data set. 

##**Objective 4: Appropriately label the data set with descriptive variable names.**

Objective 4 has been satisfied from the beginning assembly of the initial data frame.  All names were taken directly from the source data set.  Detailed descriptions of said variables will be found in the accompanying codebook and in the features_info.txt file accompanying the HAR team's original work, referenced earlier.

##**Objective 5: From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.  **

Objective 5 requests taking the filtered set containing only mean and standard deviation data and creating a new set that averages each of those variables by activity and subject.  Thus, the structure of the table will contain an activity description column, followed by a subject ID column and then the remaining columns will be the respective grouped averages.  Each cell is the grouped data of all entries of the intersection of a particular subject, activity and variable.  

This can be accomplished by using the dplyr packages group_by and summarise functions as seen in the script.

The final datasets are exported using the write.file type functions.

##**Additional Notes**

In the assembly of the initial data frame, there are duplicate variable names given to many columns containing information about bands energy (see the dataset readme for further information).  Naturally, having duplicate variable names violates tidy data principles.  However, these variables were not important to the further objectives, so I left them as is in the masterDataFrame.  Their presence will not influence the further objectives.  

##**Wrap Up**

Thank you for taking the time to review this readme document.  I hope that it serves its purpose well and that you have a clear idea of what this project's goals are and how I accomplished said goals.  Again, for more in depth information about the HAR Study, please see the original work from the researchers.  I will reference the study again for convenience:

>Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. *"Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine."* International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

Also, to satisfy other elements of this project, I will be submitting a codebook file to describe the variables from the mean and standard deviation filtered data.  The script will be found on my project repository at GitHub: <https://github.com/bcarlton/getdata-016-project>

Thank you very much for reading!  May good data be with you!