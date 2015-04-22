#Preamble
##Tidy Data
Tidy data is a single table that is easy to analize, because we know that each column has a single 
variable, and ecery row has an observation.

In the tidy data produced by this R code, each "feature" as per the original file, is an observation
of a single value in movement from a cell phone, so I consider it as an observation "each",
so it can be moved to a single column, in the end, I get a dataframe that consists of the variable
observed, be a movement, in any direction, it's mean or standard deviation, what kind of activity
was being made, and the subject who was making it, and in the end, the value of the variable.

This data is easy to read, to understand and better, to analize and use in any other R code ;)

#How the code works, line by line
Load the necessary libraries
		library(dplyr)
		library(tidyr)

Get the directories with the files and load the data, its labels and subjects
		testdata <- read.table(file.path('UCI Har Dataset', 'test',"x_test.txt"))
		testlabels <- read.table(file.path('UCI Har Dataset', 'test',"y_test.txt"))
		testsubjects <- read.table(file.path("UCI Har Dataset", "test","subject_test.txt"))

		traindata <- read.table(file.path('UCI Har Dataset','train',"X_train.txt"))
		trainlabels <- read.table(file.path('UCI Har Dataset','train',"y_train.txt"))
		trainsubjects <- read.table(file.path("UCI Har Dataset", "train","subject_train.txt"))

Bind the columns to each data, so we have complete dataframes for each observation
		testdata <- cbind(testsubjects,testlabels,testdata)
		traindata <- cbind(trainsubjects,trainlabels,traindata)

## 1. merge test and training data sets into one dataset

We bind the two data frames by rows, and because the same columns were added
in the same order, we get a complete dataframe
		newDF <- rbind(testdata,traindata)

## 2. extract the measurements of mean and standard deviation for each measurement

Load the measurements
		features <- read.table(file.path("UCI Har Dataset","features.txt"))

and add the names of the first columns we added to the dataframe
		newnames <- c(c("subject","activity"),as.vector(features[,2]))

Find which columns have the word "mean" in it as well as "std"
		meancols <- grep("mean()",newnames)
		stdcols <- grep("std()",newnames)

Make a vector of the columns, including subject and activity and update newDF
so it will have only the columns that we are asked
		columns <- c(c(1,2),meancols,stdcols)
		newDF <- newDF[,columns]

##3. use descriptive activities names

Load activities names
		activities <- read.table(file.path("UCI Har Dataset","activity_labels.txt"))

in activities, there are two columns, we will use the second, which is a factor
it will create a new factor from the vector of activities from newDF
I know it is the second column on newDF, that's why I used it
		newDF[,2] <- activities[,2][c(newDF[,2])]

##4. label the dataset with descriptive variable names

The descriptive variables were already on "features.txt", which we used
to create the newnames vector, and as columns has the columns we used to
slice our dataframe, we can use them to name our newDF
		colnames(newDF) <- newnames[columns]

##5. create a tidy dataset with the average
- for each variable
- for each activity 
- and each subject

The tidyr and dplyr packages were used to make the data "tidy"

first, make a variable so the code will give no weird answer at the end as feedback
		answer <- tbl_df(newDF)%>%
Get al variables in one place, so values get only one column, we should left subject
and activity in separate columns to be analized
		gather(variables,value,-subject,-activity)%>%
Group the data into what the problem asks, in the same order
		group_by(variables,activity,subject)%>%
We then summarize the means(average) of al the values, this is what "answer" will get
		summarize(average=mean(value,na.rm=TRUE))
The write it to "summary.txt" so we can load our tidy data any time
		write.table(answer,"summary.txt")