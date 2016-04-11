function dti_opt = g_dti_opt( dti_opt )   
%
%__________________________________________________________________________
% SUMMARY OF G_DTI_OPT
%
% Set value for parameters in DTI data process
%
% SYNTAX:
%
% 1) g_dti_opt( ) 
% 2) g_dti_opt( dti_opt ) 
%__________________________________________________________________________
% INPUTS:
%        The structure consists of data user defines
%__________________________________________________________________________
% OUTPUTS:
%        The structure consists of data user defines and defaults. The
%        fields which user doesn't define will use default value.       
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: optional parameters

% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documation files, to deal in the
% Software without restriction, including without limitation the rights to
% use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.  

% All the parameters will use default values
global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));

if nargin == 0
        
    % the start index of your ROI in time,default: 0
    dti_opt.extractB0_1_reference = 0;     
    % fractional intensity threshold (0->1); default = 0.25; smaller values
    % give larger brain outline estimates
    dti_opt.BET_1_f = 0.25;
        
    % suffix_flag: (0 or 1)
    % 1: the name of the handled data will be the connection of the 
    % original data and '_crop' as suffix       
    % 0: the name of the handled data will be the same of the orignal data       
    dti_opt.NIIcrop_suffix_flag = 1;
    % the length from the boundary of the brain to the cube we select  
    dti_opt.NIIcrop_slice_gap = 3;
        
    dti_opt.extractB0_2_reference = 0;
    dti_opt.BET_2_f = 0.25;
    
    % standard template for registering
    dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
        
    % ref_fileName: (integer: 1 or 2)
    % 1: FMRIB58_FA_1mm.nii.gz' as reference
    %    i.e. resampling the data at 1x1x1mm resolution in MNI space
    % 2: MNI152_T1_2mm.nii.gz' as reference
    %    i.e. resampling the data at 2x2x2mm resolution in MNI space
    dti_opt.applywarp_1_ref_fileName = 1;
    dti_opt.applywarp_2_ref_fileName = 2;
    dti_opt.applywarp_3_ref_fileName = 1;
    dti_opt.applywarp_4_ref_fileName = 2;
    dti_opt.applywarp_5_ref_fileName = 1;
    dti_opt.applywarp_6_ref_fileName = 2;
    dti_opt.applywarp_7_ref_fileName = 1;
    dti_opt.applywarp_8_ref_fileName = 2;
       
    % kernel size 
    dti_opt.smoothNII_1_kernel_size = 6;
    dti_opt.smoothNII_2_kernel_size = 6;
    dti_opt.smoothNII_3_kernel_size = 6;
    dti_opt.smoothNII_4_kernel_size = 6;
    
    % WM_Label_Atlas and WM_Probtract_Atlas
    dti_opt.WM_Label_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'];
    dti_opt.WM_Probtract_Atlas = [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'];
    
    % Delete Flag
    dti_opt.Delete_Flag = 1;
    
    % TBSS Flag
    dti_opt.TBSS_Flag = 0;
    
    % LDH Flag
    dti_opt.LDH_Flag = 1;
    dti_opt.LDH_Neighborhood = 7;
        
end
 
% The parameter user doesn't define will use default value
if nargin == 1
        
    if ~isfield(dti_opt,'extractB0_1_reference'),dti_opt.extractB0_1_reference = 0;end;
        
    if ~isfield(dti_opt,'BET_1_f'),dti_opt.BET_1_f = 0.25;end;
        
    if ~isfield(dti_opt,'NIIcrop_suffix_flag'),dti_opt.NIIcrop_suffix_flag = 1;end;
        
    if ~isfield(dti_opt,'NIIcrop_slice_gap'),dti_opt.NIIcrop_slice_gap = 3;end;
        
    if ~isfield(dti_opt,'extractB0_2_reference'),dti_opt.extractB0_2_reference = 0;end;
        
    if ~isfield(dti_opt,'BET_2_f'),dti_opt.BET_2_f = 0.25;end;
    
    if ~isfield(dti_opt,'FAnormalize_target')
        dti_opt.FAnormalize_target = [PANDAPath filesep 'data' filesep 'Templates' filesep 'FMRIB58_FA_1mm.nii.gz'];
    end
        
    if ~isfield(dti_opt,'applywarp_1_ref_fileName'),dti_opt.applywarp_1_ref_fileName = 1;end;
        
    if ~isfield(dti_opt,'applywarp_2_ref_fileName'),dti_opt.applywarp_2_ref_fileName = 2;end;
        
    if ~isfield(dti_opt,'applywarp_3_ref_fileName'),dti_opt.applywarp_3_ref_fileName = 1;end;
        
    if ~isfield(dti_opt,'applywarp_4_ref_fileName'),dti_opt.applywarp_4_ref_fileName = 2;end;
        
    if ~isfield(dti_opt,'applywarp_5_ref_fileName'),dti_opt.applywarp_5_ref_fileName = 1;end;
        
    if ~isfield(dti_opt,'applywarp_6_ref_fileName'),dti_opt.applywarp_6_ref_fileName = 2;end;
        
    if ~isfield(dti_opt,'applywarp_7_ref_fileName'),dti_opt.applywarp_7_ref_fileName = 1;end;
        
    if ~isfield(dti_opt,'applywarp_8_ref_fileName'),dti_opt.applywarp_8_ref_fileName = 2;end;
        
    if ~isfield(dti_opt,'smoothNII_1_kernel_size'),dti_opt.smoothNII_1_kernel_size = 6;end;
        
    if ~isfield(dti_opt,'smoothNII_2_kernel_size'),dti_opt.smoothNII_2_kernel_size = 6;end;
        
    if ~isfield(dti_opt,'smoothNII_3_kernel_size'),dti_opt.smoothNII_3_kernel_size = 6;end;
        
    if ~isfield(dti_opt,'smoothNII_4_kernel_size'),dti_opt.smoothNII_4_kernel_size = 6;end;
    
    if ~isfield(dti_opt,'Delete_Flag'),dti_opt.Delete_Flag = 1;end;
    
    if ~isfield(dti_opt,'TBSS_Flag'),dti_opt.TBSS_Flag = 0;end;
    
    if ~isfield(dti_opt, 'LDH_Flag'),dti_opt.LDH_Flag = 1;dti_opt.LDH_Neighborhood = 7;end;
    
    if ~isfield(dti_opt, 'LDH_Neighborhood'), dti_opt.LDH_Neighborhood = 7;end;
end