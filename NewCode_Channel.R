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
  sVideoID     <- "E7sP6t1QyrI" # Debugging
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
  
  
  
  library(httr)
  
  base_url <- "https://www.googleapis.com/youtube/v3/commentThreads/"
  api_opts <- list(
    part = "snippet",
    maxResults = 100, 
    textFormat = "plainText",
    videoId = sVideoID,  
    key = sAPIKey,
    fields = "items,nextPageToken", #nextPageToken only comes into play if one doesn't use the maximum of maxResults 
    orderBy = "published")
  
  init_results <- httr::content(httr::GET(base_url, query = api_opts))
  ##
  names(init_results)
  #[1] "nextPageToken" "items"
  init_results$nextPageToken
  #[1] "Cg0Q-YjT3bmSxQIgACgBEhQIABDI3ZWQkbzEAhjVneqH75u4AhgCIGQ="       
  class(init_results)
  #[1] "list"
  
  
  api_opts$pageToken <- gsub("\\=","",init_results$nextPageToken)
  next_results <- httr::content(
    httr::GET(base_url, query = api_opts))
  ##
  R> next_results$nextPageToken
  #[1] "ChYQ-YjT3bmSxQIYyN2VkJG8xAIgACgCEhQIABDI3ZWQkbzEAhiSsMv-ivu0AhgCIMgB"
  
  # unbekannt
  yt_scraper <- setRefClass(
    "yt_scraper",
    fields = list(
      base_url = "character",
      api_opts = "list",
      nextPageToken = "character",
      data = "list",
      unique_count = "numeric",
      done = "logical",
      core_df = "data.frame"),
    
    methods = list(
      scrape = function() {
        opts <- api_opts
        if (nextPageToken != "") {
          opts$pageToken <- nextPageToken
        }
        
        res <- httr::content(
          httr::GET(base_url, query = opts))
        
        nextPageToken <<- gsub("\\=","",res$nextPageToken)
        data <<- c(data, res$items)
        unique_count <<- length(unique(data))
      },
      
      scrape_all = function() {
        while (TRUE) {
          old_count <- unique_count
          scrape()
          if (unique_count == old_count) {
            done <<- TRUE
            nextPageToken <<- ""
            data <<- unique(data)
            break
          }
        }
      },
      
      initialize = function() {
        base_url <<- "https://www.googleapis.com/youtube/v3/commentThreads/"
        api_opts <<- list(
          part = "snippet",
          maxResults = 100,
          textFormat = "plainText",
          videoId = sVideoID,  
          key = "my_google_developer_api_key",
          fields = "items,nextPageToken",
          orderBy = "published")
        nextPageToken <<- ""
        data <<- list()
        unique_count <<- 0
        done <<- FALSE
        core_df <<- data.frame()
      },
      
      reset = function() {
        data <<- list()
        nextPageToken <<- ""
        unique_count <<- 0
        done <<- FALSE
        core_df <<- data.frame()
      },
      
      cache_core_data = function() {
        if (nrow(core_df) < unique_count) {
          sub_data <- lapply(data, function(x) {
            data.frame(
              Comment = x$snippet$topLevelComment$snippet$textDisplay,
              User = x$snippet$topLevelComment$snippet$authorDisplayName,
              ReplyCount = x$snippet$totalReplyCount,
              LikeCount = x$snippet$topLevelComment$snippet$likeCount,
              PublishTime = x$snippet$topLevelComment$snippet$publishedAt,
              CommentId = x$snippet$topLevelComment$id,
              stringsAsFactors=FALSE)
          })
          core_df <<- do.call("rbind", sub_data)
        } else {
          message("\n`core_df` is already up to date.\n")
        } 
      }
    )
  )
  