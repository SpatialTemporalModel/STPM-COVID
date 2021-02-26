# Project Name: Spatial-Temporal Prediction Models for COVID-19 
---
**Team Leaders**: Awtum Brashear, Jing Lin, Ming Ji 

**Team Members**:  Michelle	Grundahl, Santiago	Hernandez, Weiliang	Cen, Deepika	Kolli, Siva Allam, Chang	Li, Charley	Wang

**GVN/USF mentors**:

## Introduction
Following the first cases of Coronavirus disease 2019 (COVID-19) in Wuhan-China, the Severe Acute Respiratory Coronavirus 2 (SARS-CoV-2) has spread worldwide to over 190 countries or territories (). This extremely contagious virus has been responsible for the ongoing pandemic that has claimed over two million lives around the world (). As of February 24th 2021, the US have reported 28,297,193 confirmed cases and 503,777 deaths (). As the COVID-19 pandemic continues, it is imperative to create bioinformatic tools that provide timely spatio-temporal forecast of the number of cases at local, regional and national level as a decision-making tool for public health professionals and state authorities.
## Objectives
The aim of this study is to propose a spatiotemporal epidemiological predictive model of COVID-19 infections at local, regional and national level to generate a forecast of COVID-19 daily cases and deaths in the United States of America. 

![Flowchart of objectives](https://github.com/USFOneHealthCodeathon2021/Team6/blob/main/Flow%20Chart.jpg)

## Methods and Implementation
Data was extracted from 1point3acres.com website which is a public database that uses epidemiologic and spatial data from the John Hopkins University coronavirus Resource Center. The R-package ‘caret’ was used to create a temporal and spatio-temporal prediction model of new cases and death on a county level. Regression was performed using the machine learning algorithm ‘Spatial Random Forest’ to create spatio-temporal prediction models.

Additionally, Diffusion Convolutional Recurrent Neural Network (DCRNN, https://github.com/liyaguang/DCRNN) was explored using similar database. The model can effectively utilize spatial-temporal data by accounting for spatial dependencies using diffusion convolutional layers and by accounting for temporal dependecies using recurrent layers. Adjacency matrix was calculated by each county's representative geo-coordinates, i.e. longitude and latitude and their pair-wise distance. Tensorflow v1.4 was used to apply the model to train and evaluate COVID-19 data. 

## Results 
