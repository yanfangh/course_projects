# %%
import numpy as np
from utils import *

#### SlashDot dataset Preprocessing
slashdot_data={'sources':[], 'targets': [], 'signs': []}
slashdot_file='data/soc-sign-Slashdot090221.txt'
nodes=set()
with open(slashdot_file, 'r', encoding='utf-8') as f:
  for i in range(4):
    next(f)
  for line in f:
    source, target, sign=line.strip('\n').split('\t')
    slashdot_data['sources'].append(source)
    slashdot_data['targets'].append(target)
    slashdot_data['signs'].append(int(sign))
    nodes.add(source)
    nodes.add(target)

str2num=dict((s, i) for i, s in enumerate(nodes))
slashdot_data['sources']=list(map(lambda s: str2num[s], slashdot_data['sources']))
slashdot_data['targets']=list(map(lambda s: str2num[s], slashdot_data['targets']))

# %%
## Create adjacency matrix
from scipy.sparse import csr_matrix
import numpy as np

ss, ts, signs=slashdot_data['sources'], slashdot_data['targets'], slashdot_data['signs']
A=csr_matrix((signs, (ss, ts)), shape=(len(nodes), len(nodes)))
A_pos=A.maximum(0)
A_neg=-A.minimum(0)
nPos=sum(A_pos.data)
nNeg=sum(A_neg.data)
print('slashdot dataset:')
print('Number of nodes: %d' %(A.shape[0]))
print('Number of positive edges: %d, ratio: %.3f' %(nPos, nPos/(nPos+nNeg)))
print('Number of negative edges: %d, ratio: %.3f' %(nNeg, nNeg/(nPos+nNeg)))

# %%
## extract degree features
features=extract_deg_features(A_pos, A_neg, ss, ts)
print("Extracting degree-features finished.")

## extract cycle features
from itertools import product
from multiprocessing import Pool

def matrix_dot(p):
  a=basics[p[0]]
  b=basics[p[1]]
  return a.dot(b)

def get_triad_feature(M):
  return np.array(M[ss, ts]).reshape(-1)

def get_quad_feature(p):
  a=triad_matrice[p[0]]
  b=basics[p[1]]
  return np.array(a.dot(b)[ss, ts]).reshape(-1)

basics=[A_pos, A_neg, A_pos.T, A_neg.T]
prods=list(product(range(len(basics)), range(len(basics))))

p=Pool(processes=16)
triad_matrice=list(p.map(matrix_dot, prods))
features+=list(p.map(get_triad_feature, triad_matrice))
p.close()
p.join()
  
prods=list(product(range(len(triad_matrice)), range(len(basics))))
p=Pool(processes=30)
features+=list(p.map(get_quad_feature, prods))
p.close()
p.join()
features=np.array(features).T
print('Extracting cycle-features finished')


## utilize cross-validation to evaluate the performance
nEdges={}
result={}
for cp in cycle_types:
  for ev in embed_levels:
    if cp=='triad':
      X, y=sample(features[:,:23], slashdot_data['signs'], ev)
    else:
      X, y=sample(features, slashdot_data['signs'], ev)
    if ev not in nEdges:
      nEdges[ev]=len(y)
    cv_results=evaluate(X, y)
    scores=[np.mean(cv_results[m]) for m in metrics]
    key=cp+'-'+str(ev)
    result[key]=scores
    print(key+' finished.')

print('slashdot edge embeddedness:')
for k, v in nEdges.items():
  print('E=%d: %d edges' %(k, v))

print('slashdot result:')
for k, v in result.items():
  print('%s: accuracy=%.3f, precision=%.3f, recall=%.3f, f1=%.3f, fpr=%.3f'
  %(k, v[0], v[1], v[2], v[3], v[4]))