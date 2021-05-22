library(httr)
library(dbplyr)
library(jsonlite)
#request to onepoint3
req=GET("https://instant.1point3acres.com/v1/api/coronavirus/us/cases?token=DnfsV7jy")
onepoint3_data=content(req)

#read the csv file from JHU
jhu_data=read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv",check.names = FALSE)
#list the column names to the console
print(colnames(jhu_data))


