library(rio)
library(moments)
master=import("C:/Users/Siva Allam/project_files/onepoin3.xlsx")
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
library(tidyverse)
requireddata <- filter(norecovered, norecovered$state_name %in% states)
#group by the dataset using date and state
library(dplyr)
stategrpby=requireddata %>% group_by(confirmed_date,state_name) %>% summarise(confirmed_total=sum(confirmed_count), death_total=sum(death_count))
finaldata=stategrpby %>% ungroup()
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
        finaldata[nrow(finaldata)+1,]=list(date,state,0,0)
      }
    }
    
  }
  else
  {
    for(state in states)
    {
      finaldata[nrow(finaldata)+1,]=list(date,state,0,0)
    }
  }
}



      