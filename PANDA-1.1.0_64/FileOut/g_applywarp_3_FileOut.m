
function [ FileOut ] = g_applywarp_3_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job applywarp_3 output 
% 2 files will be produced: _MD_to_target_1mm.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'standard_space' filesep dtifit_Prefix '_MD_4normalize_to_target_1mm.nii.gz' ] ;
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];