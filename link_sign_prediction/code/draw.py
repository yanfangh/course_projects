# %%
import pandas as pd

result=pd.read_csv('result.tsv', delimiter='\t')

# %%
import seaborn as sns
import matplotlib.pyplot as plt

plt.rcParams["axes.labelsize"] = 12
plt.rcParams['legend.fontsize']='large'

#Fraction of edges for different embeddedness levels among the five datasets
ek_frac=sns.lineplot(data=result[result['dataset']!='Wiki-Elec'], 
                    hue="dataset", x="Ek", y="fraction",marker='o')
ek_frac.set(xlabel="Minimum edge embeddedness", ylabel="Fraction of edges")
plt.legend(title=None)
plt.savefig('ek_frac.pdf')
plt.show()

# #Accuracy for k=3 and 4 under different embeddedness levels
datasets=list(pd.unique(result['dataset']))

accu_plots=[None]*len(datasets)
for i in range(len(datasets)):
  accu_plots[i]=sns.lineplot(data=result[result['dataset']==datasets[i]], 
  x="Ek", y="accuracy", hue="type", marker='o')
  accu_plots[i].set(xlabel="Minimum edge embeddedness", ylabel="Prediction accuracy")
  plt.legend(title=None, labels=['degree+triad', 'degree+triad+quad'])
  plt.savefig(datasets[i]+'_accu.pdf')
  plt.show()

#False positive rate for k=3 and 4 under different embeddedness levels
fpr_plots=[None]*len(datasets)
for i in range(len(datasets)):
  fpr_plots[i]=sns.lineplot(data=result[result['dataset']==datasets[i]], 
  x="Ek", y="fpr", hue="type", marker='o')
  fpr_plots[i].set(xlabel="Minimum edge embeddedness", ylabel="False positive rate")
  plt.legend(title=None, loc='best', labels=['degree+triad', 'degree+triad+quad'])
  plt.savefig(datasets[i]+'_fpr.pdf')
  plt.show()