# %%
import numpy as np

def create_alias_table(probs):
  '''
  probs: probability distribution
  '''
  K=len(probs)
  accept=np.copy(probs)*K
  alias=np.zeros(K, dtype=np.int)

  # store the events less than 1/K
  small=[]
  # store the events greater than 1/K
  large=[]

  for i, p in enumerate(probs):
    if accept[i]<1.0:
      small.append(i)
    if accept[i]>1.0:
      large.append(i)

  while(small and large):
    s=small.pop()
    l=large.pop()

    # fill alias array
    alias[s]=l
    accept[l]=accept[l]-(1-accept[s])

    if accept[l]<1.0:
      small.append(l)
    if accept[l]>1.0:
      large.append(l)

#   print("accpet: ", accept)
#   print("alias: ", alias)
  return accept, alias
    
  

def alias_sample(accept, alias):
  '''
  return: sample index
  '''
  i=np.random.choice(len(accept))
  r=np.random.random()

  if r<accept[i]:
    return i
  else:
    return alias[i]


# probs =[0.1,0.25,0.15,0.3,0.2]
# accept, alias=create_alias_table(probs)

# x=np.zeros(1000, dtype=int)
# for i in range(1000):
#   x[i]=alias_sample(accept, alias)


# %%
