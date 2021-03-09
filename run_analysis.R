library(tidyr)
library(dplyr)
library(lubridate)


# Downloading and unzipping the data --------------------------------------


temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
unzip(zipfile = temp, exdir = getwd())


# Reading the data --------------------------------------------------------


features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("class_num", "activity"))

x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)

y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "class_num")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "class_num")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")


# Merging the data --------------------------------------------------------

x_total <- rbind(x_train,x_test)
y_total <- rbind(y_train, y_test)
subject_total <- rbind(subject_train, subject_test)

DATA <- cbind(subject_total, y_total, x_total)


# Selecting only the mean and std variables -------------------------------

tidy_data <- DATA %>% select(subject, class_num, contains("mean"), contains("std"))

tidy_data$class_num <- activities[tidy_data$class_num, 2]
tidy_data <- rename(tidy_data, activities = class_num) #renaming activities variable


# Renaming the variables --------------------------------------------------

names(tidy_data)<-gsub("mean", "Mean", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("std", "STD", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("freq", "Frequency", names(tidy_data), ignore.case = TRUE)
names(tidy_data)<-gsub("^t", "Time", names(tidy_data))
names(tidy_data)<-gsub("^f", "Frequency", names(tidy_data))
names(tidy_data)<-gsub("[Aa]cc", "Acceleration", names(tidy_data))
names(tidy_data)<-gsub("angle", "Angle", names(tidy_data))
names(tidy_data)


# Creating the second tidy data of means ----------------------------------

tidy_data <-  group_by(tidy_data, subject, activities)
Mean_data <- summarise_all(tidy_data, mean)
Mean_data

write.table(Mean_data, file = "MeanData.txt", row.names = FALSE)
