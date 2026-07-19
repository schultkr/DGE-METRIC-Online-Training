% ToyModelSOEMC_run_training_2x2x2.m
% Self-contained training launcher (2x2x2 joint policy grid).

clc; close all;

this_folder = fileparts(mfilename('fullpath'));
addpath(this_folder);
cd(this_folder);

MINIMAL_MODE = false;
TRAINING_MODE = true;

run(fullfile(this_folder, 'ToyModelSOEMC_run.m'));
