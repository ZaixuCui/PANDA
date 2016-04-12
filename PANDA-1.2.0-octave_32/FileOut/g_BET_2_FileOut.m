function [ FileOut ] = g_BET_2_FileOut( NiiOutputPath,NumberOfSubject_String )
%
% FileOut contain all the files' full path of the job BET_2 output 
% 3 files will be produced: nodif_brain.nii.gz, nodif_brain_mask.nii.gz, 
%                           .done 
% .done file is sign of the completion of the job
%
FileOut='';