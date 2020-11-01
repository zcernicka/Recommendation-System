import psycopg2
import pandas as pd

#load of sentiment from a pattern library to calculate sentiment of a summary field
from pattern.en import sentiment
import timeit

#timer implement to check how long it takes to run this analysis
start = timeit.default_timer()
#Load of a csv file with user reviews to the environment
data = pd.read_csv('Input/userReviews.csv',sep=';',quotechar='"')

#Array creation, where the sentiment calculation will be loaded
sentiments=[]

for summary in range(data.shape[0]):
    #Sentiment calculation based on a summary field. Sentiment function will output in 2 values - sentiment & objectivity. For the analysis purposes only sentiment is needed and thus [0]
    sentiments.append(sentiment(data.Summary.iloc[summary])[0])

#column Sentiment should include an array of sentiments
data['Sentiment']= sentiments
#Output data is then loaded to a csv file, with tabulator as a separator. Summary field sometimes include text with ';' inside and thus tabulator is used to refrain frm errors
data.to_csv('Input/userReviews_sentiment.csv',sep='\t', quotechar='"',index=False)

#Python connection creation to a postgres database to insert the table called 'final_test' into a database called 'test'
postgresConnection =psycopg2.connect("dbname=test user=pi password='raspberry'")
cursor =postgresConnection.cursor()
name_table= "final_test"
#Every column defined as text for now, because there are some missing values that can not be covered by any other variable type. In a real life, maybe would be better to drop such occurence.
#But as it is not sure what will be the further steps with the table, I kept it as a text. 
sqlCreateTable="create table "+name_table+" (MovieName text, Metascore_w text, Author text, AuthorHref text, Date text, Summary text, InteractionsYesCount text,"+\
"InteractionsTotalCount text, InteractionsThumbUp text, InteractionsThumbDown text, Sentiment text);"
cursor.execute(sqlCreateTable)

# reads the file, skips headers and copies the data into the table in a postgres
with open('Input/userReviews_sentiment.csv', 'r') as f:
    next(f)
    cursor.copy_from(f, name_table, sep='\t')
f.close()
#Changes execution in postgres
postgresConnection.commit()
#Connection closure
postgresConnection.close()