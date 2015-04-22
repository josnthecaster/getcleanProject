#load necessary libraries
library(dplyr)
library(tidyr)

#get the directories with the files and load the data,get the labels and subjects too
testdata <- read.table(file.path('UCI Har Dataset', 'test',"x_test.txt"))
testlabels <- read.table(file.path('UCI Har Dataset', 'test',"y_test.txt"))
testsubjects <- read.table(file.path("UCI Har Dataset", "test","subject_test.txt"))

traindata <- read.table(file.path('UCI Har Dataset','train',"X_train.txt"))
trainlabels <- read.table(file.path('UCI Har Dataset','train',"y_train.txt"))
trainsubjects <- read.table(file.path("UCI Har Dataset", "train","subject_train.txt"))

#bind the columns to each data
testdata <- cbind(testsubjects,testlabels,testdata)
traindata <- cbind(trainsubjects,trainlabels,traindata)

## 1. merge test and training data sets into one dataset
newDF <- rbind(testdata,traindata)

## 2. extract the measurements of mean and standard deviation for each measurement

#load the measurements
features <- read.table(file.path("UCI Har Dataset","features.txt"))

#add the names of the first columns so we can us them when we name the columns
#plus, it will match the dataframe size
newnames <- c(c("subject","activity"),as.vector(features[,2]))

#find which columns have the word "mean" in it as well as "std"
meancols <- grep("mean()",newnames)
stdcols <- grep("std()",newnames)

#make a vector of the columns, including subject and activity and update newDF
columns <- c(c(1,2),meancols,stdcols)
newDF <- newDF[,columns]

##3. use descriptive activities names

#load activities names
activities <- read.table(file.path("UCI Har Dataset","activity_labels.txt"))

#because we know it is the second col in the df, I will just update is's values
newDF[,2] <- activities[,2][c(newDF[,2])]

##4. label the dataset with descriptive variable names

#I'm a lazy programmer, so I will use the features (already on newnames)
#as the descriptive activities names
colnames(newDF) <- newnames[columns]

##5. create a tidy dataset with the average
##- for each variable
##- for each activity 
##- and each subject

#first use a tbl_df because I like it!
answer <- tbl_df(newDF)%>%
#get al variables in one place, so values get only one column
gather(variables,value,-subject,-activity)%>%
#group the data into what the problem asks, in the same order
group_by(variables,activity,subject)%>%
#make the average
summarize(average=mean(value,na.rm=TRUE))
#save it!
write.table(answer,"summary.txt")