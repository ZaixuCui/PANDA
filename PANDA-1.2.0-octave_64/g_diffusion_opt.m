function dti_opt = g_diffusion_opt( diffusion_opt )   
%
% SUMMARY OF G_DIFFUSION_OPT
%
% Set values for dti_opt.
%
%-------------------------------------------------------------------------- 
%	Copyright(c) 2012
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui
%	Mail to Author:  zaixucui@gmail.com
%--------------------------------------------------------------------------

dti_opt.RawDataResample_Flag = diffusion_opt.RawDataResample_Flag;
if dti_opt.RawDataResample_Flag
    dti_opt.RawDataResampleResolution = diffusion_opt.RawDataResampleResolution;
end

dti_opt.Inversion = diffusion_opt.Inversion;
dti_opt.Swap = diffusion_opt.Swap;

% the start index of your ROI in time,default: 0
dti_opt.extractB0_1_reference = 0;
% fractional intensity threshold (0->1); default = 0.25; smaller values
% give larger brain outline estimates
dti_opt.BET_1_f = diffusion_opt.SkullRemoval_f;

dti_opt.Cropping_Flag = diffusion_opt.Cropping_Flag;
if dti_opt.Cropping_Flag
    % suffix_flag: (0 or 1)
    % 1: the name of the handled data will be the connection of the
    % original data and '_crop' as suffix
    % 0: the name of the handled data will be the same of the orignal data
    dti_opt.NIIcrop_suffix_flag = 1;
    % the length from the boundary of the brain to the cube we select
    dti_opt.NIIcrop_slice_gap = diffusion_opt.Cropping_gap;
end

dti_opt.extractB0_2_reference = 0;
dti_opt.BET_2_f = diffusion_opt.SkullRemoval_f;

% standard template for registering
dti_opt.FAnormalize_target = diffusion_opt.Normalizing_target;

% ref_fileName: (integer: 1 or 2)
% 1: FMRIB58_FA_1mm.nii.gz' as reference
%    i.e. resampling the data at 1x1x1mm resolution in MNI space
% 2: MNI152_T1_2mm.nii.gz' as reference
%    i.e. resampling the data at 2x2x2mm resolution in MNI space
dti_opt.applywarp_1_ref_fileName = 1;
dti_opt.applywarp_2_ref_fileName = diffusion_opt.Normalizing_resolution;
dti_opt.applywarp_3_ref_fileName = 1;
dti_opt.applywarp_4_ref_fileName = diffusion_opt.Normalizing_resolution;
dti_opt.applywarp_5_ref_fileName = 1;
dti_opt.applywarp_6_ref_fileName = diffusion_opt.Normalizing_resolution;
dti_opt.applywarp_7_ref_fileName = 1;
dti_opt.applywarp_8_ref_fileName = diffusion_opt.Normalizing_resolution;

% kernel size
dti_opt.smoothNII_1_kernel_size = diffusion_opt.Smoothing_kernel;
dti_opt.smoothNII_2_kernel_size = diffusion_opt.Smoothing_kernel;
dti_opt.smoothNII_3_kernel_size = diffusion_opt.Smoothing_kernel;
dti_opt.smoothNII_4_kernel_size = diffusion_opt.Smoothing_kernel;

% WM_Label_Atlas and WM_Probtract_Atlas
dti_opt.WM_Label_Atlas = diffusion_opt.WM_label_atlas;
dti_opt.WM_Probtract_Atlas = diffusion_opt.WM_probtract_atlas;

% Delete Flag
dti_opt.Delete_Flag = diffusion_opt.Delete_rawNII;

% TBSS Flag
dti_opt.TBSS_Flag = diffusion_opt.Applying_TBSS;

if diffusion_opt.Applying_TBSS == 1
    dti_opt.dismap_threshold = diffusion_opt.Skeleton_cutoff;
end



