function [ FileOut ] = g_dismap_FileOut( NiiOutputPath )
%
% FileOut contains .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath filesep 'TBSS' filesep 'mean_FA.nii.gz' ];
FileOut{2} = [NiiOutputPath filesep 'TBSS' filesep 'mean_FA_mask.nii.gz' ];
FileOut{3} = [NiiOutputPath filesep 'TBSS' filesep 'mean_FA_skeleton.nii.gz' ];
FileOut{4} = [NiiOutputPath filesep 'TBSS' filesep 'mean_FA_skeleton_mask.nii.gz' ];
FileOut{5} = [NiiOutputPath filesep 'TBSS' filesep 'mean_FA_skeleton_mask_dst.nii.gz' ];