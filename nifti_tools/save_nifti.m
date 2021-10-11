function [nifti_out] = save_nifti(nii, image_path, type)
%*****************************************************************
% SAVE NIFTI function
%    
% Simple function to save nii/nii.gz files automatically
% - parameter type controls if the image has to be saved compressed or uncrompressed.
%   - type = 'C' --> compressed
%   - type = 'U' --> uncompressed
%
% This library makes use of the wonderful toolbox provided by Jimmy Shen. 
% https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image
%
% 
% ****************************************************************


    % images are compressed by default
    switch nargin
      case 2
        type = 'c';
      otherwise
        type = type;
    end


    if strcmp(type,'c')
        save_compressed_nii(nii, image_path);
    elseif strcmp(type,'u')
        save_untouch_nii(nii, [image_path,'.nii']);
    else
        error('NIFTI TOOLS: the option you are specifiying is not found or available. :(');
    end
 end