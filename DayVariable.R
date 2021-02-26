#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

type<-args[1]

#method one works for wide dataset from FL dataset method 2 is more robust for long datasets (like th all data county)

if (type == "1"){
	file<-args[2]
	tab<-read.table(file)
	colnames(tab)<-c(colnames(tab[,1:6]), seq(0,length(tab)-7))
	long<-gather(tab, "day", "cases" , 7:length(tab))
	write.table(tab, quote=F, "~/Codeathon2021/Day_as_numbers_FL.csv", sep="\t", row.names=FALSE)
	write.table(long, quote=F, "~/Codeathon2021/Day_as_numbers_long_FL.csv", sep="\t", row.names=FALSE)
} else if (type == "2") {
	file<-args[2]
	tab<-read.table(file, head=T, sep=",")
	m<-min(as.Date(tab$confirmed_date, format="%m/%d/%y"))
	df<-data.frame()
	for (date in tab$confirmed_date){
	df<-rbind(df, data.frame(DAY=as.numeric(as.Date(date, format="%m/%d/%y")-as.Date(m, format="%m/%d/%y"))))
	tab$DAY<-df$DAY
	write.table(tab, quote=F, "~/Codeathon2021/Day_as_numbers_countyID.csv", sep="\t", row.names=FALSE)
}


