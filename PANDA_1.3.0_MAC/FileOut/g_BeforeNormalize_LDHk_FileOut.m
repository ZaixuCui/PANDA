
function [ FileOut ] = g_BeforeNormalize_LDHk_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,dtifit_Prefix,Nvoxel )
%
% FileOut contain all the files' full path of the job FAnormalize1 output 
% 3 files will be produced: _..LDHk_4normalize.nii.gz, 
%                           _..LDHk_4normalize_mask.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_' num2str(Nvoxel, '%02d') 'LDHk_4normalize.nii.gz' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_' num2str(Nvoxel, '%02d') 'LDHk_4normalize_mask.nii.gz' ];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];