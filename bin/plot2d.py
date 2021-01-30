#! /usr/bin/env python3
import csv
import sys
import os
import numpy as np

import matplotlib
from matplotlib import pyplot as plt

import seaborn as sns
sns.set_style("darkgrid")

fig = plt.figure(figsize = (20, 8))

x_lim = (-0.325, -0.095)
y_lim = (-0.18, 0.05)
z_lim = (-0.06, 0.17)
force_lim = (-1, 1)

ax_x = fig.add_subplot(231, ylim = x_lim)
ax_x.set_xlabel("Time step")
ax_x.set_ylabel("X")

ax_y = fig.add_subplot(232)
ax_y.set_xlabel("Time step")
ax_y.set_ylabel("Y")

ax_z = fig.add_subplot(233)
ax_z.set_xlabel("Time step")
ax_z.set_ylabel("Z")

ax_fx = fig.add_subplot(234, ylim = force_lim)
ax_fx.set_xlabel("Time step")
ax_fx.set_ylabel("X feedback force")

ax_fy = fig.add_subplot(235, ylim = force_lim)
ax_fy.set_xlabel("Time step")
ax_fy.set_ylabel("Y feedback force")

ax_fz = fig.add_subplot(236, ylim = force_lim)
ax_fz.set_xlabel("Time step")
ax_fz.set_ylabel("Z feedback force")

if len(sys.argv) < 2:
    print("error: lack arguments")
    print("arg 1: desired trajectory path")
    print("arg 2: actual trajectory path")
    print("arg 3: force feedback path")
    sys.exit()

color_rgb = []
for idx, (color, rgb) in enumerate(matplotlib.colors.TABLEAU_COLORS.items()):
    color_rgb.append(rgb)

from scipy import interpolate

########## FILE READ ##########
desired_trajectory_path = sys.argv[1]
actual_trajectory_path  = sys.argv[2]
force_feedback_path     = sys.argv[3]

filepath = desired_trajectory_path 
with open(filepath, 'r') as file:
    X_d = []
    Y_d = []
    Z_d = []
    TIMESTEP = []
    reader = csv.reader(file)
    for index, line in enumerate(reader):
        TIMESTEP.append(index)
        X_d.append(float(line[0]))
        Y_d.append(float(line[1]))
        Z_d.append(float(line[2]))

    ax_x.plot(TIMESTEP, X_d, label='desired trajectory', color=color_rgb[3])
    ax_y.plot(TIMESTEP, Y_d, label='desired trajectory', color=color_rgb[3])
    ax_z.plot(TIMESTEP, Z_d, label='desired trajectory', color=color_rgb[3])

filepath = actual_trajectory_path 
header_seq = 0
with open(filepath, 'r') as file:
    X_a = []
    Y_a = []
    Z_a = []
    TIMESTEP = []
    reader = csv.reader(file)
    next(reader)
    time = 0
    for index, line in enumerate(reader):
        if line[4] == "1":
            if header_seq == 0: header_seq = line[1]
            X_a.append(float(line[5]))
            Y_a.append(float(line[6]))
            Z_a.append(float(line[7]))
            time+=1
    
    print(time)
    TIMESTEP = range(time)
    f_x = interpolate.interp1d(TIMESTEP, X_a, kind='linear')
    f_y = interpolate.interp1d(TIMESTEP, Y_a, kind='linear')
    f_z = interpolate.interp1d(TIMESTEP, Z_a, kind='linear')
    t_resample = np.linspace(0, TIMESTEP[-1], 100)
    X_a_resampled = f_x(t_resample)
    Y_a_resampled = f_y(t_resample)
    Z_a_resampled = f_z(t_resample)
    TIMESTEP_100 = range(100)
    ax_x.plot(TIMESTEP_100, X_a_resampled, label='actual trajectory', color=color_rgb[2])
    ax_y.plot(TIMESTEP_100, Y_a_resampled, label='actual trajectory', color=color_rgb[2])
    ax_z.plot(TIMESTEP_100, Z_a_resampled, label='actual trajectory', color=color_rgb[2])

with open(force_feedback_path, 'r') as file:
    X_f = []
    Y_f = []
    Z_f = []
    TIMESTEP = []
    reader = csv.reader(file)
    next(reader)
    time = 0
    start = 0
    for index, line in enumerate(reader):
        if line[1] == header_seq: start = 1
        if line[4] != "0.0" and start == 1:
            X_f.append(float(line[4]))
            Y_f.append(float(line[5]))
            Z_f.append(float(line[6]))
            time+=1
    
    print(time)
    TIMESTEP = range(time)
    f_x = interpolate.interp1d(TIMESTEP, X_f, kind='linear')
    f_y = interpolate.interp1d(TIMESTEP, Y_f, kind='linear')
    f_z = interpolate.interp1d(TIMESTEP, Z_f, kind='linear')
    t_resample = np.linspace(0, TIMESTEP[-1], 100)
    X_f_resampled = f_x(t_resample)
    Y_f_resampled = f_y(t_resample)
    Z_f_resampled = f_z(t_resample)
    TIMESTEP_100 = range(100)
    ax_fx.plot(TIMESTEP_100, X_f_resampled, label='force feedback', color=color_rgb[0])
    ax_fy.plot(TIMESTEP_100, Y_f_resampled, label='force feedback', color=color_rgb[0])
    ax_fz.plot(TIMESTEP_100, Z_f_resampled, label='force feedback', color=color_rgb[0])
ax_x.legend()

plt.savefig('/home/tomoki/Documents/record2d.eps', format='eps')
plt.savefig('/home/tomoki/Documents/record2d.png', format='png')
plt.show()
