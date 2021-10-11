# GLMsingle

![image](https://user-images.githubusercontent.com/35503086/130008633-68ce6bb0-ca7f-4865-9d3a-c23ec2e2f0bc.png)

-------------------------------------------------------------------------------------------

GLMsingle is a toolbox for obtaining accurate single-trial estimates
in fMRI time-series data. We provide both MATLAB and Python implementations. 

GLMsingle can be viewed as a wholesale replacement of its predecessor,
GLMdenoise (http://github.com/kendrickkay/GLMdenoise).

For additional information, please see the Wiki page of
the GLMsingle repository (https://github.com/kendrickkay/GLMsingle/wiki).

If you have questions or discussion points, please use the Discussions
feature of this github repository, or alternatively, e-mail
Kendrick (kay@umn.edu). If you find a bug, please let us know by
raising a Github issue.

## MATLAB

To use the GLMsingle toolbox, add it to your MATLAB path:
  addpath(genpath('GLMsingle/matlab'));

You will also need to download and add fracridge to your path.
It is available here: https://github.com/nrdg/fracridge

To try the toolbox on an example dataset, change to the GLMsingle directory 
and then TBD...

## Python

To install: 

```bash
pip install -r requirements.txt
pip install .
```

Code dependencies: see requirements.txt

Notes:
* Please note that GLMsingle is not (yet) compatible with Python 3.9 (due to an incompatibility between scikit-learn and Python 3.9). Please use Python 3.8 or earlier.
* Currently, numpy has a 4GB limit for the pickle files it writes; thus, GLMsingle will crash if the file outputs exceed that size. One workaround is to turn off "disk saving" and instead get the outputs of GLMsingle in your workspace and save the outputs yourself to HDF5 format.

## Additional information

For additional information, please visit the Wiki page associated with this
repository: https://github.com/kendrickkay/GLMsingle/wiki

Terms of use: This content is licensed under a BSD 3-Clause License.

If you use GLMsingle in your research, please cite the following paper:
* [Allen, E.J., St-Yves, G., Wu, Y., Breedlove, J.L., Dowdle, L.T., Caron, B., Pestilli, F., Charest, I., Hutchinson, J.B., Naselaris, T.\*, Kay, K.\* A massive 7T fMRI dataset to bridge cognitive and computational neuroscience. bioRxiv (2021).](https://www.biorxiv.org/content/10.1101/2021.02.22.432340v1)

## Change history

* 2021/05/21 - The core code is complete, but is in "beta" and we are generating tutorial examples of usage. The initial 1.0 release should be forthcoming.
