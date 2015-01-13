#!/bin/bash

julia -p $2 $1 &> output_$1_run1
julia -p $2 $1 &> output_$1_run2
julia -p $2 $1 &> output_$1_run3
julia -p $2 $1 &> output_$1_run4
julia -p $2 $1 &> output_$1_run5
