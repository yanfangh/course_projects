

Code and report for my class projects during my graduate studies. Includes some unsuccessfull attempts at challenges. Below is a brief description for each project.

#### Link sign prediction

The task is to predict whether the link between two nodes is positive or negative in online social networks. We reproduced the experiments from [1] [2], which built a logestic classifier with degree and k-cycle based features. In addition, we applied the methods to two new datasets, compared the performance of the models with different feature combinations, and measured the model performance on edges of different levels of minimum embeddedness (common neighbors).

#### Answer selection

The task is to select the best answer from a set of candidate answers for the given question. We used different neural networks, including CNN, simple RNN, LSTM and GRU, to generate vector representation for each question or answer. Our selection criteria are based on semantic textual similarity between question and candidate answers. Our optimization objective is to shorten the distance between question and positive answer and increase the distance between question and negative answers.

#### Crime graph

The experimental data is a collection of criminal records (publicly available). Each record consists of three units: time, region, and crime types. The task is to predict each unit under the condition that the other two units are known. We built a hetergeneous graph that encodes the co-occurrence and spatiotemporal neighborhood relationships among units, and learns node embeddings that can preserve the graph structure. This task was challenging and training such a complicated graph was difficult. The model perfroms not well but it was an interesting attempt.

#### COVID QA

This is from a Kaggle challenge called COVID-19 Open Research Dataset Challenge [4], which provides a large amount of scholarly articles related to coronavirus and also a list of questions that the public concerns. Our task is to return a list of articles relevant to the given questions. This project was conducted in the *Seminar distibuted data mining* class, so we focused on how to use Spark to process big data in a distrbuted way. We did an exploratoty data analysis, used keywords and tf-idf for document retrieval, and trained a word2vec model on the whole corpus, and utilized text similarity to get articles that contains the relevant sentences. All of these were performed in multiple worker nodes for parallel processing. Due to lack of labels, we were not able to evaluate model performance. 

#### Sentiment analysis

This is a simple sentiment classification task on tweets. Each tweet is classified into three categories: positive, negative and neural. We did a comparison analysis among four methods.  Two baseline methods are Naive Bayes and Logistic classification. Two deep learning methods are BERT sequence classifier and a deep LSTM network with attention called DataStories [3]. 

#### HR case

This a case study on a human resource dataset to investigate two question: 1. what factors are associated with salary of employees? 2. what factors can affect whether the employees have been terminated?  This study was conducted in the *Linear & generalized linear models* class. We formulated multple linear models with different predictors for statistical analysis.



#### References

[1] Leskovec, Jure, Daniel Huttenlocher, and Jon Kleinberg. "Predicting positive and negative links in online social networks." *Proceedings of the 19th international conference on World wide web*. 2010.

[2] Chiang, Kai-Yang, et al. "Exploiting longer cycles for link prediction in signed networks." *Proceedings of the 20th ACM international conference on Information and knowledge management*. 2011.

[3] Baziotis, Christos, Nikos Pelekis, and Christos Doulkeridis. "Datastories at semeval-2017 task 4: Deep lstm with attention for message-level and topic-based sentiment analysis." *Proceedings of the 11th international workshop on semantic evaluation (SemEval-2017)*. 2017.

[4] [Kaggle, COVID-19 Open Research Dataset Challenge (CORD-19)](https://www.kaggle.com/datasets/allen-institute-for-ai/CORD-19-research-challenge)



