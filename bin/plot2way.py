#! /usr/bin/env python3
import csv
import sys
import os
import numpy as np
from scipy import interpolate

axes_lim = {'X':[-0.25, -0.13],'Y':[-0.15, 0.15],'Z':[-0.06, 0.2]}

import matplotlib
from matplotlib import pyplot as plt

import seaborn as sns
sns.set_style("darkgrid")
#sns.set()


fig = plt.figure()


ax_at = fig.add_subplot(121, projection='3d')
ax_at.set_xlabel("X")
ax_at.set_ylabel("Y")
ax_at.set_zlabel("Z")
ax_at.set_xlim(axes_lim['X'])
ax_at.set_ylim(axes_lim['Y'])
ax_at.set_zlim(axes_lim['Z'])
ax_at.view_init(azim=200)

ax_p = fig.add_subplot(122)
ax_p.set_xlabel("Timestep")
ax_p.set_ylabel("Possibility")

if len(sys.argv) < 2:
    print("resampled_dir, actual_fpath, possibility_fpath")
    sys.exit()

color_rgb = []
for idx, (color, rgb) in enumerate(matplotlib.colors.TABLEAU_COLORS.items()):
    color_rgb.append(rgb)

########## FILE READ ##########
resampled_dir_path = sys.argv[1]
actual_fpath = sys.argv[2]
possibility_fpath = sys.argv[3]

i = 4
for item in os.listdir(resampled_dir_path):
    filepath = resampled_dir_path + "/" + item
    with open(filepath, 'r') as file:
        X = []
        Y = []
        Z = []
        reader = csv.reader(file)
        for line in reader:
            X.append(float(line[0]))
            Y.append(float(line[1]))
            Z.append(float(line[2]))

        ax_at.plot(X,Y,Z,marker=".",markersize=4,linestyle='None', color=color_rgb[i])
        i+=1


with open(actual_fpath, 'r') as file:
    reader = csv.reader(file)
    next(reader)
    X_a,Y_a,Z_a = [], [], []
    TIMESTEP = []
    time = 0
    for line in reader:
        if line[4] == "1":
            X_a.append(float(line[5]))
            Y_a.append(float(line[6]))
            Z_a.append(float(line[7]))
            time+=1
    TIMESTEP = range(time)
    f_x = interpolate.interp1d(TIMESTEP, X_a, kind='linear')
    f_y = interpolate.interp1d(TIMESTEP, Y_a, kind='linear')
    f_z = interpolate.interp1d(TIMESTEP, Z_a, kind='linear')
    t_resample = np.linspace(0, TIMESTEP[-1], 100)
    X_a_resampled = f_x(t_resample)
    Y_a_resampled = f_y(t_resample)
    Z_a_resampled = f_z(t_resample)
    ax_at.plot(X_a_resampled,Y_a_resampled,Z_a_resampled,marker=".",markersize=4,linestyle='None',label='actual trajectory', color=color_rgb[2])

with open(possibility_fpath, 'r') as file:
    reader = csv.reader(file)
    next(reader)
    p_1 = []
    p_2 = []
    TIMESTEP = []
    time = 0
    for line in reader:
        p_1.append(float(line[4]))
        p_2.append(float(line[5]))
        time+=1
    TIMESTEP = range(time)
    f_1 = interpolate.interp1d(TIMESTEP, p_1, kind='linear')
    f_2 = interpolate.interp1d(TIMESTEP, p_2, kind='linear')
    t_resample = np.linspace(0, TIMESTEP[-1], 100)
    print(t_resample)
    p_1_re = f_1(t_resample)
    p_2_re = f_2(t_resample)
    TIMESTEP_100 = range(100)
    ax_p.plot(TIMESTEP_100, p_1_re, label='possibility 1', color=color_rgb[4])
    ax_p.plot(TIMESTEP_100, p_2_re, label='possibility 2', color=color_rgb[5])


ax_at.legend()
plt.savefig('/home/tomoki/Documents/record2way.eps', format='eps')
plt.savefig('/home/tomoki/Documents/record2way.png', format='png')
plt.show()

