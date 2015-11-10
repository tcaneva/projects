# Sentiment Map project

The aim of the project is to give a proof-of-principle demonstration that Twitter
can be mined according to geolocation and topic of interest to generate a
map of what feelings people have about a given subject. 

Concretely, the interactive map is produced according to the following steps.
Firstly, the user has to introduce a topic and a list of cities in which she/he desires
to conduct her/his analysis.
Then the program is automatically mining the "worldcitiespop.txt" database to extract
the geo-coordinates of the cities of interest. Geo-coordinates and topics can be used 
to interrogate Twitter APIs and extract a bunch of tweets from a radius of 50 miles
-the radius can be adjusted- around each city. Notice that Twitter
is setting a limit to the maximum number of tweets downloadable through its APIs, so 
the global number of required tweets has to be adjusted accordingly.
Afterwards, the ensemble of tweets corresponding to each city is analyzed with Natural 
Language Processing (NLP) techniques in order to assign a polarity (positive or negative)
and a sentiment to each tweet. The global polarity of the collection of tweets 
is determined by simple 
majority criterion and such a polarity is assigned to the corresponding city.
As further analysis tool, world-cloud maps of the most frequent words appearing in 
the corpus of the tweets of a given city can be produced.
Finally the polarity of the cities can be showed on top of a map in order 
to create an almost real time snapshot of what the people think about a given subject 
in different locations.
