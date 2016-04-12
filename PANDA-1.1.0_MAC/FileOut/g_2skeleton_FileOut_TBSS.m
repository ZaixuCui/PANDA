function [ FileOut ] = g_2skeleton_FileOut_TBSS( ResultPath,fileName )
%G_2SKELETON_FA_FILEOUT_TBSS Summary of this function goes here
%   Detailed explanation goes here

if strcmp(fileName(end-6:end), '.nii.gz')
    [a, FileNameSuffixWithNII, c] = fileparts(fileName);
    FileOut{1} = cat(2,ResultPath,FileNameSuffixWithNII(1:end-4),'_skeletonised.nii.gz');
elseif strcmp(fileName(end-3:end), '.nii')
    [a, FileNameSuffix, c] = fileparts(fileName);
    FileOut{1} = cat(2,ResultPath,FileNameSuffix,'_skeletonised.nii.gz');
else
    error('not a NIFTI file');
end



