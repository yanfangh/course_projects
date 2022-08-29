# %%
import numpy as np
from utils import *
rfa_file="data/wiki-RfA.txt"

rfa={}
with open(rfa_file, 'r', encoding='latin-1') as f:
  for line in f:
    if line.startswith('SRC:'):
      source=line.strip()[4:]
    if line.startswith('TGT:'):
      target=line.strip()[4:]
    if line.startswith('VOT:'):
      sign=int(line.strip()[4:])
      if (source, target) not in rfa:
        rfa[(source, target)]=sign
      else:
        rfa[(source, target)]+=sign


rfa_data={'sources': [], 'targets': [], 'signs': []}
nodes=set()
for edge, sign in rfa.items():
  if sign!=0:
    rfa_data['sources'].append(edge[0])
    rfa_data['targets'].append(edge[1])
    if sign>0:
      rfa_data['signs'].append(1)
    else:
      rfa_data['signs'].append(-1)
    nodes.add(edge[0])
    nodes.add(edge[1])

str2num=dict((s, i) for i, s in enumerate(nodes))
rfa_data['sources']=list(map(lambda s: str2num[s], rfa_data['sources']))
rfa_data['targets']=list(map(lambda s: str2num[s], rfa_data['targets']))

# %%
## Create adjacency matrix
from scipy.sparse import csr_matrix
import numpy as np

ss, ts, signs=rfa_data['sources'], rfa_data['targets'], rfa_data['signs']
A=csr_matrix((signs, (ss, ts)), shape=(len(nodes), len(nodes)))
A_pos=A.maximum(0)
A_neg=-A.minimum(0)
nPos=sum(A_pos.data)
nNeg=sum(A_neg.data)
print('rfa dataset:')
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
nEdges={}   #record number of edges for different embededness levels
result={}

for cp in cycle_types:
  for ev in embed_levels:
    if cp=='triad':
      X, y=sample(features[:,:23], rfa_data['signs'], ev)
    else:
      X, y=sample(features, rfa_data['signs'], ev)
    if ev not in nEdges:
      nEdges[ev]=len(y)
    cv_results=evaluate(X, y)
    scores=[np.mean(cv_results[m]) for m in metrics]
    key=cp+'-'+str(ev)
    result[key]=scores
    print(key+' finished.')

print('rfa edge embeddedness:')
for k, v in nEdges.items():
  print('E=%d: %d edges' %(k, v))

print('rfa result:')
for k, v in result.items():
  print('%s: accuracy=%.3f, precision=%.3f, recall=%.3f, f1=%.3f, fpr=%.3f'
  %(k, v[0], v[1], v[2], v[3], v[4]))
        

