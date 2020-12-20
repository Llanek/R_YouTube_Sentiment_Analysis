# Copy&Paste from https://www.rpubs.com/statscol/youtube_data_in_r

require(curl)
require(jsonlite)
library(kableExtra)
library(dplyr)
library(ggplot2)
library(plotly)
library(reshape2)

  # Get and Read Google Developer Key / YouTube V3 API Key and Authentification
  sAPIpath    <- "C:/Users/Yannic/OneDrive/Documents/11_Fortbildung/RBTV_YTComment_Analysis/API_KEY_YouTubeV3.txt"
  arrAPItable <- read.table(sAPIpath, header = FALSE)
  sAPIKey     <- arrAPItable[1,1]
  #print(APIkey)  # Debugging
  arrKey      <- Authenticate("youtube",sAPIkey)
  
  #IDs
  sVideoID     <- "3gJngOCyrZg" # Debugging
  sPlaylistID  <- "PLsD6gQXey8N1pHbp1MVTmnmCx5vConHKl" # Debugging
  sChannelID   <- "UCkfDws3roWo1GaA3pZUzfIQ" # Debugging RBTV LP&S
  
  
  # single video statistics/ information (total likes, comments, etc.)
  getstats_video<-function(video_id,API_key){
    
    url=paste0("https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=",video_id,"&key=",API_key)
    result <- fromJSON(txt=url)  
    salida=list()
    return(data.frame(name=result$items$snippet$channelTitle, result$items$statistics,title=result$items$snippet$title,date=result$items$snippet$publishedAt,descrip=result$items$snippet$description))
  }
  # Test
  stats_video = getstats_video(videoID, sAPIkey)

  
  # gets videoIDs out of a playlist and the video release dates. requires the playlistID!
  get_playlist_canal<-function(playlist_id,API_key,topn=15){
    
    url=paste0('https://www.googleapis.com/youtube/v3/playlistItems?part=contentDetails&playlistId=',playlist_id,'&key=',API_key,'&maxResults=',topn)
    
    result=fromJSON(txt=url)
    return(data.frame(result$items$contentDetails))
  }
  # Test
  test_playlist_channel <- get_playlist_canal(playlistID, sAPIkey)

  
  # gets a single row of basic channel information (name, views, subscriber, etc.)
  getstats_canal<-function(channel_id,API_key){
    
    url=paste0('https://www.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails%2Cstatistics&id=',channel_id,'&key=',API_key)
    
    result <- fromJSON(txt=url)   
    return(data.frame(name=result$items$snippet$title,result$items$statistics,pl_list_id=result$items$contentDetails$relatedPlaylists))
    
  }
  # Test
  test_stats_channel <- getstats_canal(channelID, sAPIkey)
  
  getsections_canal<-function(channel_id,API_key){
    
    url=paste0('https://youtube.googleapis.com/youtube/v3/channelSections?part=snippet%2CcontentDetails&channelId=',channel_id,'&key=',API_key)
    
    result <- fromJSON(txt=url)   
    return(data.frame(playlistIDs = result[["items"]][["contentDetails"]][["playlists"]][[2]])) #, data.frame(result$items$contentDetails$channels))) #data.frame(result$items$snippet),
  
  }
  # Test
  test_sections_channel <- getsections_canal(channelID, sAPIkey)
  
  
  
  # manually
  channelID <- "UCmY6t25uVbXIDTizjfLBI4Q" # Bigpuffer
  url <- paste0('https://youtube.googleapis.com/youtube/v3/channelSections?part=snippet%2CcontentDetails&channelId=',channelID,'&key=',sAPIkey)
  url <- paste0('https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=',channelID,'&key=',sAPIkey,'&maxResults=50')
  result <- fromJSON(txt=url)
  result2 <- data.frame(playlist_names = result[["items"]][["snippet"]][["title"]], playlist_IDs = result[["items"]][["id"]])
  #y https://youtube.googleapis.com/youtube/v3/channelSections?part=snippet%2CcontentDetails&channelId=UCkfDws3roWo1GaA3pZUzfIQ&key=XXXX
  #n https://www.googleapis.com/youtube/v3/channelSections?part=snippet%2CcontentDetails&channelid=UCkfDws3roWo1GaA3pZUzfIQ&key=XXXX
  
  # function to get the last 50 playlists and their names from a specific channel
  getChannelPlaylists <- function(arg_sChannelID, arg_sAPIKey){
    # create url to access YouTube V3 API to retrieve the information about the playlists
    # arg_sChannelID <- "UCmY6t25uVbXIDTizjfLBI4Q" # Debugging Bigpuffer
    # arg_sAPIKey <- sAPIkey # Debugging
    sURL <- paste0('https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=',channelID,'&key=',sAPIkey,'&maxResults=50')
    # access the JSON results which can be found opening the URL via JSONlite and temporarily save them in a list
    lResult <- fromJSON(sURL)
    return(data.frame(playlist_names = lResult[["items"]][["snippet"]][["title"]], playlist_IDs = lResult[["items"]][["id"]]))
  }
  # Test
  test_ChannelPlaylists <- getChannelPlaylists(sChannelID, sAPIKey)
  
  
  
  
  
  
  # unbekannt
  getall_channels<-function(ids,API_key,topn=5){
    
    videos=lapply(ids,FUN=get_playlist_canal,API_key=API_key,topn=topn) %>% bind_rows()
    
    stats=lapply(videos[,1],FUN=getstats_video,API_key=API_key)
    stats=bind_rows(stats)
    stats$vid_id=videos[,1]
    return(stats)
  }
  all_channel <- getall_channels(channelID, sAPIkey)
  