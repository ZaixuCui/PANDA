function [ FileOut ] = g_smoothNII_2_FileOut( NiiOutputPath,NumberOfSubject_String,dtifit_Prefix,kernel_size,Resolution )
%
% FileOut contain all the files' full path of the job smoothNII_2 output 
% 2 files will be produced: _MD_to_target_2mm_s6mm.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'standard_space' filesep dtifit_Prefix '_MD_4normalize_to_target_' num2str(Resolution) 'mm_s' num2str(kernel_size) 'mm.nii.gz' ];
