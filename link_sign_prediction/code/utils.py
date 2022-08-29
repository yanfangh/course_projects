import numpy as np
def extract_deg_features(A_pos, A_neg, sources, targets):
  '''
  Extract degree-based features for all edges from the matrice A, A_pos and A_neg.
  For example, given an edge (u, v)the features include:
  - din_pos, din_neg: the number of incoming positive and negative edges to v
  - dout_pos, dout_neg: the number of outgoing positive and negative edges from u
  - din, dout: the total indegree of v and the total outdegree of u
  - c: the number of common neighbors of u and v in an undirected sense
  '''
  # obtain the list consisting of the degree-based features for each node
  din_pos_lst=np.ravel(A_pos.sum(axis=0))
  din_neg_lst=np.ravel(A_neg.sum(axis=0))
  dout_pos_lst=np.ravel(A_pos.sum(axis=1))
  dout_neg_lst=np.ravel(A_neg.sum(axis=1))
  din_lst=din_pos_lst+din_neg_lst
  dout_lst=dout_pos_lst+dout_neg_lst
  unsignedA=A_pos+A_neg
  Au=unsignedA+unsignedA.T   #get the adjacency matrix when ignoring the direction 
  cs=Au.dot(Au)

  #extract the degree-based features for all edges
  din_pos=din_pos_lst[targets]
  din_neg=din_neg_lst[targets]
  dout_pos=dout_pos_lst[sources]
  dout_neg=dout_neg_lst[sources]
  din=din_pos+din_neg
  dout=dout_pos+dout_neg
  c=np.array(cs[sources, targets]).reshape(-1)
  deg_features=[din_pos, din_neg, dout_pos, dout_neg, din, dout, c]
  return deg_features

def sample(features,signs, embed_level):
  features=np.array(features)
  signs=np.array(signs)
  mask=(features[:, 6]>=embed_level)
  X=features[mask]
  y=signs[mask]
  return X, y

from sklearn.metrics import make_scorer
def false_positive_rate(y_true, y_pred):

  y_true=np.array(y_true)
  y_pred=np.array(y_pred)
  fp=sum((y_pred==1) & (y_true==-1))
  fpr=fp/sum(y_true==-1)
  return fpr

scoring={'accuracy': 'accuracy', 'precision': 'precision', 
        'recall': 'recall','f1':'f1', 
        'fpr': make_scorer(false_positive_rate)}

from sklearn.linear_model import LogisticRegression 
from sklearn.model_selection import cross_validate
def evaluate(X, y, nIter=200):
  '''
  build logistic regression model and use cross-validation to evaluate the performance
  '''
  # scores=cross_validate(clf, X, y, cv=10, scoring=scoring, n_jobs=-1)
  nTranin=int(len(y)*0.8)
  mask=[1]*nTrain+[0]*(len(y)-nTrain)
  mask=np.random.shuffle(mask)
  clf=LogisticRegression(random_state=0, max_iter=nIter).fit(X[mask==1], y[mask==1])
  pred=clf.predict(X[mask==0])
  pred[pred>0]=1
  pred[pred<=0]=-1
  scores=sum(y==pred)/len(y)
  
  return scores

embed_levels=list(range(0, 30, 5))
cycle_types=['triad', 'quad']
metrics=['test_'+k for k in scoring.keys()]
