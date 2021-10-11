function [nifti_out] = load_nifti(image_path)
%*****************************************************************
% LOAD NIFTI function
%    
% Simple function to load nii/nii.gz files automatically
%
% This library makes use of the wonderful toolbox provided by Jimmy Shen. 
% https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
%
% 
% ****************************************************************
    if exist([image_path,'.nii.gz'],'file')
        nifti_out = load_compressed_nii([image_path,'.nii.gz']);
    elseif exist([image_path,'.nii'],'file')
        nifti_out = load_untouch_nii([image_path,'.nii']);
    else
        error('NIFTI TOOLS: the file you are trying to load is not found or available. :(');
    end
 end