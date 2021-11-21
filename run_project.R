# Getting and Cleaning Data
# Week 4 Assignment
# Marcos Medeiros, November 2021

library(data.table)
library(dplyr)

# set working directory
setwd("C:/Users/Marcos/Desktop/Projetos_R/Cleaning_Data")

# downloading UCI data files from the web, unzip them, and specify time/date settings
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
        download.file(URL, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
        unzip(destFile)
}
dateDownloaded <- date()

# reading files
setwd("C:/Users/Marcos/Desktop/Projetos_R/Cleaning_Data/UCI HAR Dataset")

# reading activity files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

# reading features files
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

# reading subject files
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

# reading activity labels
ActivityLabels <- read.table("./activity_labels.txt", header = F)

# reading features names
FeaturesNames <- read.table("./features.txt", header = F)

# merg dataframes: features test&train, activity test&train, subject test&train
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

# renaming colums in ActivityData & ActivityLabels dataframes
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

# activity names factor 
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

# renaming SubjectData columns
names(SubjectData) <- "Subject"

# renaming FeaturesData columns from FeaturesNames
names(FeaturesData) <- FeaturesNames$V2

# new dataset with variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

# new datasets with the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

# renaming the columns of the large dataset with activity names
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

# creating an independent tidy data set with the mean of each variable for each activity and each subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

# saving tidy dataset to local file
write.table(SecondDataSet, file = "tidydata.txt",row.name=FALSE)