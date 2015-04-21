#load necessary libraries
library(dplyr)
library(tidyr)

#get the directories with the files and load the data,get the labels and subjects too
testdata <- tbl_df(read.table(file.path('UCI Har Dataset', 'test',"x_test.txt")))
testlabels <- read.table(file.path('UCI Har Dataset', 'test',"y_test.txt"))[,1]
testsubjects <- read.table(file.path("UCI Har Dataset", "test","subject_test.txt"))[,1]

traindata <- tbl_df(read.table(file.path('UCI Har Dataset','train',"X_train.txt")))
trainlabels <- read.table(file.path('UCI Har Dataset','train',"y_train.txt"))[,1]
trainsubjects <- read.table(file.path("UCI Har Dataset", "train","subject_train.txt"))[,1]

activities <- read.table(file.path("UCI Har Dataset","activity_labels.txt"))[,2]

#merge test and training data sets into one
#I prefer bind_rows as it does not change the order nor needs an ID
midata <- bind_rows(testdata,traindata)

#extract the measurements of mean and standar deviation for each measurement
#load the measurements
features <- read.table(file.path("UCI Har Dataset","features.txt"))[,2]
#find which columns have the word "mean" in it as well as "std"
meancols <- grep("mean()",features)
stdcols <- grep("std()",features)
#make a vector of the columns and use midata2 as the new dataFrame
columns <- c(meancols,stdcols)
midata2 <- midata[,columns]

#use descriptive activities names
activityName <- activities[c(testlabels,trainlabels)]

#label the dataset with descriptive variable names
columnnames <- features[columns]
colnames(midata2) <- columnnames

#create a tidy dataset with the average for each variable for each activity and each subject
subject <- c(testsubjects,trainsubjects)
midata2 <- bind_cols(midata2,data.frame(subject = subject, activity = activityName))%>%
    tbl_df()#%>%
gather(midata2,variables,value,-subject,-activity)%>%
    #answer is wrong if I use this:
    #separate(variables,c("variable","measure","axis"))%>%
    group_by(variables,activity,subject)%>%
    summarize(average=mean(value,na.rm=TRUE))%>%
write.table("summary.txt")