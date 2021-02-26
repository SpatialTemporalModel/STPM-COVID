#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

file<-args[1]

tab<-read.table(file)

colnames(tab)<-c(colnames(tab[,1:6]), seq(0,length(tab)-7))

long<-gather(tab, "day", "cases" , 7:length(tab))

write.table(tab, quote=F, "~/Codeathon2021/Day_as_numbers_FL.csv", sep="\t", row.names=FALSE)
write.table(long, quote=F, "~/Codeathon2021/Day_as_numbers_long_FL.csv", sep="\t", row.names=FALSE)
