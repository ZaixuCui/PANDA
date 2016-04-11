
function [ FileOut ] = g_2skeleton_L23m_FileOut( NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job 2skeleton_FA output 
% 2 files will be produced: _L23_to_target_1mm_skeletonised.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'standard_space' filesep dtifit_Prefix '_L23m_4normalize_to_target_1mm_skeletonised.nii.gz' ] ;
