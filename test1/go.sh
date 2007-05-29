#!/bin/bash

export PATH=$PATH:~/icra07pis/src/libraries/fig/
export PATH=$PATH:../sm/

RAYTRACER=~/icra07pis/src/misc_apps/raytracer
LD_DRAW=~/icra07pis/src/misc_apps/ld_draw
FIGMERGE=figmerge
MULTIPLY=json_pipe
NOISE=ld_noise
SM1=sm1
JSON2MATLAB=../matlab_new/json2matlab.rb


dir=out/
mkdir -p $dir

num=100

fig=square.fig

nrays=181
fov_deg=180
max_reading=80
NOISE_ARGS="-sigma 0.01"
RAYTRACER_ARGS="-fig $fig -nrays $nrays -fov_deg $fov_deg -max_reading $max_reading"

pose1="5 5 0"
pose2="5.1 5.2 0.09"

echo $RAYTRACER $RAYTRACER_ARGS

echo $pose1 | $RAYTRACER $RAYTRACER_ARGS > $dir/scan1.txt
echo $pose2 | $RAYTRACER $RAYTRACER_ARGS > $dir/scan2.txt


$MULTIPLY -n $num < $dir/scan1.txt > $dir/scan1_noise.txt
$MULTIPLY -n $num < $dir/scan2.txt | $NOISE $NOISE_ARGS > $dir/scan2_noise.txt

$LD_DRAW < $dir/scan1.txt > $dir/scan1.fig
$LD_DRAW -config scan2.config < $dir/scan2.txt > $dir/scan2.fig

$FIGMERGE $fig $dir/scan1.fig > $dir/scan1-map.fig
$FIGMERGE $fig $dir/scan2.fig > $dir/scan2-map.fig
$FIGMERGE $fig $dir/scan1.fig $dir/scan2.fig > $dir/complete.fig

$SM1 -file1 $dir/scan1_noise.txt -file2 $dir/scan2_noise.txt -config sm1.config > $dir/results.txt

$JSON2MATLAB results < $dir/results.txt > $dir/results.m