require(curl)
require(jsonlite)
library(kableExtra)
library(dplyr)
library(ggplot2)
library(plotly)
library(reshape2)

API_key= "AIzaSyB6CH658uQulai9xvTNu5sf7hsQwlecO2s"
videoID= "3gJngOCyrZg"
getstats_video<-function(video_id,API_key){
  
  url=paste0("https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=",video_id,"&key=",API_key)
  result <- fromJSON(txt=url)  
  salida=list()
  return(data.frame(name=result$items$snippet$channelTitle, result$items$statistics,title=result$items$snippet$title,date=result$items$snippet$publishedAt,descrip=result$items$snippet$description))
}
data2 = getstats_video(videoID, API_key)

get_playlist_canal<-function(id,API_key,topn=15){
  
  url=paste0('https://www.googleapis.com/youtube/v3/playlistItems?part=contentDetails&playlistId=',id,'&key=',API_key,'&maxResults=',topn)
  
  result=fromJSON(txt=url)
  return(data.frame(result$items$contentDetails))
}

getstats_canal<-function(id,API_key){
  
  url=paste0('https://www.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails%2Cstatistics&id=',id,'&key=',API_key)
  
  result <- fromJSON(txt=url)   
  return(data.frame(name=result$items$snippet$title,result$items$statistics,pl_list_id=result$items$contentDetails$relatedPlaylists))
  
}

getall_channels<-function(ids,API_key,topn=5){
  
  videos=lapply(ids,FUN=get_playlist_canal,API_key=API_key,topn=topn) %>% bind_rows()
  
  stats=lapply(videos[,1],FUN=getstats_video,API_key=API_key)
  stats=bind_rows(stats)
  stats$vid_id=videos[,1]
  return(stats)
}