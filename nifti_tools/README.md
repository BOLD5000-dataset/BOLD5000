# NIFTI tools

A library for creating, deleting and manipulating NIFTI files in MATLAB. This library is an extension of the library proposed by [Jimmy Shen](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image).

Basically, I have updated the library with simple capabilities to load and save compressed NIFTI files. 

## Usage

The easiest way to load a NIFTI volume is using the function ```load_nifti```. This function will automatically detect if the image is compressed or not and load it. The path of the image has to be passed without extension. 

```
nifti_vol = load_nifti('path_to_the_image_without_extension')
```

Similarly, NIFTI volumes can be saved using the function ```save_nifti``` specifying if the NIFTI has to be compressed or not.


```
save_nifti(nifti_vol, 'path_to_the_image_without_extension', 'type')
```

where ```type``` can be compressed `'c'` or uncompressed `'u'`. If no parameter `type` is passed, the NIFTI images will be compressed by default.


## Test

So, far, I only tested on GNU/Linux, but should work on all platforms. 



