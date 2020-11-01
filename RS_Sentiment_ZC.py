import pandas as pd
import timeit

start = timeit.default_timer()
#Load of a csv file with sentiment calculation to the environment
data = pd.read_csv('Input/userReviews_sentiment.csv',sep='\t')
data.head()
#Decision not to put all columns into the analysis, since not needed for the final output (decreases the output calculation time)
data = data.drop(columns=['AuthorHref','Date','InteractionsYesCount','InteractionsTotalCount','InteractionsThumbUp','InteractionsThumbDown'])
#Dropped columns are not included. New columns Abs_Increase to prepare for the final output calculation
column_names = ['movieName', 'Metascore_w','Author','Summary','Sentiment','Abs_Increase']
#Creation of a smaller dataset that entails all information about the lion king reviews ("small filter")
subset = data[data['movieName']=='the-lion-king']
        
result= pd.DataFrame(columns = column_names)
#for each author in sequence, execute following expression 
for author in range(subset.shape[0]):
    #search of row indexes where author equals author from a subset AND sentiment of author from a subset is less then the sentiment of the author from the whole dataset
    indexes =data[data['Author']==subset.Author.iloc[author]]
    indexes =indexes[indexes['Sentiment']>subset.Sentiment.iloc[author]].index.values
    for movie in indexes:
        #every found index and its row values shall be added to "row"
        row=data[movie:movie+1]
        #data about absolute review sentiment increase shall be added within a columns called Abs_increase      
        row.insert(5,'Abs_Increase', data.Sentiment.iloc[movie] - subset.Sentiment.iloc[author])
        #Rows defined shall be added to the result dataset
        result=result.append(row)       
#Absolute Increases shall be sorted in a descending order
result.sort_values(['Abs_Increase'], ascending=False)
#Movie names duplicates shall be dropped from a dataset, leaving only the ones with the highest review sentiment increase
result.drop_duplicates(subset = 'movieName', keep = 'first', inplace=True)
#Final output shall be loaded to a csv file called "recommendations", without assigned indexes
result.to_csv("Output/RS_Sentiment_ZC.csv", sep=";", index=False)

print(timeit.default_timer() - start)
        

