function g_DeterministicTracking( NativeFolderPath, tracking_opt, Prefix )
%
%__________________________________________________________________________
% SUMMARY OF G_TRACKING
% 
% Deterministic fiber tracking
%
% SYNTAX:
% g_DeterministicTracking( NativeFolderPath, tracking_opt, Prefix )
%__________________________________________________________________________
% INPUTS:
%
% NATIVEFOLDERPATH
%       (string)
%       Full path of a folder containing four files as listed, if do 
%       deterministic fiber tracking, deterministic network construction 
%       and bedpostx & probabilistic network construction.
%       1) A 4D image named data.nii.gz containing diffusion-weighted 
%          volumes and volumes without diffusion weighting.
%       2) A 3D binary brain mask volume named nodif_brain_mask.nii.gz.
%       3) A text file named bvecs containing gradient directions for 
%          diffusion weighted volumes.
%       4) A text file named bvals containing b-values applied for each 
%          volume acquisition.
%
% TRACKING_OPT
%       (structure) with the following fields :
%
%        DeterminFiberTracking
%            (integer, 0 or 1, default 0)
%            1: Do deterministic fiber tracking.
%
%        ImageOrientation
%            (string, default 'Auto')
%            Four selections: 'Auto'
%                             'Axial'
%                             'Coronal'
%                             'Sagittal'.
%            
%        PropagationAlgorithm
%            (string, default 'FACT')
%            Four selections: 'FACT'
%                             '2nd-order Runge Kutta'
%                             'Interpolated Streamline'
%                             'Tensorline'.
%
%        StepLength
%            (float) 
%            Default 0.1 for '2nd-order Runge Kutta' & 'Tensorline'. 
%            Default 0.5 for 'Interpolated Streamline'.
%
%        AngleThreshold
%            (integer, default 35)
%            Stop tracking when the angle of the corner is larger than the
%            threshold.
%
%        MaskThresMin
%            (float, default 0.1)
%            The lower bound of FA threshold, tracking will be stopped if
%            FA is lower than this value.
%
%        MaskThresMax
%            (float, default 1)
%            The upper bound of FA threshold, tracking will be stopped if
%            FA is larger than this value.
%
%        Inversion
%            (string, default 'No Inversion')
%            Four selections: 'No Inversion'
%                             'Invert X'
%                             'Invert Y'
%                             'Invert Z'.
%
%        Swap
%            (string, default 'No Swap')
%            Four selections: 'No Swap' 
%                             'Swap X/Y'  
%                             'Swap Y/Z'
%                             'Swap Z/X'.
%
%        ApplySplineFilter
%            (string, 'Yes' or 'No', default 'Yes')
%            'Yes' : Apply apline filter.
%            Select whether to smooth & clean up the original track file.       
%
% PREFIX
%       (string)
%       The prefix of the resultant files.
%__________________________________________________________________________
% OUTPUTS:
%
% A folder named trackvis containing deterministic fiber tracking results.
% See g_DeterministicTracking_FileOut.
%__________________________________________________________________________
% COMMENTS:
% 
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Suyu Zhong, Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% See licensing information in the code
% keywords: reconstruct, tracking
% Please report bugs or requests to:
%   Zaixu Cui:         <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%   Suyu Zhong:        <a href="suyu.zhong@gmail.com">suyu.zhong@gmail.com</a>
%   Gaolang Gong (PI): <a href="gaolang.gong@gmail.com">gaolang.gong@gmail.com</a>

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

if strcmp( tracking_opt.ImageOrientation, 'Axial')
    Recon_Option.img_orient_patient = 'axial';
elseif strcmp( tracking_opt.ImageOrientation, 'Coronal')
    Recon_Option.img_orient_patient = 'cor';
elseif strcmp( tracking_opt.ImageOrientation, 'Sagittal')
    Recon_Option.img_orient_patient = 'sag';
else
    Recon_Option.img_orient_patient = '';
end

g_dtiRecon(NativeFolderPath,Recon_Option)

if strcmp( tracking_opt.PropagationAlgorithm, 'FACT')
    Tracker_Option.Track.Method = 'fact';
elseif strcmp( tracking_opt.PropagationAlgorithm, '2nd-order Runge Kutta')
    Tracker_Option.Track.Method = 'rk2';
elseif strcmp( tracking_opt.PropagationAlgorithm, 'Interpolated Streamline')
    Tracker_Option.Track.Method = 'sl';
elseif strcmp( tracking_opt.PropagationAlgorithm, 'Tensorline')
    Tracker_Option.Track.Method = 'tl';
end

if ~isfield(tracking_opt, 'StepLength')
    Tracker_Option.Track.step_length = '';
else
    Tracker_Option.Track.step_length = tracking_opt.StepLength;
end

Tracker_Option.Angle_tresh = tracking_opt.AngleThreshold;

Tracker_Option.Mask_threshold(1) = tracking_opt.MaskThresMin;
Tracker_Option.Mask_threshold(2) = tracking_opt.MaskThresMax;

if strcmp( tracking_opt.Inversion, 'Invert X' )
    Tracker_Option.Invert_flag(1,1) = 1;
    Tracker_Option.Invert_flag(1,2) = 0;
    Tracker_Option.Invert_flag(1,3) = 0;
elseif  strcmp( tracking_opt.Inversion, 'Invert Y' )
    Tracker_Option.Invert_flag(1,1) = 0;
    Tracker_Option.Invert_flag(1,2) = 1;
    Tracker_Option.Invert_flag(1,3) = 0;
elseif  strcmp( tracking_opt.Inversion, 'Invert Z' )
    Tracker_Option.Invert_flag(1,1) = 0;
    Tracker_Option.Invert_flag(1,2) = 0;
    Tracker_Option.Invert_flag(1,3) = 1;
end

if strcmp( tracking_opt.Swap, 'Swap X/Y' )
    Tracker_Option.Swap_flag.sxy = 1;
elseif strcmp( tracking_opt.Swap, 'Swap Y/Z' )
    Tracker_Option.Swap_flag.syz = 1;
elseif strcmp( tracking_opt.Swap, 'Swap Z/X' ) 
    Tracker_Option.Swap_flag.szx = 1;
end

if strcmp( tracking_opt.ApplySplineFilter, 'Yes' )
    Tracker_Option.Spline_filter.on = '1';
else
    Tracker_Option.Spline_filter.on = '0';
end

g_tracker(NativeFolderPath,Tracker_Option,tracking_opt,Prefix)



function g_dtiRecon(NativeFolderPath,Option)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program will reconstruct raw data to a set of images,such as tensor images, DWI, ADC and FA maps.
%
%   SYNTAX:
%   G_DTIRECON(SubjectFolderPath,Option)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   INPUTS:
%   FILENAME
%      (string)the full path of the raw data with the end of delimiter.   
%   Option:
%   Option.output_type(default 'nii')
%	Option.img_orient_patient(default auto,mean read from the header file of the raw data)
%	Option.oblique_correction(default oblique_correction is not need.
%                             When oblique angle(s) applied,some SIEMENS dti protocols do not adjust gradient accordingly,
%                             thus it requires adjustmet for correct diffusion tensor calculation)
%	Option.b0_threshold(default auto)
%	Option.Unoutput.eigen(default ' ',means <prefix>_eigen files are saved)
%	Option.Unoutput.tensor(default ' ',means <prefix>_tensor file is saved)
%	Option.Unoutput.exp(default ' ',means <prefix>_exp files is saved)
%	Option.output_5d(default' ',means outputmulti-frame(4D) niff file)
%		
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OUTPUTS:
%    13 files will be produced.
%    <Prefix>_adc      - Apparent Diffusion Coefficent(ADC) map
%    <Prefix>_b0       - Averaged low b(b0) map
%    <Prefix>_dwi      - Diffusion weighted Imaging map.
%    <Prefix>_V1       - 1st eigenvector
%    <Prefix>_V2       - 2nd eigenvector
%    <Prefix>_V3       - 3rd eigenvector
%    <Prefix>_e1       - 1st eigenvalue
%    <Prefix>_e2       - 2nd eigenvalue
%    <Prefix>_e3       - 3rd eigenvalue
%    <Prefix>_exp      -
%    <Prefix>_fa_color - color Fractional Anisotropy(FA) map
%    <Prefix>_fa       - fractional anisotropy(FA) MAP 
%    <Prefix>_tensor   - Diffusion tensor data.There will not be <prefix>_tensor,if Option.no_exp_output is on.
%                      A 5D nifti file with 1 time point (the 4th dimension) and the 5th dimension size as 6 
%                      (6 elements of a diffusion tensor matrix). 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author  Suyu Zhong
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));

[SubjectFolderPath, b, c] = fileparts(NativeFolderPath);
if nargin == 1
	Option.output_type = 'nii.gz';
   	Option.img_orient_patient = '';
	Option.oblique_correction = '';
	Option.b0_threshold = [' ',' ']';
	Option.Unoutput.eighen = '';
	Option.Unoutput.exp = '';
	Option.output_5d = '';
	Option.help = ' ';
end
if nargin == 2
    if ~isfield(Option,'output_type'),Option.output_type = 'nii.gz';
    end

    if ~isfield(Option,'img_orient_patient'),Option.img_orient_patient = '';
    elseif strcmp(Option.img_orient_patient,'sag');Option.img_orient_patient = ' -iop 0 1 0 0 -1 0 ';
    elseif strcmp(Option.img_orient_patient,'cor');Option.img_orient_patient = ' -iop 1 0 0 0 0 -1 ';
    elseif strcmp(Option.img_orient_patient,'axial');Option.img_orient_patient = ' -iop 1 0 0 0 1 0 ';
    end

    if ~isfield(Option,'oblique_correction');Option.oblique_correction = '';
    else Option.oblique_correction = ' -oc ';
    end

    if ~isfield(Option,'b0_threshold');Option.b0_threshold = [' ',' ']';
    else Option.b0_threshold = num2str(Option.b0_threshold');
    end

    if ~isfield(Option,'Unoutput');Option.Unoutput.exp = '';Option.Unoutput.tensor = '';Option.Unoutput.eighen = '';
    elseif isfield(Option.Unoutput,'eighen');Option.Unoutput.eighen =' -no_eigen ';Option.Unoutput.tensor ='';Option.Unoutput.exp ='';     
    elseif isfield(Option.Unoutput,'exp');Option.Unoutput.exp =' -no_exp ';Option.Unoutput.eighen ='';Option.Unoutput.tensor ='';
    end

    if ~isfield(Option,'output_5d');Option.output_5d = '';
    else Option.output_5d = ' -output_5d ';
    end
end

if strcmp(SubjectFolderPath(end),'/')
    Track_Folder = cat(2,SubjectFolderPath,'trackvis');
else
    Track_Folder = cat(2,SubjectFolderPath,'/trackvis');
end

if ~exist(Track_Folder) 
    mkdir(Track_Folder)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ForDTKBVector_filename = fullfile(Track_Folder,'ForDTK_bvecs');
disp(['The resulted b vector file for DTK has been saved as: ' ForDTKBVector_filename ]);
if exist (ForDTKBVector_filename)
   delete(ForDTKBVector_filename)
end

Bvec = load(fullfile(NativeFolderPath,'bvecs'));
Bvec = Bvec';
Bval = load(fullfile(NativeFolderPath,'bvals'));
Bval = Bval';
fid = fopen(ForDTKBVector_filename,'a+');
for j = 1:size(Bvec,1)
    fprintf(fid,'%2.4f%s%2.4f%s%2.4f%s%2.4f\n',Bvec(j,1),', ',Bvec(j,2),', ',Bvec(j,3), ', ',Bval(j,1));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Raw_data_filename = fullfile(NativeFolderPath,'data.nii.gz');
Output_File_Prefix = fullfile(Track_Folder,'dti'); 
DTKBvecs = fullfile(SubjectFolderPath,'trackvis','ForDTK_bvecs');
system(['chmod +x ' PANDAPath filesep 'diffusion_toolkit' filesep 'dti_recon']);
cmd = cat(2,PANDAPath,filesep,'diffusion_toolkit',filesep,'dti_recon ', Raw_data_filename,' ',Output_File_Prefix,' -gm ',DTKBvecs,' -ot ',...
        Option.output_type,' ',Option.img_orient_patient,Option.oblique_correction,...
        '-b0_th ',Option.b0_threshold(1,:),' ',Option.b0_threshold(2,:), Option.Unoutput.eighen,... 
     	Option.Unoutput.exp,Option.output_5d);
disp(cmd);
system(cmd);


function g_tracker(NativeFolderPath,Option,tracking_opt,Prefix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program will perform fiber tracking from the reconstructed
%   tensor and maps by g_ditRecon and output a track file with '.trk'
%   as a suffix.
%   SYNTAX:
%   G_TRACKER(SubjectFolderPath,Option)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   INPUTS:
%   SubjectFolderPath
%       (string)the full path of the raw analyze image used to reconstruct tensor.
%   OPTION:
%       Option.Track.
%       Option.Track.Method(There are four methods.fact,rk2,tl,sl.)
%       Option.Track.step_length(set step length for each track method, in the unit of munimum voxel size. default value is 0.5 for interpokated streamline method and 0.1 for other methods)
%   	
%       Option.Angle_tresh(set angle threshold.default value is 35 degree)
%       Option.Num_RandSeed(default is 1)
%       
%       Option.Invert_flag(the syntax is 1X3 matrix. For example,if you want to invert y direction,input the [0 1 0] to the Option.Invert_flag)
%   	Option.Invert_flag.X
%   	Option.Invert_flag.Y
%   	Option.Invert_flag.Z
%       Option.Swap_flag='';
%       Option.Swap_flag.sxy='';
%       Option.Swap_flag.syz='';
%       Option.Swap_flag.szx='';
%       Option.Mask_threshold=[0.1 1];
%       
%       Option.Spline_filter
%       Option.Spline_filter.on='on';(default is on,meaning to do spline filter which is to smooth and clean up the original track file genetrated by dti tracker)
%       Option.Spline_filter.step_length=' 0.5 '(default is 0.5.The step length for spline filter is in the unit of minimum voxel size)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OUTPUTS:
%     The track file with '.trk' as a suffix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author  Suyu Zhong 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PANDAPath;
[PANDAPath, y, z] = fileparts(which('PANDA.m'));

[SubjectFolderPath, b, c] = fileparts(NativeFolderPath);
if nargin==1
   	Option.Track.Method='-fact';
   	Option.Track.step_length='';
	Option.Angle_tresh='35';
    Option.Num_Randseed=' 1 ';
    Option.Invert_flag='';
    Option.Invert_flag_X='';
    Option.Invert_flag_Y='';
    Option.Invert_flag_Z='';
    Option.Swap_flag='';
    Option.Swap_flag.sxy='';
    Option.Swap_flag.syz='';
    Option.Swap_flag.szx='';
    Option.Mask_threshold=[0.1 1];
    Option.Spline_filter.step_length=' 0.5 ';%Spline_filter step length
    Option.Spline_filter.on='1';
end

if nargin>=2
    
    if ~isfield(Option,'Track');Option.Track.Method=' -fact ';Option.Track.step_length='';
    else if isfield(Option.Track,'step_length') && isfield(Option.Track,'Method')
           if strcmp(Option.Track.Method,'fact');Option.Track.Method=' -fact ';Option.Track.step_length='';
           elseif strcmp(Option.Track.Method,'rk2'); Option.Track.Method=' -rk2 ';
           elseif strcmp(Option.Track.Method,'tl'); Option.Track.Method=' -tl ';
           elseif strcmp(Option.Track.Method,'sl'); Option.Track.Method=' -sl ';
           else disp('The Track_Method is wrong! The fact method will be used!');
                Option.Track.Method=' -fact ';Option.Track.step_length='';
           end
               
        elseif isfield(Option.Track,'step_length');
              disp('The default fact method will be used.The step length is inconstant!');
              Option.Track.step_length='';Option.Track.Method=' -fact ';
           
        
        elseif isfield(Option.Track,'Method');
             if strcmp(Option.Track.Method,'fact');Option.Track.Method=' -fact ';Option.Track.step_length='';
             elseif strcmp(Option.Track.Method,'rk2'); Option.Track.Method=' -rk2 ';Option.Track.step_length=' 0.1 ';
             elseif strcmp(Option.Track.Method,'tl'); Option.Track.Method=' -tl ';Option.Track.step_length=' 0.1 ';
             elseif strcmp(Option.Track.Method,'sl'); Option.Track.Method=' -sl ';Option.Track.step_length=' 0.5 ';
             else  disp('The Track_Method is wrong! The fact method will be used!The step length is inconstant!');
                   Option.Track.Method=' -fact ';Option.Track.step_length='';
            end
        end
    end
    
            
  
   if ~isfield(Option,'Angle_tresh'), Option.Angle_tresh='35';  end
   
   if ~isfield(Option,'Num_Randseed'),Option.Num_Randseed='1';end
   
   if ~isfield(Option,'Invert_flag'),Option.Invert_flag_X='';Option.Invert_flag_Y='';Option.Invert_flag_Z='';
   else   Option.Invert_flag_X='';Option.Invert_flag_Y='';Option.Invert_flag_Z='';
           if Option.Invert_flag(1,1) == 1,Option.Invert_flag_X=' -ix ';end
           if Option.Invert_flag(1,2) == 1,Option.Invert_flag_Y=' -iy ';end
           if Option.Invert_flag(1,3) == 1,Option.Invert_flag_Z=' -iz ';end
          
   end
   
   if ~isfield(Option,'Swap_flag'),Option.Swap_flag.syz='';Option.Swap_flag.szx='';Option.Swap_flag.sxy='';
   elseif isfield(Option.Swap_flag,'sxy');Option.Swap_flag.sxy=' -sxy ';Option.Swap_flag.syz='';Option.Swap_flag.szx='';
   elseif isfield(Option.Swap_flag,'syz'),Option.Swap_flag.syz=' -syz ';Option.Swap_flag.sxy='';Option.Swap_flag.szx='';
   elseif isfield(Option.Swap_flag,'szx'),Option.Swap_flag.szx=' -szx ';Option.Swap_flag.syz='';Option.Swap_flag.sxy='';
   end
   
   if ~isfield(Option,'Mask_threshold'),Option.Mask_threshold=[0.1 1];end
   
   if ~isfield(Option,'Spline_filter'),Option.Spline_filter.on='1';Option.Spline_filter.step_length='0.5';
   elseif ~isfield(Option.Spline_filter,'step_length'),Option.Spline_filter.step_length='0.5';
   else if ~isfield(Option.Spline_filter,'on'),Option.Spline_filter.on='1';
       elseif strcmp(Option.Spline_filter.on,'1'),Option.Spline_filter.on='0';end
   end
end

if strcmp(SubjectFolderPath(end),'/');
     Track_Folder=cat(2,SubjectFolderPath,filesep,'trackvis');
     Mask1=cat(2,NativeFolderPath,filesep,'nodif_brain_mask.nii.gz');
     Mask2=cat(2,SubjectFolderPath,filesep,'trackvis','/dti_fa.nii');
else Track_Folder=cat(2,SubjectFolderPath,'/trackvis');
     Mask1=cat(2,NativeFolderPath,filesep,'nodif_brain_mask.nii.gz');
     Mask2=cat(2,SubjectFolderPath,'/trackvis','/dti_fa.nii');
end

Input_Data_Perfix=cat(2,Track_Folder,'/dti ');
if nargin == 4
    Output_Filename = [SubjectFolderPath filesep 'trackvis' filesep Prefix '_dti_' tracking_opt.PropagationAlgorithm '_'];
    if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT')
        Output_Filename = [Output_Filename num2str(tracking_opt.StepLength) '_'];
    else
        Output_Filename = [Output_Filename '_'];
    end
    Output_Filename = [Output_Filename num2str(tracking_opt.AngleThreshold) '_' num2str(tracking_opt.MaskThresMin) '_' num2str(tracking_opt.MaskThresMax)];
    % Delete '.' in the name of the .trk file
    Output_Filename = strrep(Output_Filename, '.', '');
    Output_Filename = strrep(Output_Filename, ' ', '');
    Output_Filename = strrep(Output_Filename, '-', '');
    Output_Filename = [Output_Filename '.trk'];
else
    Output_Filename = cat(2,Track_Folder,'/dti.trk ');
end

system(['chmod +x ' PANDAPath filesep 'diffusion_toolkit' filesep 'dti_tracker']);
if ~strcmp(tracking_opt.PropagationAlgorithm, 'FACT')
    cmd = cat(2,PANDAPath,filesep,'diffusion_toolkit',filesep,'dti_tracker ', Input_Data_Perfix,Output_Filename,Option.Track.Method, ' -l ', num2str(Option.Track.step_length),...
           ' -at ', num2str(Option.Angle_tresh) ,' -rseed ',Option.Num_Randseed, Option.Invert_flag_X,Option.Invert_flag_Y,...
           Option.Invert_flag_Z,Option.Swap_flag.sxy,Option.Swap_flag.syz,Option.Swap_flag.szx,' -m ', Mask1,' -m2 ',Mask2,' ',...
           num2str(Option.Mask_threshold(1,1)),' ',num2str(Option.Mask_threshold(1,2)));
else
    cmd = cat(2,PANDAPath,filesep,'diffusion_toolkit',filesep, 'dti_tracker ', Input_Data_Perfix,Output_Filename,Option.Track.Method, ...
           ' -at ', num2str(Option.Angle_tresh) ,' -rseed ',Option.Num_Randseed, Option.Invert_flag_X,Option.Invert_flag_Y,...
           Option.Invert_flag_Z,Option.Swap_flag.sxy,Option.Swap_flag.syz,Option.Swap_flag.szx,' -m ', Mask1,' -m2 ',Mask2,' ',...
           num2str(Option.Mask_threshold(1,1)),' ',num2str(Option.Mask_threshold(1,2)));
end
disp(cmd);
print = ['system(''' cmd ''')'];
disp(print);
system(cmd);

if strcmp(Option.Spline_filter.on,'1')
    system(['chmod +x ' PANDAPath filesep 'diffusion_toolkit' filesep 'spline_filter']);
    [a,b,c] = fileparts(Output_Filename);
    Output_Filename_spline = cat(2, a, filesep, b, '_S.trk');
    cmd = cat(2,PANDAPath,filesep,'diffusion_toolkit',filesep,'spline_filter ',Output_Filename,' ',Option.Spline_filter.step_length,' ',Output_Filename_spline);
    disp(cmd);
    system(cmd);
end

