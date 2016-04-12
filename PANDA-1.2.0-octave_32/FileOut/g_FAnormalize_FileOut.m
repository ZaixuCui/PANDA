function [ FileOut ] = g_FAnormalize_FileOut( NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job FAnormalize2 output 
% 6 files will be produced: _FA_4normalize_to_FMRIB58_FA_1mm.log, 
%                           _FA_4normalize_to_target.done,
%                           _FA_4normalize_to_target.mat,
%                           _FA_4normalize_to_target_warp.msf,
%                           _FA_4normalize_to_target_warp.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_FMRIB58_FA_1mm.log' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_target.mat' ];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_target_warp.msf' ];
FileOut{4} = [NiiOutputPath NumberOfSubject_String filesep 'transformation' filesep dtifit_Prefix '_FA_4normalize_to_target_warp.nii.gz' ];

