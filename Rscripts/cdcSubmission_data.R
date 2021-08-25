library(httr)
library(dbplyr)
library(jsonlite)
setwd("./")
#request to onepoint3
req=GET("https://instant.1point3acres.com/v1/api/coronavirus/us/cases?token=DnfsV7jy")
onepoint3_data=content(req)
master=onepoint3_data
#read the csv file from JHU
jhu_data=read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv",check.names = FALSE)
#list the column names to the console
#print(colnames(jhu_data))
#setwd("C:/Users/Siva Allam/project_files")
library(rio)
library(moments)
library(tidyverse)
library(dplyr)
#master=import("C:/Users/Siva Allam/project_files/onepoin3.xlsx")
#eliminate the recovered column rows

norecovered=subset(master,recovered_count==0)
#compute the min and max dates
min_date=min(as.Date(norecovered$confirmed_date, format="%Y-%m-%d"))
max_date=max(as.Date(norecovered$confirmed_date, format="%Y-%m-%d"))
#get the all_dates in b/w min and max
all_dates<-as.factor(seq.Date(min_date,max_date, by = "day"))
#get all states
states<-unique(norecovered$state_name)
#remove unwanted states
remove<-c("Veteran Affair", "Diamond Princess", "BOP", "Wuhan Evacuee", "Military", "Unassigned", "Grand Princess") 
states<-states [! states %in% remove]
#get the required rows where state is valid
requireddata <- filter(norecovered, norecovered$state_name %in% states)
#group by the dataset using date and state
stategrpby=requireddata %>% group_by(confirmed_date,state_name) %>% summarise(confirmed_total=sum(confirmed_count), death_total=sum(death_count))
finaldata=stategrpby %>% ungroup()
#generate data for all date and states
for(date in all_dates)
{
  date_exists=as.Date(date) %in% finaldata$confirmed_date
  if(date_exists)
  {
    temp=subset(stategrpby,confirmed_date==date)
    for(state in states)
    {
      state_exists=state %in% temp$state_name
      print(state_exists)
      if(!state_exists)
      {
        finaldata[nrow(finaldata)+1,]=list(as.Date(date),state,0,0)
      }
    }
    
  }
  else
  {
    for(state in states)
    {
      finaldata[nrow(finaldata)+1,]=list(as.Date(date),state,0,0)
    }
  }
}

finaldata=finaldata[order(finaldata$confirmed_date),]
futureData=finaldata

#add 6 future dates to final data
for(i in 1:6)
{
  max_date=max_date+1
  for(state in states)
  {
    futureData[nrow(futureData)+1,]=list(max_date,state,0,0)
  }
  
  print(max_date)
}

state_pop=data.frame("state_name"=c(
  "AK","AL","AR","AZ","CA","CO","CT","DC","DE","FL","GA","HI","IA","ID","IL","IN","KS","KY","LA","MA","MD","ME","MI","MN","MO","MS","MT","NC","ND","NE","NH","NJ","NM","NV","NY",
  "OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VA","VT","WA","WI","WV","WY"
), population=c(731545,4903185,3017804,7278717,39512223,5758736,3565287,705749,
                973764,21477737,10617423,1415872,3155070,1787065,12671821,
                6732219,2913314,4467673,4648794,6892503,6045680,1344212,9986857,
                5639632,6137428,2976149,1068778,10488084,762062,1934408,1359711,
                8882190,2096829,3080156,19453561,11689100,3956971,4217737,12801989,
                1059361,5148714,884659,6829174,28995881,3205958,8535519,623989,7614893,
                5822434,1792147,578759))

CasesPop=inner_join(futureData, state_pop, by = NULL, copy = FALSE, suffix = c(".x", ".y"))
CasesPop2=inner_join(finaldata, state_pop, by = NULL, copy = FALSE, suffix = c(".x", ".y"))

#write.csv(CasesPop,file="casesPop.csv")

#source("GLMER2_pipe2.R")

tmp2.df<-CasesPop

###Restructure the data set
total_rows=nrow(tmp2.df)
State<-rep(1:51,total_rows/51)
tmp2.df<-data.frame(tmp2.df,State)
tmp2.df<-tmp2.df[order(tmp2.df$state_name),]

###Add the Time variable
Time<-rep(1:(total_rows/51),51)
tmp2.df<-data.frame(tmp2.df,Time)

###Subset the data set to include num_days_back = 7 from the current date. This subset has 7+5=12 days and therefore 12*51=
num_days_back<-7
num_days_forward<-6
max_day<-max(tmp2.df$Time)
min_day<-max_day-num_days_back-num_days_forward+1

tmp2current.df<-tmp2.df[tmp2.df$Time>=min_day&tmp2.df$Time<=max_day,]
tmppos2.df<-tmp2current.df[!(tmp2current.df$confirmed_total<0),]

###Load the R libraries for GLMM
library(lme4)
library(splines)

###Calibrate the Time variable to start with 0
Time2<-tmppos2.df$Time-min(tmppos2.df$Time)
tmppos2.df<-data.frame(tmppos2.df,Time2)
##Linear Model (in Time)
gm1 <- glmer(confirmed_total ~ Time2 + (1 | state_name)+offset(log(population)), data = tmppos2.df, family = poisson(link = "log"), nAGQ = 100)

###Generate the prediction for one day
# tmp3.df<-tmppos2.df[tmppos2.df$Time2==num_days_back,]
# newdata<-tmp3.df
# str(p2 <- predict(gm1,newdata,type="response"))
# predicted<-round(p2)
# tmp3.df<-data.frame(tmp3.df,predicted)
# write.csv(tmp3.df,file="Onedayprediction.csv")

###Generate the predictions for next num_days_forward days
tmp3.df<-tmppos2.df[tmppos2.df$Time2>=num_days_back,]

newdata<-tmp3.df
str(p2 <- predict(gm1,newdata,type="response"))
predicted<-round(p2)
tmp3.df<-data.frame(tmp3.df,predicted)
tmp3_values<-tmp3.df  %>% group_by(state_name) %>% summarise(value=sum(predicted))
loc_data=read.csv("https://raw.githubusercontent.com/reichlab/covid19-forecast-hub/master/data-locations/locations.csv")
combined=inner_join(tmp3_values,loc_data,by=c("state_name"="abbreviation"))
combined$target="1 wk ahead inc case"
combined$forecast_date=max_date-5
combined$target_end_date=max_date
combined$type="point"
combined$quantile=""
final_combined=combined %>% select(location,target,type,quantile,forecast_date,target_end_date,value)
write.csv(final_combined,file=paste(max_date-5,'-USF-STPM.csv',sep=""),row.names = FALSE)



# #Map Visualizations.......................
# library(usmap)
# library(ggplot2) #use ggplot2 to add layer for visualization
# #get last 7 days date
# lastday_data=tail(CasesPop2,51)
# #write.csv(lastWeek_data,file="lastweek.csv")
# lastdaygrp_pop=inner_join(lastday_data, state_pop, by = NULL, copy = FALSE, suffix = c(".x", ".y"))
# lastdaygrp_pop$percapper1000=lastdaygrp_pop$confirmed_total/(lastdaygrp_pop$population/100000);
# colnames(lastdaygrp_pop)=c('date','state','confirmed_total','death_total','population','percapper1000')
# png(file="Lastday.png",
#     width=600, height=350)
# #plot graph for average of last 7 days data
# plot_usmap(data=lastdaygrp_pop,values="percapper1000",color='red')+
#   scale_fill_continuous(low="white",high="red",name="Cases per 100,000 residents",label=scales::comma)+labs(title=as.character(lastdaygrp_pop$date));
# dev.off()
# 
# 
# #visualization of predicted data
# nextday_data=tmp3.df[order(tmp3.df$confirmed_date),]
# nextday_data=head(nextday_data,51)
# #statePredictedgrpby=tmp3.df %>% group_by(state_name) %>% summarise(predicted_cases=mean(predicted))
# #write.csv(lastWeek_data,file="lastweek.csv")
# predictedgrp_pop=inner_join(nextday_data, state_pop, by = NULL, copy = FALSE, suffix = c(".x", ".y"))
# predictedgrp_pop$percapper1000=predictedgrp_pop$predicted/(predictedgrp_pop$population/100000);
# colnames(predictedgrp_pop)=c('date','state','confirmed_cases','deaths','population',
#                              'state_count','time','time2', 'predicted_cases','percapper1000')
# png(file="Predicted_nextday_average.png",
#     width=600, height=350)
# #plot graph for average of last 7 days data
# plot_usmap(data=predictedgrp_pop,values="percapper1000",color='red')+
#   scale_fill_continuous(low="white",high="red",name="Cases per 100,000 residents",label=scales::comma)+labs(title=as.character(predictedgrp_pop$date))
# dev.off()








