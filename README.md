<!-- # **BOLD5000 2.0: a massive-scale fMRI dataset to advance the study of human and machine vision** -->
# **BOLD5000, a public fMRI dataset while viewing 5000 visual images**
![image](https://user-images.githubusercontent.com/35503086/135143518-f7904f98-d0c2-4185-b9b3-83d4ea53f10f.png)

### [Project page](bold5000.org) | [Paper](https://www.nature.com/articles/s41597-019-0052-3) | [List Serv](https://docs.google.com/forms/d/e/1FAIpQLScdxRc7eKOpZv5Yc6sfzWP5gi0egkDtNSPedVqpvtx_3yw4pg/viewform)

BOLD5000, a public fMRI dataset while viewing 5000 visual images.<br>
[Nadine Chang](nadinechang.com), [John A. Pyles](https://www.linkedin.com/in/john-pyles-37401a7a/), [Jacob Prince](https://jacob-prince.github.io), Austin Marcus, [Michael J. Tarr](https://sites.google.com/andrew.cmu.edu/tarrlab/people/michael-j-tarr?authuser=0), [Elissa M. Aminoff](https://www.fordham.edu/info/21660/faculty_and_staff/9370/elissa_aminoff/1) <br>
Nature Scientific Data 2019.

BOLD5000 is a human functional MRI (fMRI) study that includes almost 5,000 distinct images depicting real-world scenes, incorporating images from the Scene UNderstanding (SUN), Common Objects in Context (COCO), and ImageNet datasets. The scale and diversity of these image datasets, combined with a slow event-related fMRI design, enables fine-grained exploration into the neural representation of a wide range of visual features, categories, and semantics.

**[BOLD5000 Release 2.0](https://figshare.com/s/bbaf45dca1b1b873ddfa) is a complete re-release of functional data from BOLD5000, with optimized procedures for GLM estimation of brain-wide percent signal change in response to the experimental stimuli, yielding significant increases in the reliability of BOLD signal estimates compared to the initial data release.**

**For all analyses of functional data from BOLD5000, we highly recommend utilizing data from Release 2.0.**

Moving forward, we will continue to update BOLD5000 Release 2.0 with additional data versions, files for defining functional ROIs, and other relevant additions. If you would like to be notified, please sign up for our listserv [here](https://docs.google.com/forms/d/e/1FAIpQLScdxRc7eKOpZv5Yc6sfzWP5gi0egkDtNSPedVqpvtx_3yw4pg/viewform).

To access BIDS-formatted raw MRI data files, experimental stimuli, behavioral data, physiological data, scanning protocols, image labels, and code from the experimment, please refer to the [Dataset Download](https://bold5000-dataset.github.io/website/download.html) page. 

# **Methods for improved data quality**

Data included in BOLD5000 Release 2.0 integrate three techniques designed to improve the accuracy of trial-wise GLM beta estimates:

1.  First, for each voxel, a custom hemodynamic response function (HRF) is identified from a library of candidate functions.
    
2.  Second, the selected HRFs are used in a cross-validated GLM in order to derive a set of optimized noise regressors from voxels unrelated to the experimental paradigm (“[GLMdenoise](https://www.frontiersin.org/articles/10.3389/fnins.2013.00247/full)”; Kay et al., 2013).

3. Third, to mitigate the effects of signal overlap, beta estimates are regularized on a voxel-by-voxel basis using ridge regression (“[Fracridge](https://arxiv.org/pdf/2005.03220v1.pdf)” Kay & Rokem, 2020).

See the “GLM Analysis” section of the newly-available [Natural Scenes Dataset preprint](https://www.biorxiv.org/content/10.1101/2021.02.22.432340v1) for further details on these methods. Code for these approaches will be released in the near future – **if you would like to be notified, please sign up for our listserv [here](https://docs.google.com/forms/d/e/1FAIpQLScdxRc7eKOpZv5Yc6sfzWP5gi0egkDtNSPedVqpvtx_3yw4pg/viewform).**

# **Code for Release 2.0**

Code included in this repository can be used to replicate GLM fitting from BOLD5000 Release 2.0 using BIDS-formatted data. 

### Requirements ###
Please refer to [GLMsingle](https://github.com/cvnlab/GLMsingle) for installation instructions. 

Please refer to [fracridge](https://github.com/nrdg/fracridge) for installation instructions.

please refer to the [Dataset Download](https://bold5000-dataset.github.io/website/download.html) for release 2.0 data download. 

### Instructions ###
After downloading the time-series data using the link above, GLM routines for a given subject/session(s) can be run using the MATLAB script `run_GLMsingle_pipeline_BOLD5000.m`.  

The script `example_GLM_usage.sh` shows how to call this function: 
```
./example_GLM_usage.sh CSI1 1_5_10 optimize /path/to/BIDS/dataset/ output_dirname
```

Description of arguments: 
```
arg 1: <subj> is the string identifier for a BOLD5000 subject (CSI1, CSI2, CSI3, or CSI4) 
determining which subject's data will be processed.

arg 2: <sess> is a string defining which sessions of data will be processed. subjects 1-3 
completed all 15 sessions, while subject 4 completed 9 sessions. because GLMsingle relies 
on the existence of repeated stimuli within each group of data being processed, it is 
likely best to process several sessions of data simultaneously to maximize the available 
image repetitions. inputs should be formatted as numbers separated by underscores - for
example, to process data from sessions 1, 4, 9, and 13, <sess> would be "1_4_9_13".

arg 3: <GLM_method> describes which combination of GLMsingle hyperparameters should be 
applied for this run. "assume" fits the GLM using the canonical HRF, with no denoising 
or ridge regression. "optimize" (recommended) performs a complete run of GLMsingle 
incorporating HRF fitting, GLMdenoise, and ridge regression. 

arg 4: <bidsdir> is a filepath pointing to the location of BOLD5000 fMRI time-series 
data in BIDS format. these data are available here: 
https://openneuro.org/datasets/ds001499/versions/1.3.1

arg 5: <outputdir> is a user-provided string that will name the folder into which 
outputs will be saved.
```

# **Summary of data versions available in Release 2.0**

[Click here](https://figshare.com/s/bbaf45dca1b1b873ddfa) to access the most up-to-date BOLD5000 data from Release 2.0. 

See below for a summary of the 5 complete versions of the functional data that are available for download. **We recommend using the TYPED betas, which contain the complete set of GLM optimizations described above.**

| Data version descriptor                  | GLM betas vs. residual time-series | HRF opt?       | GLMdenoise? | Ridge regression? | File save format             | Naming scheme                                           |
|------------------------------------------|------------------------------------|----------------|-------------|-------------------|------------------------------|---------------------------------------------------------|
| TYPEA-ASSUMEHRF                          | betas                              | 🚫  (canonical) | 🚫           | 🚫                 | One .nii.gz file per session | CSIX_GLMbetas-TYPEA-ASSUMEHRF_ses-XX.nii.gz            |
| TYBEB-FITHRF                             | betas                              | ✅              | 🚫           | 🚫                 | One .nii.gz file per session | CSIX_GLMbetas-TYBEB-FITHRF_ses-XX.nii.gz               |
| TYPEC-FITHRF-GLMDENOISE                  | betas                              | ✅              | ✅           | 🚫                 | One .nii.gz file per session | CSIX_GLMbetas-TYPEC-FITHRF-GLMDENOISE_ses-XX.nii.gz    |
| TYPED-FITHRF-GLMDENOISE-RR (recommended) | betas                              | ✅              | ✅           | ✅                 | One .nii.gz file per session | CSIX_GLMbetas-TYPED-FITHRF-GLMDENOISE-RR_ses-XX.nii.gz |
| SPM-RESIDUAL *                           | time series of residuals           | 🚫              | 🚫           | 🚫                 | One .nii.gz file per session | CSIX_SPMResids_allsess_TRX.nii.gz                       |

\*  SPM-RESIDUAL version refers to whole-brain data preprocessed in an identical manner to the ROI data described in the [BOLD5000 paper](https://www.nature.com/articles/s41597-019-0052-3), via fmriPrep and SPM.

# General Study Design Overview:

| Subject | N sessions experimental data | N trials completed | Dimensionality of subject-space volumes |
|---------|------------------------------|--------------------|-----------------------------------------|
| CSI1    | 15                           | 5254               | (71, 89, 72)                            |
| CSI2    | 15                           | 5254               | (72, 92, 70)                            |
| CSI3    | 15                           | 5254               | (72, 88, 67)                            |
| CSI4    | 9                            | 3108               | (70, 89, 70)                            |

Each experimental run contains 37 stimuli. The fMRI sampling rate is TR = 2 sec, and the resolution of each voxel is 2mm isotropic. The presentation order of the stimulus images is randomly and uniquely determined for each participant. Each image is presented for 1 sec followed by a 9 sec fixation cross. For each subject, some sessions contain 9 runs (333 stimuli each) and others contain 10 runs (370 stimuli each).

# FAQs:

**What makes BOLD5000 different from other large-scale fMRI datasets?**

BOLD5000 contains images from the ImageNet, COCO, and SUN datasets, enabling flexible comparisons between neural responses and machine learning models trained on a diverse array of computer vision benchmarks.

BOLD5000 experimental stimuli are 10 sec apart; in theory, the neural responses to stimuli in BOLD5000 should be less affected by responses to neighboring trials than in more rapid event-related designs (e.g. the Natural Scenes Dataset, which has a 4 sec inter-stimulus interval).

BOLD5000 has a substantial quantity of stimuli that overlap between subjects (4916 unique images). Extensive sampling of individuals in the study does not prevent cross-subject aggregation and comparison.

**Can I use BOLD5000 and the [Natural Scenes Dataset](http://naturalscenesdataset.org/) together in my analyses?**

Yes! There are several thousand images that overlap between the datasets; this was a purposeful aspect of their design. This overlap directly allows users to develop models/theories using one dataset, and to then use the other as a validation or test dataset.

**How have people already used BOLD5000?**

        ...to [infer the similarity of different task-derived neural representations](https://openreview.net/pdf?id=ryGCaBreIB)

        ...to [study how local and global symmetry differentially influence neural responses to real-world scenes](https://jov.arvojournals.org/article.aspx?articleid=2771866)

        ...to [show that discriminability and similarity, at different visual levels, predict image memorability](https://www.biorxiv.org/content/10.1101/834796v3.full.pdf)

        ...to [assess the similarity of cortical object and scene representations through cross-validated voxel encoding models](https://jov.arvojournals.org/article.aspx?articleid=2750674)

        ...among many other contexts and studies!

**Where can I access BOLD5000 v2.0 data?**

All files are available for download on Figshare at the following link. [add link]

**What are the differences between files available on OpenNeuro and on Figshare?**

BOLD5000 v1.0 data is currently available in BIDS format on OpenNeuro [link]. Currently, v2.0 is available only on Figshare [link]. In coming months, we are planning to release BOLD5000 v2.0 data in BIDS format on OpenNeuro. Sign up here [link] if you would like to be notified about future data releases.

**Where are the BOLD5000 stimulus images, and how can I download them?**

Stimulus images are available for direct download on the BOLD5000 website, at the following [link](https://bold5000.github.io/download.html).

**When I load a data file using TYPE A-D betas from BOLD5000 v2.0, what do the units refer to?**

These values can be interpreted as percent signal change at a given voxel in response to a given experimental stimulus. Prior to saving, GLM betas were converted to units of percent signal change by dividing amplitudes by the mean signal intensity observed at each voxel and multiplying by 100.

**How should I account for drifts in mean/variance of BOLD responses from session to session?**

It is recommended that betas for each voxel be z-scored within each scan session prior to conducting further analysis.

**Is the data format the same for all data versions in BOLD5000 v2.0?**

For the TYPEA-D betas, the format is identical between versions. Session betas are stored in the (X, Y, Z, img) volumetric format.
