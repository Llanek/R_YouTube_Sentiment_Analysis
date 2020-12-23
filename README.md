# Youtube Comment Analysis
```R
> print("Hello, stranger!")
[1] "Hello, stranger!"
```
  And welcome to my first github repository! In this little readme I want to explain the idea, the aim(s) and maybe one day the results behind all the code you'll stumble across here. As a little disclaimer this project is only supervised and work on by myself and so far not peer reviewed in any kind as well as served as a prototype to get to know github. Therefore excuse all major and minor faux pas in the git/coding etiquette.


## The origin
  As mentioned above this all started with the idea to maybe support a [german YouTube channel](https://www.youtube.com/channel/UCQvTDmHza8erxZqDkjQ4bQQ) with their video and especially their comment analysis. Due to my work as a data analyst with some data science influence I've gotten to know [KNIME](https://www.knime.com/) and seen some sentiment analysis workflows created with it. But since my day-to-day worktasks focus more on numbers rather than strings and texts, the idea came up to put some sentiment analysis methods to use analysing YouTube comments.
  
### Choice of programming language
  As you've might noticed by now - through all the files linked above or the highlighting of the little `Hello, stranger!` - this code is written in R. "Why?", you might ask. Well because, as mentioned earlier, I'm working with KNIME and I've got example workflows regarding the sentiment analysis, so it seemed obvious. But since KNIME (by now) doesn't include a YouTube API node, a stackoverflow post with the same problem hinted on using an R snippet node and put all the API code there. Having used R back at university and not wanting to mix up tools, I then switched to R knowing it probably will even fit better for statistical analysis later on. 
  The idea to maybe repeat all that in Python too is also resting at the back of my head. Not only refreshing my knowledge with R but then likewise with Python. But one step at a time!
  
### Possible questions
- Which information is provided by a sentiment analysis for one video?
- How may the sentiment change for videos within a playlist?
- Comment section sentiment vs. video likes - do they match up?
- Regarding playlists - are there "super commenters"? And if so ... 
  - How often do they comment the videos in the playlist? 
  - How early do they comment on videos releasing in this playlist?
  - Does their sentiment fit the overall comment section sentiment?
  - How many likes do their comments receive?
  
to be continued...

[comment]: <> (## Status quo)
