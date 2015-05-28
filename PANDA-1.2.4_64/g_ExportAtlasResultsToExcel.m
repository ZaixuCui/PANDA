function g_ExportAtlasResultsToExcel( AtlasResultsCell, WMlabelImagePath, WMtractImagePath, ResultantFolder, Type )
%
%__________________________________________________________________________
% SUMMARY OF G_EXPORTATLASRESULTSTOEXCEL
% 
% Write WMlabel and WMtract results to excel.
%
% SYNTAX:
% 
% 1) g_ExportAtlasResultsToExcel( AtlasResultsCell, WMlabelImagePath, WMtractImagePath, ResultantFolder, Type )
%__________________________________________________________________________
% INPUTS:
%
% ATLASRESULTSCELL
%        (cell of strings) 
%        Cell of folders, each of which is the full path of one subject's 
%        atlas result. 
%
% WMLABELIMAGEPATH
%        (string) 
%        The full path of the White Matter label altas image.
%
% WMTRACTIMAGEPATH
%        (string)
%        The full path of the White Matter tract altas image.
%
% RESULTANTFOLDER
%        (string)
%        The folder to store the resultant excel.
%
% TYPE
%        (string) 
%        Four selections: 'FA'
%                         'MD'
%                         'L1'
%                         'L23m'
%                         'LDHk'
%                         'LDHs'
%__________________________________________________________________________
% OUTPUTS:
%
% The excel containing all subjects' altas results. 
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: atlas, excel

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


[PANDAPath, y, z] = fileparts(which('PANDA.m'));

% Acquire the path of subjects' results
for i = 1:2:length(AtlasResultsCell)
    WMlabelFiles{(i + 1)/2} = AtlasResultsCell{i};
    WMtractFiles{(i + 1)/2} = AtlasResultsCell{i + 1};
end
WMlabelFiles = reshape(WMlabelFiles, length(WMlabelFiles), 1);
WMtractFiles = reshape(WMtractFiles, length(WMtractFiles), 1);

% Acquire the name of the brain regions
if strcmp(WMlabelImagePath, [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'])
    load([PANDAPath filesep 'data' filesep 'atlases' filesep 'WM_label_BrainRegion.mat']);
else
    WMlabelBrainRegionsQuantity = g_CalculateROIQuantity(WMlabelImagePath, ResultantFolder);
    for i = 1:WMlabelBrainRegionsQuantity
        WM_label_BrainRegion{i} = ['BrainRegion' num2str(i)];
    end
end
if strcmp(WMtractImagePath, [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'])
    load([PANDAPath filesep 'data' filesep 'atlases' filesep 'WM_tract_BrainRegion.mat']);
else
    WMtractBrainRegionsQuantity = g_CalculateROIQuantity(WMtractImagePath, ResultantFolder);
    for i = 1:WMtractBrainRegionsQuantity
        WM_tract_BrainRegion{i} = ['BrainRegion' num2str(i)];
    end
end

% Integrate all subjects' data into a big cell
% WMlabel
for i = 1:length(WMlabelFiles)
    tmp = load(WMlabelFiles{i}, 'ascii');
    if ~isempty(tmp)
        for j = 1:length(tmp)
            WMlabel_Array_Data{i,j} = tmp(j);
        end
    else
        for j = 1:length(tmp)
            WMlabel_Array_Data{i,j} = '';
        end
    end
end
% WMtract
for i = 1:length(WMtractFiles)
    tmp = load(WMtractFiles{i}, 'ascii');
    if ~isempty(tmp)
        for j = 1:length(tmp)
            WMtract_Array_Data{i,j} = tmp(j);
        end
    else
        for j = 1:length(tmp)
            WMtract_Array_Data{i,j} = '';
        end
    end
end

% Define result Name
if ~exist(ResultantFolder, 'dir')
    mkdir(ResultantFolder);
end

WMlabelResultPath = [ResultantFolder filesep 'WMlabelResults_' Type '.xls'];
WMtractResultPath = [ResultantFolder filesep 'WMtractResults_' Type '.xls'];

% Write into excel
% WMlabel
g_xlswrite( WMlabelFiles, WM_label_BrainRegion, WMlabel_Array_Data, WMlabelResultPath );
% WMtract
g_xlswrite( WMtractFiles, WM_tract_BrainRegion, WMtract_Array_Data, WMtractResultPath );

[DestinationPath y z] = fileparts(ResultantFolder);
system(['rm -rf ' DestinationPath filesep 'WM_label']);
system(['rm -rf ' DestinationPath filesep 'WM_tract_prob']);


