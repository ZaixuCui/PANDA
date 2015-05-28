function [ FileOut ] = g_BeforeNormalize_L1_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job FAnormalize1 output 
% 3 files will be produced: _L1_4normalize.nii.gz, 
%                           _L1_4normalize_mask.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_L1_4normalize.nii.gz' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_L1_4normalize_mask.nii.gz' ];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];