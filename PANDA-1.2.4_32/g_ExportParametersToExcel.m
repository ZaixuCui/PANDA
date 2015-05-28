function g_ExportParametersToExcel(ParametersMatFiles, SubjectIDs, ResultFile)
%
%__________________________________________________________________________
% SUMMARY OF G_EXPORTPARAMETERSTOEXCEL
%
% Export the scanning parameters into excel.
%
% SYNTAX:
%
% 1) g_ExportParametersToExcel( ParametersMatFiles, SubjectIDs, ResultFolder )
%__________________________________________________________________________
% INPUTS:
%
% PARAMETERSMATFILES
%        (cell of strings) 
%        The input cell, each of which is the full path of subject's .mat
%        file containing scanning parameters
%
% SubjectIDs
%        (array)  
%        Array of subject IDs. 
%
% ResultFolder
%        (string) 
%        The full path of the resultant file containing scanning parameters
%        of all subjects.
%__________________________________________________________________________
% OUTPUTS:
%
% An excel with the scanning parameters of all subjects.       
%__________________________________________________________________________
% COMMENTS:
% 
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: scanning parameters, excel

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

[ResultFolder y z] = fileparts(ResultFile);
if ~exist(ResultFolder, 'dir')
    mkdir(ResultFolder);
end

% Load information from every .mat file
for i = 1:length(ParametersMatFiles)
    try
        Parameters{i} = load(ParametersMatFiles{i});
    catch
        Parameters{i} = '';
    end
end

% Calculate the length of the fields
ParametersLength = 0;
for i = 1:length(ParametersMatFiles)
    if ~isempty(Parameters{i})
        FieldNamesCell = fieldnames(Parameters{i});
        FieldNamesCell = reshape(FieldNamesCell, 1, length(FieldNamesCell));
        
        ParametersLength = length(FieldNamesCell);
        break;
    end
end
if i >= length(ParametersMatFiles) & isempty(Parameters{i})
    FieldNamesCell{1} = '';
end

% 
Data = '';
for i = 1:length(ParametersMatFiles)
    try
        ParametersCell{i} = struct2cell(Parameters{i});
        ParametersCell{i} = reshape(ParametersCell{i}, 1, length(ParametersCell{i}));
    catch
        if ParametersLength
            for j = 1:ParametersLength
                ParametersCell{i}{j} = '';
            end    
        else
            ParametersCell{i}{1} = '';
        end
    end
    Data = [Data; ParametersCell{i}];
end

for i = 1:length(SubjectIDs)
    SubjectIDsCell{i} = num2str(SubjectIDs(i), '%05d');
end
SubjectIDsCell = reshape(SubjectIDsCell, length(SubjectIDsCell), 1);
g_xlswrite( SubjectIDsCell, FieldNamesCell, Data, ResultFile );

