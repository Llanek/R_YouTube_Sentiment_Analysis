# Filename: RBTV_YTComment_Analysis
# Author: YBU
# Date: 17.12.2020
# Runtime: --
  
  # Call the needed libraries
  library(vosonSML)   #necessary to get the Authenticate, Collect, ... functions
  #library(magrittr)   

  
  # Get and Read Google Developer Key / YouTube V3 API Key and Authentification
  sAPIpath    <- "C:/Users/Yannic/OneDrive/Documents/11_Fortbildung/RBTV_YTComment_Analysis/RBTV_YTComment_Analysis/API_KEY_YouTubeV3.txt"
  arrAPItable <- read.table(sAPIpath, header = FALSE)
  sAPIkey     <- arrAPItable[1,1]
  #print(APIkey)  # Debugging
  arrKey      <- Authenticate("youtube",sAPIkey)
  #testetstest
  
  #Collect Data using YouTube videos
  ytVideos <- c()
  ytVideoIds <- GetYoutubeVideoIDs(ytVideos)
  ytData <- Collect(
              keyvideoIDs = ytVideoIds
              ,maxComments = 100
              ,verbose = FALSE
            )
  
  # Save the comment data as csv
  filenamecsv <- "snippet2"
  pathcsv <- paste("C:/Users/Yannic/Desktop/", filenamecsv, ".csv")
  delimitercsv <- ";"
  write.csv2(
    ytData 
    , file = pathcsv
    , append = FALSE
    , sep = delimitercsv
    , row.names = FALSE
  )
  
  # Read the comment data
  data <- read.csv(
            pathcsv
            , sep = delimitercsv
            , header = TRUE
          )
  str(data)
  
  # Get channel ID
  channelID <- "UCkfDws3roWo1GaA3pZUzfIQ" #RBTV LP&Streams
  channelData <- youtube.channels.list(channelID, part=contentDetails)
  