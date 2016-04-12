
function [ FileOut ] = g_delete_tmp_file_FileOut( JobName,NiiOutputPath,NumberOfSubject_String )
%
% FileOut contains .done file is sign of the completion of the job
%

FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done'];
