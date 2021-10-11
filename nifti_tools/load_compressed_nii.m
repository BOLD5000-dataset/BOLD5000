
function [nifti_out] = load_compressed_nii(image_path, untouch)
%*****************************************************************
% LOAD NIFTI compressed nifti
%    
% Simple function to decompress and load a nifti volume.
%
% This library makes use of the wonderful toolbox provided by Jimmy Shen. 
% https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image    
% 
% USE: 
%   [nifti_out] = load_compressed_nii(image_path, untouch)
% IN:
%   image_path - full path to compressed nifti file (*.nii.gz)
%   untouch    - if true, uses load_untouch_nii instead of load_nii (default:0)
% OUT:
%   nifti_out  - loaded nifti structure from niftiTools
%
% ****************************************************************  

    if(nargin<2)
        untouch = 0;
    end
    
    % input file: full path with extension only
    if(~exist(image_path,'file'))
        error('Input file not found: %s',image_path);
    end
    [~, fnm] = fileparts(image_path);    
    [~,fnm] = fileparts(fnm); % get rid of *.nii
    
    % assign a new tmp_id to each volume is useful when the same images are used in parallel    
    s = clock;    
    tmp_id = num2str(round(rand*1000*s(6)));
    tmppath = fullfile(tempdir(),[fnm,'_', tmp_id]);
    tmpGZ = [tmppath '.nii.gz'];   
    tmpNII = [tmppath '.nii'];
    
    % copy original *.nii.gz to temp folder + unzip
    copyfile(image_path, tmpGZ);    
    filenames = gunzip(tmpGZ);
    if(length(filenames)~=1)
        warning('multiple (%s) files in the gzip archive: probably not a proper .nii.gz file')
    end
    
    % load unzipped
    if(untouch)
        nifti_out = load_untouch_nii(tmpNII);
    else
        nifti_out = load_nii(tmpNII);
    end
    
    % clean-up both
    delete(tmpGZ);
    if exist(tmpNII, 'file')
        delete(tmpNII);
    end
end


