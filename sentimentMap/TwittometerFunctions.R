library(twitteR)
library(ROAuth)
library(wordcloud)
library(RColorBrewer)
library(plyr)
library(ggplot2)
library(sentiment)

initializeTwitter <- function(){
  # Declare Twitter API Credentials
  api_key <- "" 
  api_secret <- "" 
  token <- "" 
  token_secret <- "" 
  setup_twitter_oauth(api_key, api_secret, token, token_secret)
}


initializeCity <- function(){
  # create dataframe with us cities and relative coordinates. 
  # Download the database at: http://download.maxmind.com/download/worldcities/worldcitiespop.txt.gz
  complete <- read.csv("worldcitiespop.txt", stringsAsFactors = FALSE)
  complete_us=complete[complete$Country=="us",] 
  save(complete_us,file="data_us.Rda")
}


getTweetCity <- function(myLat=51.508515,
                         myLon=-0.125487,
                         myRadius=50,
                         myKeyword="Clinton",
                         tweetNr=10){
  # get tweets around given coordinates
  myRadius <- paste(myRadius,"mi",sep="")
  myGeocode <- paste(myLat,myLon,myRadius,sep=",")
  tweets <- searchTwitter(myKeyword,n=tweetNr, geocode=myGeocode)
  return(tweets)
}
 
 
sentAnalysis <- function(tweets){
  # it returns a dataframe with tweets and relative sentiment and polarity,
  # see https://mkmanu.wordpress.com/2014/08/05/sentiment-analysis-on-twitter-data-text-analytics-tutorial/

  # Prepare text
  tweet_txt <- sapply(tweets, function(x) x$getText())
  tweet_txt = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", tweet_txt)
  tweet_txt = gsub("@\\w+", "", tweet_txt)
  tweet_txt = gsub("[[:punct:]]", " ", tweet_txt)
  tweet_txt = gsub("[[:digit:]]", "", tweet_txt)
  tweet_txt = gsub("http\\w+", "", tweet_txt)

  catch.error <- function(x)
    {
    y <- NA
    catch_error <- tryCatch(tolower(x), error=function(e) e)
    if (!inherits(catch_error, "error"))
    y <- tolower(x)
    return(y)
  }

  tweet_txt <- sapply(tweet_txt, catch.error)
  tweet_txt <- tweet_txt[!is.na(tweet_txt)]
  names(tweet_txt) <- NULL

  # classify emotions
  class_emo = classify_emotion(tweet_txt, algorithm="bayes", prior=1.0)
  emotion = class_emo[,7]
  emotion[is.na(emotion)] = "unknown"

  # classify polarity
  class_pol <- classify_polarity(tweet_txt, algorithm="bayes")
  polarity <- class_pol[,4]
  
  sentiment_df = data.frame(text=tweet_txt, 
                            emotion=emotion, 
                            polarity=polarity, 
                            stringsAsFactors=FALSE)
  
  return(sentiment_df)
}


getWordCloud <- function(tweet_text,city_name){ 
  # create a word cloud, see http://shiny.rstudio.com/gallery/word-cloud.html

  #create corpus
  myCorpus = Corpus(VectorSource(tweet_text))

  # remove stopwords
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("SMART"), "the", "and", "but"),mc.cores=1)

  myDTM = TermDocumentMatrix(myCorpus, control = list(minWordLength = 1))
  m = as.matrix(myDTM)
  m_sort<-sort(rowSums(m), decreasing = TRUE)
  
  wordcloud(names(m_sort), m_sort, 
            min.freq=1,max.words=10,
            colors=brewer.pal(8, "Dark2"),
            main="Title")
}
