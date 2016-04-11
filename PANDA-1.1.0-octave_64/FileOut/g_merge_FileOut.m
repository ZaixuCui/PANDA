function [ FileOut ] = g_merge_FileOut( NiiOutputPath,NumberOfSubject_String )
%
% FileOut contain all the files' full path of the job merge output 
% 4 files will be produced: bvals, bvces, DWI.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep 'bvals' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep 'bvecs' ];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep 'data.nii.gz' ];
