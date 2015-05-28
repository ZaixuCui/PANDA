function [ FileOut ] = g_NIIcrop_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,Quantity_Of_Sequence,NIIcrop_suffix_flag,RawDataResample_Flag,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job NIIcrop output 
% 2 files will be produced: DWI_crop.nii.gz, .done 
% .done file is sign of the completion of the job
%
% if NIIcrop_suffix_flag == 1

% The output file of NIIcrop
for i = 1:Quantity_Of_Sequence
    if ~RawDataResample_Flag
        FileOut{i} =[NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(i,'%02.0f') '_0000_crop.nii.gz'];
    else
        FileOut{i} =[NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(i,'%02.0f') '_resample_0000_crop.nii.gz'];
    end
end

FileOut{i + 1} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];
