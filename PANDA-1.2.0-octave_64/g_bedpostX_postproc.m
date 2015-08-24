function g_bedpostX_postproc( BedpostxFolder, Fibers )
%
%__________________________________________________________________________
% SUMMARY OF G_BEDPOSTX_POSTPROC
% 
% The post-processing of the bedpostx
%
% SYNTAX:
% 1) g_bedpostX_postproc( BedpostxFolder, Fibers )
%__________________________________________________________________________
% INPUTS:
%
% BEDPOSTXFOLDER
%        (string) 
%        The full path of folder which stores bedpostx results.
%
% FIBERS
%        (integer, default 2) 
%        Number of fibers per voxel.
%
%__________________________________________________________________________
% OUTPUTS:
%     
% See g_bedpostX_postproc_FileOut.m file.
%__________________________________________________________________________
% COMMENTS:
%
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: bedpostx, post-processing
% Please report bugs or requests to:
%   Zaixu Cui:            zaixucui@gmail.com
%   Suyu Zhong:           suyu.zhong@gmail.com
%   Gaolang Gong (PI):    gaolang.gong@gmail.com

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

for i = 1:Fibers
    cmd = ['fslmerge -z ' BedpostxFolder filesep 'merged_th' num2str(i) ...
          'samples `imglob ' BedpostxFolder filesep 'diff_slices' filesep ...
          'data_slice_*' filesep 'th' num2str(i)  'samples*` && touch ' ...
          BedpostxFolder filesep 'diff_slices' filesep 'th.done'];
    system(cmd);
    
    cmd = ['fslmerge -z ' BedpostxFolder filesep 'merged_ph' num2str(i) ...
          'samples `imglob ' BedpostxFolder filesep 'diff_slices' filesep ...
          'data_slice_*' filesep 'ph' num2str(i)  'samples*` && touch ' ...
          BedpostxFolder filesep 'diff_slices' filesep 'ph.done'];
    system(cmd);
    
    cmd = ['fslmerge -z ' BedpostxFolder filesep 'merged_f' num2str(i) ...
          'samples `imglob ' BedpostxFolder filesep 'diff_slices' filesep ...
          'data_slice_*' filesep 'f' num2str(i)  'samples*` && touch ' ...
          BedpostxFolder filesep 'diff_slices' filesep 'f.done'];
    system(cmd);
    
    cmd = ['fslmaths ' BedpostxFolder filesep 'merged_th' num2str(i) ...
          'samples -Tmean ' BedpostxFolder filesep 'mean_th' num2str(i) ...
          'samples && touch ' BedpostxFolder filesep 'diff_slices' ...
          filesep 'th_mean.done'];
    system(cmd);
    
    cmd = ['fslmaths ' BedpostxFolder filesep 'merged_ph' num2str(i) ...
          'samples -Tmean ' BedpostxFolder filesep 'mean_ph' num2str(i) ...
          'samples && touch ' BedpostxFolder filesep 'diff_slices' ...
          filesep 'ph_mean.done'];
    system(cmd);
    
    cmd = ['fslmaths ' BedpostxFolder filesep 'merged_f' num2str(i) ...
          'samples -Tmean ' BedpostxFolder filesep 'mean_f' num2str(i) ...
          'samples && touch ' BedpostxFolder filesep 'diff_slices' ...
          filesep 'f_mean.done'];
    system(cmd);
    
    cmd = ['make_dyadic_vectors ' BedpostxFolder filesep 'merged_th' num2str(i) ...
          'samples ' BedpostxFolder filesep 'merged_ph' num2str(i) 'samples ' ...
          BedpostxFolder filesep 'nodif_brain_mask ' BedpostxFolder filesep ...
          'dyads' num2str(i) ' && touch ' BedpostxFolder filesep 'diff_slices' ...
          filesep 'dyads.done'];
    system(cmd);
end

Done{1} = [BedpostxFolder filesep 'diff_slices' filesep 'th.done'];
Done{2} = [BedpostxFolder filesep 'diff_slices' filesep 'ph.done'];
Done{3} = [BedpostxFolder filesep 'diff_slices' filesep 'f.done'];
Done{4} = [BedpostxFolder filesep 'diff_slices' filesep 'th_mean.done'];
Done{5} = [BedpostxFolder filesep 'diff_slices' filesep 'ph_mean.done'];
Done{6} = [BedpostxFolder filesep 'diff_slices' filesep 'f_mean.done'];
Done{7} = [BedpostxFolder filesep 'diff_slices' filesep 'dyads.done'];

DoneFileQuantity = 7;
if exist([BedpostxFolder filesep 'diff_slices' filesep 'data_slice_0000' filesep 'mean_dsamples.nii.gz'], 'file')
    cmd = ['fslmerge -z ' BedpostxFolder filesep 'mean_dsamples ' ...
          '`imglob ' BedpostxFolder filesep 'diff_slices' filesep 'data_slice_*' ...
          filesep 'mean_dsamples*` && touch ' BedpostxFolder filesep 'diff_slices' ...
          filesep 'dsample_mean.done'];
    system(cmd);
    DoneFileQuantity = DoneFileQuantity + 1;
    Done{DoneFileQuantity} = [BedpostxFolder filesep 'diff_slices' filesep 'dsample_mean.done'];
    BedpostxDone = 1;
    for i = 1:DoneFileQuantity
        if ~exist(Done{i}, 'file')
           BedpostxDone = 0; 
           break;
        end
    end
    disp('BedpostxDone');
    disp(BedpostxDone);
    if exist([BedpostxFolder filesep 'diff_slices'], 'dir') && BedpostxDone
        system(['rm -rf ' BedpostxFolder filesep 'diff_slices && touch ' ...
           BedpostxFolder filesep 'BedpostX.done']);
    end
end

if exist([BedpostxFolder filesep 'diff_slices' filesep 'data_slice_0000' filesep 'mean_d_stdsamples.nii.gz'], 'file')
    cmd = ['fslmerge -z ' BedpostxFolder filesep 'mean_d_stdsamples ' ...
          '`imglob ' BedpostxFolder filesep 'diff_slices' filesep 'data_slice_*' ...
          filesep 'mean_d_stdsamples*` && touch ' BedpostxFolder filesep 'diff_slices' ...
          filesep 'stdsample_mean.done'];
    disp(cmd);
    system(cmd);
    DoneFileQuantity = DoneFileQuantity + 1;
    Done{DoneFileQuantity} = [BedpostxFolder filesep 'diff_slices' filesep 'stdsample_mean.done'];
    BedpostxDone = 1;
    for i = 1:DoneFileQuantity
        if ~exist(Done{i}, 'file')
           BedpostxDone = 0; 
           break;
        end
    end
    if exist([BedpostxFolder filesep 'diff_slices'], 'dir') && BedpostxDone
        system(['rm -rf ' BedpostxFolder filesep 'diff_slices && touch ' ...
           BedpostxFolder filesep 'BedpostX.done']);
    end
end


