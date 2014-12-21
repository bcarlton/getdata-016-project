#load necessary packages
library(dplyr)

#establishing the base working directory
working_dir <- '/home/brian/Coursera/Getting_and_Cleaning_Data/UCI\ HAR\ Dataset'

#setting working directory
setwd(working_dir)

#CREATING VECTOR OF ALL VARIABLE NAMES
#==========================================#

#Establish basic variables
nameVector <- c("subjectID", "trainOrTestID", "activityID", "activityDescription")

#read in names from the features.txt into a single vector
featureNames <- read.table(file="features.txt", header=FALSE, sep=" ", stringsAsFactors=FALSE)
featureNames <- featureNames[ ,2] #converts from data frame to vector

#combining all names together in one vector and removing placeholders
nameVector <- c(nameVector, featureNames)
rm(list=c("featureNames"))


#READING IN DATA AND ASSEMBLING DATA FRAME
#===============================================#

#creating df for activity descriptor lookup
setwd(working_dir)
actDescriptorDF <- read.table("activity_labels.txt", sep="", header=FALSE, stringsAsFactors=FALSE)

#Reading TEST data first
setwd(paste(working_dir, "/","test" , sep=""))

#creating vector of all subjectIDs for test group
subjectIDtest <- read.table(file="subject_test.txt", sep="", header=FALSE, stringsAsFactors=FALSE)
subjectIDtest <- as.character(subjectIDtest[,1]) #transform into a character vector
print("subjectIDtest vector created.")

#creating testOrTrainID vector for master data frame
testVec <- character()
for (i in 1:length(subjectIDtest)){
        testVec <- c(testVec, 'test')
}
print("testVec created")

#reading in activityID information and creating vector
activityIDtest <- read.table("y_test.txt", sep="", header=FALSE, stringsAsFactors=FALSE)
activityIDtest <- as.character(activityIDtest[,1])
print("activityIDtest vector created")

#creating activityDescription from activityID and actDescriptorDF
actDescTest <- character()
for (i in 1:length(activityIDtest)){
        actDescTest <- c(actDescTest, actDescriptorDF[actDescriptorDF[,1]==activityIDtest[i], 2])
}
print("actDescTest vector created")

#creating placeholder test data.frame
featureDFtest <- read.table("X_test.txt", sep="", header=FALSE, stringsAsFactors=FALSE)
print("featureDFtest created")

#Reading in TRAIN class data and merging with TEST data
setwd(paste(working_dir,"/train",sep=""))

#reading in train class subjectIDs
subjectIDtrain <- read.table("subject_train.txt", sep="", header=FALSE, stringsAsFactors=FALSE)
subjectIDtrain <- as.character(subjectIDtrain[,1])
print("subjectIDtrain vector created.")

#merging all subjectIDs into a single vector
subjectIDAll <- c(subjectIDtest, subjectIDtrain)
print("data merged and subjectIDAll vector created")

#create train vector for each subject ID entry
trainVec <- character()
for (i in 1:length(subjectIDtrain)){
        trainVec <- c(trainVec, "train")
}
print("trainVec created.")

#merge test and train vectors to make complete testOrTrainID
testOrTrainAll <- c(testVec, trainVec)
print("data merged and testOrTrainAll vector created")

#reading in activity ID labels for train data
activityIDtrain <- read.table("y_train.txt", sep="", header=FALSE, stringsAsFactors=FALSE)
activityIDtrain <- as.character(activityIDtrain[,1])
print("activityIDtrain vector created")

#create activity description based on activityIDtrain and actDescriptorDF
actDescTrain <- character()
for (i in 1:length(activityIDtrain)){
        actDescTrain <- c(actDescTrain, actDescriptorDF[actDescriptorDF[ ,1]==activityIDtrain[i], 2])
}
print("actDescTrain vector created")

#merging both activityID and activity description vectors into one
activityIDAll <- c(activityIDtest, activityIDtrain)
activityDescriptorAll <- c(actDescTest, actDescTrain)
print("activityIDAll vector created")
print("activityDescriptorAll vector created")

#reading in feature data from the train feature Dataset
featureDFtrain <- read.table("X_train.txt", sep="", header=FALSE, stringsAsFactors=FALSE)
print ("featureDFtrain data.frame created")

#merging the test and train feature dataframes
featureDFAll <- rbind(featureDFtest, featureDFtrain)

#assemble all data into a single, master data frame. Lead with 4 vectors and follow w/ feature DF.
masterDataFrame <- cbind(subjectIDAll, testOrTrainAll, activityIDAll, activityDescriptorAll, featureDFAll)
names(masterDataFrame) <- nameVector
print("masterDataFrame created")

#CLEANING masterDataFrame NAMES
#==========================================================
#removing parentheses at the end of the name
names(masterDataFrame) <- sub("\\(\\)", "", names(masterDataFrame))
print("End parentheses removed")

#removing intermediate hyphens from names
names(masterDataFrame) <- gsub("-", "", names(masterDataFrame))
print("Intermediate hyphens removed")

#remove errant closing parentheses in one of the Angle variables
names(masterDataFrame) <- sub("\\)\\,", ",", names(masterDataFrame))

#making variable names from feature set 'prettier' by uppercasing the first letter

#getting the list of all variables for feature set from features.info.txt
setwd(working_dir)
featureVarSet <- read.table("features_info.txt", header=FALSE, sep="\t", skip=32, nrows=17, stringsAsFactors=FALSE)
featureVarSet <- as.character(featureVarSet[,1])
featureVarSet <- strsplit(featureVarSet, "\\(")
featureVarVec <- character()
for (i in 1:length(featureVarSet)){
	featureVarVec <- c(featureVarVec, featureVarSet[[i]][[1]])
}
rm(featureVarSet)

#Uppercasing the first letter of all the feature variables in masterDataFrame
for(i in 1:length(featureVarVec)){
	names(masterDataFrame) <- sub(featureVarVec[i], paste(toupper(substr(featureVarVec[i], 1, 1)), substr(featureVarVec[i], 2, nchar(featureVarVec[i])), sep=""), names(masterDataFrame))
}

#converting the first 4 variables into characters from factors
for (i in 1:4) {
	masterDataFrame[,i] <- as.character(masterDataFrame[,i])
}

#remove unnecessary variables from current workspace(keep only the masterDataFrame)
rm(list=grep("master", ls(), invert=TRUE, value=TRUE))

#FILTER MASTER DATA TO GET MEAN AND STANDARD DEVIATION DATA
#==========================================================

#use grep() and c() to get all mean and std data
meanAndStdDF <- masterDataFrame[ ,c(names(masterDataFrame)[1:4], grep("Mean", names(masterDataFrame), value=TRUE), grep("Std", names(masterDataFrame), value=TRUE))]

#remove the angle variables from meanAndStdDF
meanAndStdDF <- meanAndStdDF[ ,grep("Angle", names(meanAndStdDF), value=TRUE, invert=TRUE)]

# #take meanAndStdDF data frame and  use dplyr to group by activity and subject
byActAndSubj <- group_by(meanAndStdDF, activityDescription, subjectID)
byActAndSubj <- summarise_each(byActAndSubj, funs(mean))
byActAndSubj <- byActAndSubj[ ,c(1,2,5:length(names(byActAndSubj)))]
byActAndSubj$subjectID <- as.integer(byActAndSubj$subjectID)
byActAndSubj <- arrange(byActAndSubj, activityDescription, subjectID)

#updates names of byActAndSubj to distinguish from meanAndStdDF
for (i in 3:length(names(byActAndSubj))){
        names(byActAndSubj)[i] <- paste("GroupedAvg-", names(byActAndSubj)[i], sep="")
}

#output byActAndSubj to text file to submit
#values are separated by " ", the default value in the write.table function
setwd("~/Coursera/Getting_and_Cleaning_Data/UCI HAR Dataset/")
write.table(byActAndSubj, file="BCarlton - GroupedAvgsByActivityAndSubj.txt", row.names=FALSE)