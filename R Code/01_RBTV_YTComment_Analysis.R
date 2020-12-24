# Filename: RBTV_YTComment_Analysis
# Author: YBU
# Date: 23.12.2020
# Runtime: --
  
  # Call the needed libraries
  require(vosonSML)   # necessary to get the Authenticate, Collect, ... functions
  require(jsonlite)   # necessary to get the fromJSON function
  require(config)     # necessary to read out the config .yml-file
  require(data.table) # better than just data.frame
  #library(magrittr)  
  #require(curl)

  
  # Get and Read Google Developer Key / YouTube V3 API Key and Authentification
  sAPIKey     <- config::get("API_Key")
  #print(APIkey)  # Debugging
  arrKey      <- Authenticate("youtube",sAPIKey)
  
  
  
  # #Collect Data using YouTube videos
  # ytVideos <- c()
  # ytVideoIds <- GetYoutubeVideoIDs(ytVideos)
  # ytData <- Collect(
  #             keyvideoIDs = ytVideoIds
  #             ,maxComments = 100
  #             ,verbose = FALSE
  #           )
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
  
  
  # function to get up to the last 50 playlists (default 15) and their names from a specific channel. requires the channelID!
    get_ChannelPlaylists <- function(arg_sChannelID, arg_sAPIKey, iMaxResults = 15){
      
      # create url to access YouTube V3 API to retrieve the information about the playlists from the channel
      sURL <- paste0('https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=',arg_sChannelID,'&key=',arg_sAPIKey,'&maxResults=',iMaxResults)
      # access the JSON results which can be found opening the URL via JSONlite and temporarily save them in a list
      lResult <- fromJSON(sURL)
      # return a data.frame with last n playlist names and corresponding playlist IDs
      return(
        data.table(
          playlist_names = lResult[["items"]][["snippet"]][["title"]]
          , playlist_IDs = lResult[["items"]][["id"]]
        )
      )
      
    }
  # Test
    # test_ChannelPlaylists <- get_ChannelPlaylists(sChannelID, sAPIKey)
  
  # function to get up to the last 50 videoIDs (default 15) out of a playlist and the video release dates. requires the playlistID!
    get_PlaylistVideos <- function(arg_sPlaylistID, arg_sAPIKey, iMaxResults = 15){
      
      # create url to access YouTube V3 API to retrieve the information about the videos in the playlist
      sURL <- paste0('https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=',arg_sPlaylistID,'&key=',arg_sAPIKey,'&maxResults=',iMaxResults)
      # access the JSON results which can be found opening the URL via JSONlite and temporarily save them in a list
      lResult <- fromJSON(sURL)
      #return(lResult)
      # return a data.frame with last n video names and corresponding video IDs as well as publish dates
      return(
        data.table(
          name = lResult$items$snippet$title
          , videoID = lResult$items$snippet$resourceId$videoId
          , published = lResult$items$snippet$publishedAt
        )
      )
      
    }
  # Test
    # test_PlaylistVideos <- get_PlaylistVideos(bug_PlaylistID, sAPIKey)
    
  # function to retrieve the information about a video and its basic statistics. requires the videoID!
    get_VideoStats <- function(arg_sVideoID, arg_sAPIKey){
      
      # create url to access YouTube V3 API to retrieve the information about the video
      sURL <- paste0("https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=",arg_sVideoID,"&key=",arg_sAPIKey)
      # access the JSON results which can be found opening the URL via JSONlite and temporarily save them in a list
      lResult <- fromJSON(sURL)
      # return(lResult)
      # return a data.table with information about the video and simple statistics
      return(
        data.table(
          videoID = arg_sVideoID
          , tags = list(lResult[["items"]][["snippet"]][["tags"]][[1]])
          , viewCount = lResult$items$statistics$viewCount
          , likeCount = lResult$items$statistics$likeCount
          , dislikeCount = lResult$items$statistics$dislikeCount
          , favoriteCount = lResult$items$statistics$favoriteCount
          , commentCount = lResult$items$statistics$commentCount
        )
      )
      
    }
  # Test
    # test_VideoStats <- get_VideoStats(bug_VideoID, sAPIKey)
    
  # function to join the results from get_PlaylistVideos and get_VideoStats
    join_PlaylistVideosInformation <- function(arg_dt_resultPlaylist, arg_sAPIKey){
      
      # set a key for the playlist data.table videoID to later specify the exact row
      setkey(arg_dt_resultPlaylist, videoID)
      # generate an empty data.table with the corresponding column(headers) to later be the result data.table
      dtResult <- data.table(
        name = character()
        , videoID = character()
        , published = character()
        , tags = character()
        , viewCount = character()
        , likeCount = character()
        , dislikeCount = character()
        , favoriteCount = character()
        , commentCount = character()
        )
      # loop through the videoIDs from the playlist data.table
      for (tmp_videoID in arg_dt_resultPlaylist$videoID){
        
        # call the VideoStats-function to get the information for the current videoID iteration
        tmp_dt_vidInfo <- get_VideoStats(tmp_videoID, arg_sAPIKey)
        # also set a key for the videoID to specify the exact row
        setkey(tmp_dt_vidInfo, videoID)
        # use the more efficient rbindlist to add rows to the result data.table joining the video information onto the playlist videos
        dtResult <- rbindlist(list(dtResult, cbind(arg_dt_resultPlaylist[.(tmp_videoID)], tmp_dt_vidInfo[.(tmp_videoID),c(2:7)]))) 
        
      }
      # return a data.table with information about all the videos and their simple statistics which are present in the given playlist
      return(dtResult)
    }
  # Test
    # test_Join <- join_PlaylistVideosInformation(test_PlaylistVideos, sAPIKey)
  