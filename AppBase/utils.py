import base64
from io import BytesIO
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')


def get_graph():
    buffer = BytesIO()
    plt.savefig(buffer, format='png')
    buffer.seek(0)
    img_png = buffer.getvalue()
    graph = base64.b64encode(img_png)
    graph = graph.decode('utf-8')
    buffer.close()

    return graph


def get_barplot(x, y, title, xlabel, ylabel):
    plt.switch_backend('AGG')
    plt.figure(figsize=(20,10))
    plt.title(title, fontsize=30)
    plt.xlabel(xlabel, fontsize=20)
    plt.ylabel(ylabel, fontsize=20)
    plt.xticks(fontsize=20)
    plt.yticks(fontsize=20)
    plt.bar(x, y)
    plt.tight_layout()

    graph = get_graph()

    return graph


def get_pieplot(x, y, z,title, labelTitle1, labelTitle2, labelTitle3):
    clases = np.array([x, y, z])

    labels = [ str(round(x * 1.0 / clases.sum() * 100.0, 2)) + '%' for x in clases]
    labels[0] = labelTitle1 +'\n'+ labels[0]
    labels[1] = labelTitle2 +'\n'+ labels[1]
    labels[2] = labelTitle3 +'\n'+ labels[2] 

    parameters = {'axes.labelsize': 100, 'axes.titlesize': 35}
    plt.rcParams.update(parameters)

    plt.switch_backend('AGG')
    plt.figure(figsize=(20,10))
    plt.title(title, fontsize=30)
    plt.pie(clases, labels=labels)
    plt.axis("equal")
    plt.tight_layout()

    graph = get_graph()

    return graph
    
