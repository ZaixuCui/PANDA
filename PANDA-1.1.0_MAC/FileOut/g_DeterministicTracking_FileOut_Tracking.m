function FileOut = g_DeterministicTracking_FileOut_Tracking( NativeFolderPath, Option, Prefix )
%G_TRACKING_FILEOUT_ALONE Summary of this function goes here
%   Detailed explanation goes here
[NativeParentFolderPath, b, c] = fileparts(NativeFolderPath);
FileOut{1} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_adc.nii.gz'];
FileOut{2} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_b0.nii.gz'];
FileOut{3} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_dwi.nii.gz'];
FileOut{4} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_e1.nii.gz'];
FileOut{5} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_e2.nii.gz'];
FileOut{6} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_e3.nii.gz'];
FileOut{7} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_exp.nii.gz'];
FileOut{8} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_fa.nii.gz'];
FileOut{9} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_fa_color.nii.gz'];
FileOut{10} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_tensor.nii.gz'];
FileOut{11} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_tracker.log'];
FileOut{12} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_v1.nii.gz'];
FileOut{13} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_v2.nii.gz'];
FileOut{14} = [NativeParentFolderPath filesep 'trackvis' filesep 'dti_v3.nii.gz'];
FileOut{15} = [NativeParentFolderPath filesep 'trackvis' filesep 'ForDTK_bvecs'];
FileOut{16} = [NativeParentFolderPath filesep 'trackvis' filesep Prefix '_dti_' Option.PropagationAlgorithm '_'];
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
if strcmp(Option.ApplySplineFilter, 'Yes')
    [a,b,c] = fileparts(FileOut{16});
    FileOut{17} = [ a filesep b '_S.trk'];
end


