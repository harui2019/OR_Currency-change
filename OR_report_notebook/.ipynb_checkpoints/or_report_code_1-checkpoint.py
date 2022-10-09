import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

path_s = dict()
path_s['main'] = 'D:\\Desktop\\1082_OR_report_summary'
path_s['1.5a'] = '\\or_report_1.5_model_A_multinode_trivial'
path_s['1.5b'] = '\\or_report_1.5_model_B_multinode_trivial'
path_s['1.6a'] = '\\or_report_1.6_model_A_multinode'
path_s['1.6b'] = '\\or_report_1.6_model_B_multinode'
path_s['5e'] = '\\5nodes'
path_s['6f'] = '\\6nodes'
path_s['7g'] = '\\7nodes'
path_s['8h'] = '\\8nodes'
path_s['9i'] = '\\9nodes'

path_s2 = dict()
path_s2['1.5a'] = '\\or_report.1.5_mA_'
path_s2['1.5b'] = '\\or_report.1.5_mB_'
path_s2['1.6a'] = '\\or_report.1.6_mA_'
path_s2['1.6b'] = '\\or_report.1.6_mB_'

#生成檔案位置以載入
def makingpath(folder = None, nodes = None):
    if folder == None or nodes == None:
        raise ValueError(
            "the 'folder' or 'nodes' is not given," + 
            " 'path_s' has what you should entry", path_s)
    path_0 = (
        path_s['main'] + path_s[folder] + path_s[nodes] +
        path_s2[folder] + nodes + '_out_')
    path_cost = path_0 + 'cost.csv'
    path_remain = path_0 + 'remain.csv'
    path_remainrate = path_0 + 'remainrate.csv'
    path_isfeasible = path_0 + 'isfeasible.csv'
    return path_cost, path_remain, path_remainrate, path_isfeasible

#將檔案載入後，他們是個別的DataFrame
def dataload(folder = None, nodes = None):
    if folder == None or nodes == None:
        raise ValueError(
            "the 'folder' or 'nodes' is not given," + 
            " 'path_s' has what you should entry", path_s)
    data_path = makingpath(folder, nodes)
    data_cost = pd.read_csv(data_path[0])
    data_remain = pd.read_csv(data_path[1])
    data_remainrate = pd.read_csv(data_path[2])
    data_isfeasible = pd.read_csv(data_path[3])
    return data_cost, data_remain, data_remainrate, data_isfeasible

#將資料整合在同一個表格
def framegenerate(folder = None, nodes = None):
    if folder == None or nodes == None:
        raise ValueError(
            "the 'folder' or 'nodes' is not given," + 
            " 'path_s' has what you should entry", path_s)
    frame_set = dataload(folder, nodes)
    frame_target = pd.DataFrame()
    frame_target['cost'] = frame_set[0]['cost(iter)']
    frame_target['remain'] = frame_set[1]['remain(iter)']
    frame_target['remainrate'] = frame_set[2]['remainrate(iter)']
    frame_target['isfeasible'] = frame_set[3]['isfeasible(iter)']
    return frame_target

#將不可行解，獨立成表格中另外幾行；給出最後一個(即最大)可行解所在的輸入金額
def fail_seperate(frame = None):
    if type(frame) != type(pd.DataFrame()):
        raise TypeError("this is only for dataframe of or_report")
    endpoint = 0
    for i in list(frame.index):
        isfeasible = frame.loc[i, ('isfeasible')]
        if frame.loc[i, ('isfeasible')] == 1:
            frame.loc[i, ('cost_fail')] = None
            frame.loc[i, ('remain_fail')] = None 
            frame.loc[i, ('remainrate_fail')] = None
        else :
            frame.loc[i, ('cost_fail')] = frame.loc[i, ('cost')]
            frame.loc[i, ('remain_fail')] = frame.loc[i, ('remain')]
            frame.loc[i, ('remainrate_fail')] = frame.loc[i, ('remainrate')]
            
            frame.loc[i, ('cost')] = None
            frame.loc[i, ('remain')] = None 
            frame.loc[i, ('remainrate')] = None
    
    for i in list(frame.index):
        if frame.loc[i, ('isfeasible')] == 4:
            endpoint = i - 1
            break
        
    return frame, endpoint

#將上列工作濃縮成一個指令
def callframe(folder, nodes):
    return fail_seperate(framegenerate(folder, nodes))

#單一模型圖表生成
def plot_single(frame = None, endpoint = 0, column = None, title = None):
    if type(frame) != type(pd.DataFrame()):
        raise TypeError("this is only for dataframe of or_report")
    column_fail = column + '_fail'
    
    pic = plt.figure(figsize = (10, 5))
    pic = plt.plot(frame[column])
    pic = plt.plot(frame[column_fail])
    pic = plt.vlines(endpoint, ymin = 0, ymax = frame.loc[endpoint, (column)])
    pic = plt.xlabel('quantity of currency', fontdict = {'fontsize':15})
    pic = plt.ylabel(column, fontdict = {'fontsize': 15})
    pic = plt.fill_between(list(frame.index), frame[column], 0, alpha = 0.3)
    pic = plt.fill_between(list(frame.index), frame[column_fail], 0, alpha = 0.3)
    pic = plt.legend(('feasible', 'infeasible', 'max feasible',), fontsize = 12)
    pic = plt.title(title, fontdict = {'fontsize': 20})
    
    return pic



