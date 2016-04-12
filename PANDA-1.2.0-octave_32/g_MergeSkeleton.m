function g_MergeSkeleton( InvidualSkeletonCell, SubjectIDs, ResultantFile )
%
%__________________________________________________________________________
% SUMMARY OF G_MERGESKELETON
%
% Merge all individual skeletons into a 4D skeleton.
%
% SYNTAX:
%
% 1) g_MergeSkeleton( InvidualSkeletonCell, SubjectIDs, ResultantFile )
%__________________________________________________________________________
% INPUTS:
%
% INVIDUALSKELETONCELL
%        (cell of strings) 
%        The input cell, each of which is individual skeleton.
%
% SUBJECTIDS
%        (array of integers) 
%        Array, each element is a Subject ID.
%
% RESULTANTFILE
%        (string) 
%        The full path of the merged 4D skeleton.
%__________________________________________________________________________
% OUTPUTS:
%
% Merged 4D skeleton name ResultantFile.       
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslmerge, All skeleton
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

% Merge individual skeletons into 4D skeleton
system(['cp ' InvidualSkeletonCell{1} ' ' ResultantFile]);
for i = 2:length(InvidualSkeletonCell)
    cmd = ['fslmerge -t ' ResultantFile ' ' ResultantFile ' ' InvidualSkeletonCell{i}];
    system(cmd);
end
% Display the parameters to the text file
[ResultantFolder, y, z] = fileparts(ResultantFile);
File = [ResultantFolder filesep 'SubjectID.txt'];
fid = fopen(File, 'w');
for i = 1:length(SubjectIDs)
    fprintf(fid, ['The ' num2str(i) ' dimension:']);
    fprintf(fid, ' \t');
    fprintf(fid, [num2str(SubjectIDs(i), '%05d') ' subject']);
    fprintf(fid, '\n');
end