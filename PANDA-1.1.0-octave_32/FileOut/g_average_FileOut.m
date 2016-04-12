function [ FileOut ] = g_average_FileOut( NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job average output 
% 4 files will be produced: bvals, bvecs, DWI.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_bvals_average'];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_bvecs_average'];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_0000_average.nii.gz'];
FileOut{4} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep 'data_b0_eddy.nii.gz'];
