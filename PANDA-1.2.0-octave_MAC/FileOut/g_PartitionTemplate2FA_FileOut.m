function [ FileOut ] = g_AAL2FA_FileOut( FAPath,PartitionTemplate )
%G_AAL2FA_FILEOUT Summary of this function goes here
%   Detailed explanation goes here
[NativeFolder, filename, c] = fileparts(FAPath);
[SubjectFolder, b, c] = fileparts(NativeFolder);
[a, PartitionTemplateNamePrefix, Suffix] = fileparts(PartitionTemplate);
if strcmp(Suffix, '.gz')
    FileOut{1} = [NativeFolder filesep filename(1:end-4) '_Parcellated_' PartitionTemplateNamePrefix(1:end-4) '.nii.gz'];
elseif strcmp(Suffix, '.nii') || isempty(Suffix)
    FileOut{1} = [NativeFolder filesep filename(1:end-4) '_Parcellated_' PartitionTemplateNamePrefix '.nii.gz'];
end



