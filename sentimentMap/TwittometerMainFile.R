##### Initialization #####
library(ggplot2)
library(ggmap) # library to plot world map
source('TwittometerFunctions.R')

# Twitter connection
initializeTwitter() 

# Cities database: do just once, then comment the following line
initializeCity()

#### User input ####
myInterest <- "Clinton"
citySelection <- c("New York NY","Miami FL","San Francisco CA","Dallas TX") 
tweetNrSelection <- 50 # number of tweets for each city

### main ####
load("data_us.Rda") # data_us.Rda available after initializeCity(); load complete_us
complete_us$City=iconv(complete_us$City,from="",to="UTF-8") # convert to UTF-8 to avoid error in tolower()
myCities <- complete_us[tolower(paste(complete_us$City,complete_us$Region,sep=" ")) %in% tolower(citySelection),]

pos_polarity=vector('numeric')
neg_polarity=vector('numeric')
myList=list()
for (i in (1:nrow(myCities))){
  myTweets <- getTweetCity(myLat=myCities$Latitude[i],
                           myLon=myCities$Longitude[i],
                           myRadius=50,
                           myKeyword=myInterest,
                           tweetNr=tweetNrSelection)

  mySent.df <- sentAnalysis(myTweets)
  getWordCloud(mySent.df$text,myCities$City[i])
  myList[[i]] <- mySent.df
  pos_polarity[i] <- nrow(myList[[i]][myList[[i]]$polarity=="positive",])/nrow(myList[[i]])
  neg_polarity[i] <- nrow(myList[[i]][myList[[i]]$polarity=="negative",])/nrow(myList[[i]])
}

myCities$positive <- pos_polarity
myCities$negative <- neg_polarity

myCities_pos <- myCities[myCities$positive > myCities$negative, ]
myCities_neg <- myCities[myCities$positive < myCities$negative, ]

map <- qmap('US',zoom=4)
#plot the city points on top
map <- map + geom_point(data =  myCities_pos,
                        aes(x = Longitude, y = Latitude), 
                        color="blue", size=2, alpha=0.5) + 
  geom_point(data = myCities_neg, 
             aes(x = Longitude, y = Latitude), 
             color="red", size=2, alpha=0.5)
show(map)

