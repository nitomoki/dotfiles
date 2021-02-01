#! /usr/bin/env python3
import csv
import sys
import os
import numpy as np
import math
from scipy import interpolate

axes_lim = {'X':[-0.25, -0.13],'Y':[-0.15, 0.15],'Z':[-0.06, 0.2]}

import matplotlib
from matplotlib import pyplot as plt

import seaborn as sns
sns.set(style="ticks")
sns.set_style('whitegrid')


fig = plt.figure(figsize = (20,8))

ax_t = fig.add_subplot(131)
ax_t.set_xlabel("Time steps")
ax_t.set_ylabel("distance")

ax_p = fig.add_subplot(132)
ax_p.set_xlabel("Time steps")
ax_p.set_ylabel("Possibility")

ax_f = fig.add_subplot(133)
ax_f.set_xlabel("Time steps")
ax_f.set_ylabel("feedback force")


if len(sys.argv) < 2:
    print("recorded_dpath, actual_fpath, possibility_fpath, force_feedback_fpath")
    sys.exit()

color_rgb = []
for idx, (color, rgb) in enumerate(matplotlib.colors.TABLEAU_COLORS.items()):
    color_rgb.append(rgb)

########## FILE READ ##########
recorded_dpath = sys.argv[1]
actual_fpath = sys.argv[2]
possibility_fpath = sys.argv[3]
force_feedback_fpath = sys.argv[4]

########## Recorded trajectory ##########
rcd_X = []
rcd_Y = []
rcd_Z = []
#color 4, 5
for item in os.listdir(recorded_dpath):
    filepath = recorded_dpath + "/" + item
    with open(filepath, 'r') as file:
        X = []
        Y = []
        Z = []
        reader = csv.reader(file)
        for line in reader:
            X.append(float(line[0]))
            Y.append(float(line[1]))
            Z.append(float(line[2]))

        rcd_X.append(X)
        rcd_Y.append(Y)
        rcd_Z.append(Z)

########## Actual trajectory ##########
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

########## Calc distance ##########
i = 0
for rX, rY, rZ in zip(rcd_X, rcd_Y, rcd_Z):
        distX = [rx-ax for rx, ax in zip(rX, X_a_resampled)]
        distY = [ry-ay for ry, ay in zip(rY, Y_a_resampled)]
        distZ = [rz-az for rz, az in zip(rZ, Z_a_resampled)]
        dist = [np.sqrt(dx**2 + dy**2 + dz**2) for dx, dy, dz, in zip(distX, distY, distZ)]
        TIMESTEP_100 = range(100)
        ax_t.plot(TIMESTEP_100, dist, label='distance '+ str(i+1), color=color_rgb[i+4])
        i+=1

########## Possibility ##########
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
    p_1_re = f_1(t_resample)
    p_2_re = f_2(t_resample)
    p_max = [p1 if p1 > p2 else p2 for (p1, p2) in zip(p_1_re, p_2_re)]
    TIMESTEP_100 = range(100)
    ax_p.plot(TIMESTEP_100, p_1_re, label='possibility 1', color=color_rgb[4])
    ax_p.plot(TIMESTEP_100, p_2_re, label='possibility 2', color=color_rgb[5])


with open(force_feedback_fpath, 'r') as file:
    X_f = []
    Y_f = []
    Z_f = []
    TIMESTEP = []
    reader = csv.reader(file)
    next(reader)
    time = 0
    for index, line in enumerate(reader):
        if line[4] != "0.0" :
            X_f.append(float(line[4]))
            Y_f.append(float(line[5]))
            Z_f.append(float(line[6]))
            time+=1
    
    TIMESTEP = range(time)
    f_x = interpolate.interp1d(TIMESTEP, X_f, kind='linear')
    f_y = interpolate.interp1d(TIMESTEP, Y_f, kind='linear')
    f_z = interpolate.interp1d(TIMESTEP, Z_f, kind='linear')
    t_resample = np.linspace(0, TIMESTEP[-1], 100)
    X_f_resampled = f_x(t_resample)
    Y_f_resampled = f_y(t_resample)
    Z_f_resampled = f_z(t_resample)
    TIMESTEP_100 = range(100)
    F_reduced = [np.sqrt(x**2 + y**2 + z**2) for x, y, z in zip(X_f_resampled, Y_f_resampled, Z_f_resampled)]
    F = [f / p for (f, p) in zip(F_reduced, p_max)]
    ax_f.plot(TIMESTEP_100, F, label='force feedback')
    ax_f.plot(TIMESTEP_100, F_reduced, label='reduced force feedback')

ax_t.legend()
ax_p.legend()
ax_f.legend()
print('save plot as record2way_force')
plt.savefig('/home/tomoki/Documents/record2way_force.eps', format='eps')
plt.savefig('/home/tomoki/Documents/record2way_force.png', format='png')
plt.show()

