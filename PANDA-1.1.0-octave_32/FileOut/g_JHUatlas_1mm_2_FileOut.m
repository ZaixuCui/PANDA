function [ FileOut ] = g_JHUatlas_1mm_2_FileOut( NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job JHUatlas_1mm_2 output 
% 3 files will be produced: _MD_to_target_1mm.WMlabel, 
%                           _MD_to_target_1mm.WMtract, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'standard_space' filesep dtifit_Prefix '_MD_4normalize_to_target_1mm.WMlabel' ] ;
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'standard_space' filesep dtifit_Prefix '_MD_4normalize_to_target_1mm.WMtract' ] ;
