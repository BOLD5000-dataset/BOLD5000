function save_compressed_nii(nii_struct, output_path, untouch)
%*****************************************************************
% SAVE NIFTI compressed nifti
%    
% Simple function to save a nifti volume in compressed mode.
%
% This library makes use of the wonderful toolbox provided by Jimmy Shen. 
% https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image    
% 
% USE:
%   save_compressed_nii(nii_image, image_path)
% IN:
%   nii_struct  - niftiTools structure, containing nifti data
%   output_path - full filename to write the output nifti image, including
%                 file extension
%   untouch     - if true, use save_untouch_nii instead of save_nii (default:0)
%   
% ****************************************************************  
    
    if(nargin<3)
        untouch = false;
    end
    
    [pth, fname] = fileparts(output_path);
    [~,fname] = fileparts(fname);
    
    tmpNII = [pth '/',fname,'_tmp_.nii'];
    tmpGZ = [tmpNII '.gz'];
    
    % create temporary nii file
    if(untouch)
        save_untouch_nii(nii_struct, tmpNII); 
    else
        save_nii(nii_struct,tmpNII);
    end
    
    % gzip + clear temporary *.nii file
    gzip(tmpNII);
    movefile(tmpGZ, output_path);
    delete(tmpNII);
   
end