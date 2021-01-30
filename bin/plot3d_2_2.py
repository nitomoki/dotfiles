#! /usr/bin/env python3
import csv
import sys
import os
#import numpy as np
#X = np.array([i for i in range(1,1000)])
#Y = np.sin(X)
#Z = np.log(Y)

axes_lim = {'X':[-0.25, -0.13],'Y':[-0.15, 0.15],'Z':[-0.06, 0.2]}

import matplotlib
from matplotlib import pyplot as plt

import seaborn as sns
sns.set_style("darkgrid")
#sns.set()


fig = plt.figure()


ax = fig.add_subplot(111, projection='3d')
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")
ax.set_xlim(axes_lim['X'])
ax.set_ylim(axes_lim['Y'])
ax.set_zlim(axes_lim['Z'])
ax.view_init(azim=200)

if len(sys.argv) < 2:
    print("error: need argument filepath")
    sys.exit()

color_rgb = []
for idx, (color, rgb) in enumerate(matplotlib.colors.TABLEAU_COLORS.items()):
    color_rgb.append(rgb)

########## FILE READ ##########
desired_fpath = sys.argv[1]
with open(desired_fpath, 'r') as file:
    X_desired=[]
    Y_desired=[]
    Z_desired=[]
    reader=csv.reader(file)
    for line in reader:
        X_desired.append(float(line[0]))
        Y_desired.append(float(line[1]))
        Z_desired.append(float(line[2]))
    ax.plot(X_desired, Y_desired, Z_desired, marker='.', markersize=4, linestyle='None', label='desired trajectory', color=color_rgb[3])

actual_fpath = sys.argv[2]
with open(actual_fpath, 'r') as file:
    reader = csv.reader(file)
    next(reader)
    prev = 0
    X_actual,Y_actual,Z_actual = [], [], []
    for line in reader:
        if line[1] == "1":
            X_actual.append(float(line[8]))
            Y_actual.append(float(line[9]))
            Z_actual.append(float(line[10]))
            prev = 1
    ax.plot(X_actual,Y_actual,Z_actual,marker=".",markersize=4,linestyle='None',label='actual trajectory', color=color_rgb[2])
#resampled_dir_path = sys.argv[1] # DIRECTORY
#i = 0
#
#for item in os.listdir(resampled_dir_path):
#    filepath = resampled_dir_path + "/" + item
#    with open(filepath, 'r') as file:
#        X = []
#        Y = []
#        Z = []
#        reader = csv.reader(file)
#        for line in reader:
#            X.append(float(line[0]))
#            Y.append(float(line[1]))
#            Z.append(float(line[2]))
#
#        ax.plot(X,Y,Z,marker=".",markersize=4,linestyle='None', color=color_rgb[0])
#
#
#with open(filepath, 'r') as file:
#    reader = csv.reader(file)
#    next(reader)
#    prev = 0
#    for line in reader:
#        if line[1] == "0" and prev == 1:
#            ax.plot(X,Y,Z,marker=".",markersize=3,linestyle='None', color=color_rgb[0])
#            X,Y,Z = [], [], []
#
#        if line[1] == "1":
#            X.append(float(line[8]))
#            Y.append(float(line[9]))
#            Z.append(float(line[10]))
#            prev = 1

#filepath_2 = sys.argv[2]
#
#X,Y,Z = [], [], []
#with open(filepath_2, 'r') as file2:
#    reader = csv.reader(file2)
#    for line in reader:
#        X.append(float(line[0]))
#        Y.append(float(line[1]))
#        Z.append(float(line[2]))
#
#ax.plot(X,Y,Z,marker="o",markersize=3,label='desired trajectory',linestyle='None', color=color_rgb[3])
#
#filepath_3 = sys.argv[3]
#X,Y,Z = [], [], []
#with open(filepath_3, 'r') as file2:
#    reader = csv.reader(file2)
#    for line in reader:
#        X.append(float(line[0]))
#        Y.append(float(line[1]))
#        Z.append(float(line[2]))

#ax.plot(X, Y, Z, marker='^', markersize=6, label='goal position', linestyle='None', color=color_rgb[3])
ax.legend()

plt.savefig('/home/tomoki/Documents/record_2_2.eps', format='eps')
plt.savefig('/home/tomoki/Documents/record_2_2.png', format='png')
plt.show()

