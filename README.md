# Resting-State fMRI Analysis Pipeline using CONN (rest_pipeline)

This code is intended to be used in our lab only, but feel free to have a look at it and how I made use of CONN's batch functionality.

## Introduction
This MATLAB-pipeline is based on CONN (Functional Connectivity Toolbox) and is intended to merely serve as a wrapper for CONN's batch function, which can be quite tedious some times. The basic idea is to simplify the import of data, the use of multiple atlases and within these the specification of (the to-be-analyzed) ROIs - all when using CONN's batch functionality.

## Installation
No installation is needed, but you need CONN and SPM.

## How to
To run data through this pipeline, follow these steps:

1. Make sure all your data is in one folder with a sub-folder per subject. Within the subject's folders, you need to have either a 4D-Nifti file or multiple HDR-images.

2. Open 'run_rest_pipeline.m' and save it under a different name which is specific to your project.

3. In this m-file, insert all your project's specifications as described in the comments within that file.

4. After running through all the variables in the first part of the script, continue with the second part and specify all analyses that you want to run. When you're running the analysis for the first time and want to end up with the connectivity matrices, run everything but the second-level analysis.

5. If you need to specify additional CONN parameters, do so by using the 'initConnBatchCustom.m' file. You can find a description of all CONN parameters in 'conn_batch_overview.xlsx'.


## Copyright
Nils Winter, Frankfurt 2016, nils.r.winter@gmail.com
