function g_track4NETpost_fdt(Label_seed_fileCell,Label_fdt_fileCell,Prefix)
%
%__________________________________________________________________________
% SUMMARY OF G_TRACK4NETPOST_FDT( LABEL_SEED_FILECELL, LABEL_FDT_FILECELL )
% 
% Construct network with the result of probabilistic fiber tracking results
%
% SYNTAX:
% G_TRACK4NET_FDT( LABEL_SEED_FILECELL, LABEL_FDT_FILECELL )
%__________________________________________________________________________
% INPUTS:
%
% LABEL_SEED_FILECELL
%        (cell of string) 
%        member of the cell is seed file in probabilistic tracking
%
% LABEL_FDT_FILECELL
%        (cell of string)
%        member of the cell is fdt_paths.nii.gz in the probabilistic 
%        tracking results 
%__________________________________________________________________________
% OUTPUTS:
%
% See g_track4NETpost_fdt_..._FileOut.m file         
%__________________________________________________________________________
% USAGES:
%
%        1) g_track4NETpost_fdt(Label_seed_fileCell,Label_fdt_fileCell)
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: probabilistic, network

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
if length(Label_seed_fileCell) ~= length(Label_fdt_fileCell)
    error('number of files are not matched'); 
end
seed_Voxel_matrix = zeros(length(Label_seed_fileCell), length(Label_seed_fileCell));
target_Voxel_matrix = zeros(length(Label_seed_fileCell), length(Label_seed_fileCell));
target_meanFDT_matrix = zeros(length(Label_seed_fileCell), length(Label_seed_fileCell));
for i = 1:length(Label_seed_fileCell) 
    Label_seed_fileName = Label_seed_fileCell{i};
    disp(Label_seed_fileName);
    disp(cat(2, 'reading label of ',Label_seed_fileName));
    [status, results] = system(cat(2, 'fslstats ', Label_seed_fileName, ' -V'));
    tmp = str2num(results); 
    seed_Voxel_matrix(i,:) = tmp(1);
    fdt_fileName = Label_fdt_fileCell{i};
    disp(fdt_fileName);
    for j = 1:length(Label_seed_fileCell)
        if j ~= i
            Label_target_fileName = Label_seed_fileCell{j};
            [status, results] = system(cat(2, 'fslstats ', fdt_fileName, ' -k ', Label_target_fileName, ' -M -V'));
            if strcmp(results(1:5), 'ERROR'); 
                target_meanFDT_matrix(i, j)=0;
                target_Voxel_matrix(i, j)=0; 
            else
                tmp = str2num(results); 
                target_meanFDT_matrix(i, j) = tmp(1);
                target_Voxel_matrix(i, j) = tmp(2); 
            end
        end
    end
end
seedVoxel = seed_Voxel_matrix;
targetVoxel = target_Voxel_matrix;
FDT2target = target_Voxel_matrix .* target_meanFDT_matrix;
ProbabilisticMatrix = FDT2target./seedVoxel./10000;
[LabelIDFolder, b, c] = fileparts(Label_seed_fileCell{i}); 
[ProbabilisticFolder, b, c] = fileparts(LabelIDFolder);
ProbabilisticMatrixPath = [ProbabilisticFolder filesep Prefix '_ProbabilisticMatrix.mat'];
save( ProbabilisticMatrixPath, 'ProbabilisticMatrix' ); 
