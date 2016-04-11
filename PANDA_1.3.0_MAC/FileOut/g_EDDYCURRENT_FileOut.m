function [ FileOut ] = g_EDDYCURRENT_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,Quantity_Of_Sequence,RawDataResample_Flag,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job EDDYCURRENT output 
% 4 files will be produced: data.eccdone, data.ecclog, data.nii.gz, .done 
% .done file is sign of the completion of the job
%
for i = 1:Quantity_Of_Sequence
    if ~RawDataResample_Flag
        FileOut{i} =[NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(i,'%02.0f') '_0000_crop_eddy.nii.gz'];
    else
        FileOut{i} =[NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(i,'%02.0f') '_resample_0000_crop_eddy.nii.gz'];
    end
end
FileOut{i + 1} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep 'ecclog.mat' ];
FileOut{i + 2} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];