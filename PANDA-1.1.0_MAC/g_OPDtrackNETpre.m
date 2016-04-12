function g_OPDtrackNETpre( Label_fileName, Label_vector, resultant_folder )
%
%__________________________________________________________________________
% SUMMARY OF G_OPDTRACKNETPRE
%
% pre-processing of probabilistic fiber tracking
%
% SYNTAX:
% G_OPDTRACKNETPRE( LABEL_FILENAME, LABEL_VECTOR, RESULTANT_FOLDER )
%__________________________________________________________________________
% INPUTS:
%
% LABEL_FILENAME
%        (string) the full path of the parcellated file of subject
%
% LABEL_VECTOR
%        (array) the ids of ROI which will be used as seed point
%
% RESULTANT_FOLDER
%        (string) the path of the tracking result
%__________________________________________________________________________
% OUTPUTS:
%
% See g_OPDtrackNETpre_..._FileOut.m file         
%__________________________________________________________________________
% USAGES:
%
%        1) g_OPDtrackNETpre( Label_fileName, Label_vector, resultant_folder )
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: pre-processing, probabilistic fiber tracking

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
if ~exist(resultant_folder)
    mkdir(resultant_folder);
end
disp(Label_fileName);
[a,b,c] = fileparts(Label_fileName);
if strcmp(c, '.gz')
    Label_fileName_mask = cat(2, resultant_folder, filesep, b(1:end-4), '_mask');
else
    Label_fileName_mask = cat(2, resultant_folder, filesep, b, '_mask');
end
system(cat(2, 'fslmaths ', Label_fileName, ' -bin ', Label_fileName_mask));
            
targets_txt_fileName = cat(2, resultant_folder,filesep,'Seed2Target.txt');
fid = fopen(targets_txt_fileName, 'w');
for i = 1:length(Label_vector)
    index = Label_vector(i);     
    output_dir = cat(2, resultant_folder, filesep, 'Label', num2str(index,'%02.0f'), '_OPDtrackNET');
    if ~exist(output_dir, 'dir')
        mkdir(output_dir); 
    end
    Label_seed_fileName{i,1} = cat(2, output_dir, filesep, 'Label', num2str(index,'%02.0f'), '_SeedMask');    
    Label_term_fileName{i,1} = cat(2, output_dir, filesep, 'Label', num2str(index,'%02.0f'), '_TermMask');
    disp(cat(2, 'generating masks for label of ', num2str(index,'%02.0f')));
    system(cat(2, 'fslmaths ', Label_fileName, ' -thr ', num2str(index), ' -uthr ', num2str(index), ' -div ', num2str(index), ' ', Label_seed_fileName{i,1}));
    system(cat(2, 'fslmaths ', Label_fileName_mask, ' -sub ', Label_seed_fileName{i,1}, ' ',Label_term_fileName{i,1}));    
    
    fprintf(fid, Label_seed_fileName{i,1});
    fprintf(fid, '\n');
end

