cases<-read.table("~/Downloads/cases3.csv", header=T, sep=",")

#cases3<-cases[which(cases$DAY>=(max(cases$DAY)-3)),]

#coords<-cases3[,10:11]

library(spind)
#gee.fit<- GEE(confirmed_count ~ DAY,
#family = "poisson",
#data = cases3,
#coord = coords,
#corstr = "fixed",
#scale.fix = FALSE)

cases_FL<-cases[which(cases$state_name=="FL"),]
cases_FL<-cases_FL[which(cases_FL$DAY>=(max(cases$DAY)-7)),]

coords<-cases_FL[,10:11]


gee.fit<- GEE(confirmed_count ~ DAY,
family = "poisson",
data = cases_FL,
coord = coords,
corstr = "fixed",
scale.fix = FALSE)


