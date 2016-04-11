function [ FileOut ] = g_dcm2nii_dwi_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,QuantityOfSequence,dtifit_Prefix )
%
% FileOut contain all the files' full path of the g_dcm2nii_dwi output 
% (3 * QuantityOfSequence + 1) files will be produced.
% For each sequence, three files: bvals, bvecs, DWI.nii.gz
% .done file is sign of the completion of the job
%
for i = 1:QuantityOfSequence
    j = (i - 1) * 3;
    FileOut{j + 1} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_bvals_' num2str(i,'%02.0f')];
    FileOut{j + 2} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_bvecs_' num2str(i,'%02.0f')];
    FileOut{j + 3} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep dtifit_Prefix '_DWI_' num2str(i,'%02.0f') '.nii.gz'];
end
FileOut{j + 4} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done'];


        