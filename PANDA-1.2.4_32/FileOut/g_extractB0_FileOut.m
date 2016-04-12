function [ FileOut ] = g_extractB0_FileOut( JobName,NiiOutputPath,NumberOfSubject_String )
%
% FileOut contain all the files' full path of the job extractB0_1 output 
% 2 files will be produced: data_b0.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'data_b0.nii.gz' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];