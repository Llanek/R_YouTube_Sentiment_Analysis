# Filename: RBTV_YTComment_Analysis
# Author: YBU
# Date: 19.12.2020
# Runtime: --
  
  # Call the needed libraries
  require(vosonSML)   # necessary to get the Authenticate, Collect, ... functions
  require(jsonlite)   # necessary to get the fromJSON function
  require(config)     # necessary to read out the config .yml-file
  #library(magrittr)  
  #require(curl)

  
  # Get and Read Google Developer Key / YouTube V3 API Key and Authentification
  sAPIKey     <- config::get("API_Key")
  #print(APIkey)  # Debugging
  arrKey      <- Authenticate("youtube",sAPIKey)
  
  
  
  # #Collect Data using YouTube videos
  ytVideos <- c()
  ytVideoIds <- GetYoutubeVideoIDs(ytVideos)
  ytData <- Collect(
              keyvideoIDs = bug_VideoID
              ,maxComments = 100
              ,verbose = FALSE
            )
  # 
  # # Save the comment data as csv
  # filenamecsv <- "snippet2"
  # pathcsv <- paste("C:/Users/Yannic/Desktop/", filenamecsv, ".csv")
  # delimitercsv <- ";"
  # write.csv2(
  #   ytData 
  #   , file = pathcsv
  #   , append = FALSE
  #   , sep = delimitercsv
  #   , row.names = FALSE
  # )
  # 
  # # Read the comment data
  # data <- read.csv(
  #           pathcsv
  #           , sep = delimitercsv
  #           , header = TRUE
  #         )
  # str(data)
  # 
  # # Get channel ID
  # channelID <- "UCkfDws3roWo1GaA3pZUzfIQ" #RBTV LP&Streams
  # channelData <- youtube.channels.list(channelID, part=contentDetails)
  
  # Set debugging variables
  bug_VideoID <- "3gJngOCyrZg"
  bug_ChannelID <- "UCkfDws3roWo1GaA3pZUzfIQ"
  bug_PlaylistID <- "PLsD6gQXey8N1pHbp1MVTmnmCx5vConHKl"
  
  
  # function to get up to the last 50 playlists (default 15) and their names from a specific channel
    get_ChannelPlaylists <- function(arg_sChannelID, arg_sAPIKey, iMaxResults = 15){
      
      # create url to access YouTube V3 API to retrieve the information about the playlists from the channel
      sURL <- paste0('https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=',arg_sChannelID,'&key=',arg_sAPIKey,'&maxResults=',iMaxResults)
      # access the JSON results which can be found opening the URL via JSONlite and temporarily save them in a list
      lResult <- fromJSON(sURL)
      # return a data.frame with last n playlist names and corresponding playlist IDs
      return(data.frame(playlist_names = lResult[["items"]][["snippet"]][["title"]], playlist_IDs = lResult[["items"]][["id"]]))
      
    }
  # Test
    # test_ChannelPlaylists <- get_ChannelPlaylists(sChannelID, sAPIKey)
  
  # function to get up to the last 50 videoIDs (default 15) out of a playlist and the video release dates. requires the playlistID!
    get_PlaylistVideos <- function(arg_sPlaylistID, arg_sAPIKey, iMaxResults = 15){
      
      # create url to access YouTube V3 API to retrieve the information about the videos in the playlist
      sURL <- paste0('https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails&playlistId=',arg_sPlaylistID,'&key=',arg_sAPIKey,'&maxResults=',iMaxResults)
      # access the JSON results which can be found opening the URL via JSONlite and temporarily save them in a list
      lResult <- fromJSON(sURL)
      return(lResult)
      # return a data.frame with last n video names and corresponding video IDs
      return(data.frame(lResult$items$contentDetails))
      
    }
  # Test
  test_PlaylistVideos <- get_PlaylistVideos(bug_PlaylistID, sAPIKey)
  