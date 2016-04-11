function [ FileOut ] = g_DeterministicTracking_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,Option,Prefix )
%
% FileOut contain all the files' full path of the job BET_2 output 
% 3 files will be produced: nodif_brain.nii.gz, nodif_brain_mask.nii.gz, 
%                           .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_adc.nii.gz'];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_b0.nii.gz'];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_dwi.nii.gz'];
FileOut{4} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_e1.nii.gz'];
FileOut{5} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_e2.nii.gz'];
FileOut{6} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_e3.nii.gz'];
FileOut{7} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_exp.nii.gz'];
FileOut{8} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_fa.nii.gz'];
FileOut{9} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_fa_color.nii.gz'];
FileOut{10} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_tensor.nii.gz'];
FileOut{11} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_tracker.log'];
FileOut{12} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_v1.nii.gz'];
FileOut{13} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_v2.nii.gz'];
FileOut{14} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'dti_v3.nii.gz'];
FileOut{15} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep 'ForDTK_bvecs'];
FileOut{16} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep Prefix '_dti_' Option.PropagationAlgorithm '_'];
if ~strcmp(Option.PropagationAlgorithm, 'FACT')
    FileOut{16} = [FileOut{16} num2str(Option.StepLength) '_'];
else
    FileOut{16} = [FileOut{16} '_'];
end
FileOut{16} = [FileOut{16} Option.AngleThreshold '_' num2str(Option.MaskThresMin) '_' num2str(Option.MaskThresMax) ];
FileOut{16} = strrep(FileOut{16}, '.', '');
FileOut{16} = strrep(FileOut{16}, ' ', '');
FileOut{16} = strrep(FileOut{16}, '-', '');
FileOut{16} = [FileOut{16} '.trk'];
FileOut{17} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];
if strcmp(Option.ApplySplineFilter, 'Yes')
    [a,b,c] = fileparts(FileOut{16});
    FileOut{18} = [ a filesep b '_S.trk'];
end

