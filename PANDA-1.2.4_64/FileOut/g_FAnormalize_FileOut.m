function [ FileOut ] = g_FAnormalize_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job FAnormalize2 output 
% 5 files will be produced: _FA_4normalize_to_target.mat,
%                           _FA_4normalize_to_target_warp.msf,
%                           _FA_4normalize_to_target_warp.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_target.mat' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_target_warp.msf' ];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_target_warp.nii.gz' ];
FileOut{4} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];