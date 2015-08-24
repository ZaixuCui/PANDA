function g_OPDtrackNET(bedpostx_folder, Label_seed_fileName, Label_term_fileName, targets_txt_fileName, JobName)
%
%__________________________________________________________________________
% SUMMARY OF G_OPDTRACKNET
% 
% probabilistic fiber tracking
%
% SYNTAX:
%
% 1) g_OPDtrackNET(bedpostx_folder, Label_seed_fileName, Label_term_fileName, targets_txt_fileName, JobName)
%__________________________________________________________________________
% INPUTS:
%
% BEDPOSTX_FOLDER
%        (string) 
%        The full path of the bedpostx result.
%
% LABEL_SEED_FILENAME
%        (string) 
%        The full path of the seed mask.
%
% LABEL_TERM_FILENAME
%        (string) 
%        The full path of the terminate mask.
%
% TARGETS_TXT_FILENAME
%        (string) 
%        A text file which contains all the target file path.
%__________________________________________________________________________
% OUTPUTS:
%
% See g_OPDtrackNET_..._FileOut.m file         
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: probtrackx
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

samples_basefileName = cat(2, bedpostx_folder, filesep, 'merged');
nodif_mask_fileName = cat(2, bedpostx_folder, filesep, 'nodif_brain_mask');

[output_dir, b, c] = fileparts(Label_seed_fileName);

probtrack_cmd = cat(2, 'probtrackx --mode=seedmask',...
    ' -l -c 0.2 -S 1000 --steplength=0.5 -P 5000',...
    ' --stop=',Label_term_fileName,...
    ' -x ', Label_seed_fileName,...
    ' --forcedir --os2t --opd --s2tastext',...
    ' --targetmasks=',targets_txt_fileName,...
    ' -s ', samples_basefileName,...
    ' -m ', nodif_mask_fileName,...
    ' --dir=', output_dir, ' && touch ', output_dir, filesep, JobName, '.done');

system(probtrack_cmd);


