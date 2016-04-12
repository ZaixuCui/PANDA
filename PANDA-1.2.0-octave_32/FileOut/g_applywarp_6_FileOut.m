
function [ FileOut ] = g_applywarp_6_FileOut( NiiOutputPath,NumberOfSubject_String,dtifit_Prefix,Resolution )
%
% FileOut contain all the files' full path of the job applywarp_6 output 
% 2 files will be produced: _L1_to_target_2mm.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'standard_space' filesep dtifit_Prefix '_L1_4normalize_to_target_' num2str(Resolution) 'mm.nii.gz' ] ;
