function g_ExportAtlasResultsToExcel( AtlasResultsCell, WMlabelFolderPath, WMtractFolderPath, ResultantFolder, Type )
%
%__________________________________________________________________________
% SUMMARY OF G_EXPORTATLASRESULTSTOEXCEL
% 
% Write WMlabel and WMtract results to excel.
%
% SYNTAX:
% 
% 1) g_ExportAtlasResultsToExcel( AtlasResultsCell, WMlabelFolderPath, WMtractFolderPath, ResultantFolder, Type )
%__________________________________________________________________________
% INPUTS:
%
% ATLASRESULTSCELL
%        (cell of strings) 
%        Cell of folders, each of which is the full path of one subject's 
%        atlas result. 
%
% WMLABELFOLDERPATH
%        (string) 
%        The full path of the White Matter label altas.
%
% WMTRACTFOLDERPATH
%        (string)
%        The full path of the White Matter tract altas.
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


[PANDAPath, y, z] = fileparts(which('PANDA.m'));

% Acquire the path of subjects' results
for i = 1:2:length(AtlasResultsCell)
    WMlabelFiles{(i + 1)/2} = AtlasResultsCell{i};
    WMtractFiles{(i + 1)/2} = AtlasResultsCell{i + 1};
end
WMlabelFiles = reshape(WMlabelFiles, length(WMlabelFiles), 1);
WMtractFiles = reshape(WMtractFiles, length(WMtractFiles), 1);

% Acquire the name of the brain regions
if strcmp(WMlabelFolderPath, [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'rICBM_DTI_81_WMPM_FMRIB58.nii.gz'])
    load([PANDAPath filesep 'data' filesep 'atlases' filesep 'WM_label_BrainRegion.mat']);
else
    tmp = load(WMlabelFiles{1});
    WMlabelBrainRegionsQuantity = length(tmp);
    for i = 1:WMlabelBrainRegionsQuantity
        WM_label_BrainRegion{i} = ['BrainRegion' num2str(i)];
    end
end
if strcmp(WMtractFolderPath, [PANDAPath filesep 'data' filesep 'atlases' filesep 'rICBM_DTI' filesep 'JHU_ICBM_tracts_maxprob_thr25_1mm.nii.gz'])
    load([PANDAPath filesep 'data' filesep 'atlases' filesep 'WM_tract_BrainRegion.mat']);
else
    tmp = load(WMtractFiles{1});
    WMtractBrainRegionsQuantity = length(tmp);
    for i = 1:WMtractBrainRegionsQuantity
        WM_tract_BrainRegion{i} = ['BrainRegion' num2str(i)];
    end
end

% Integrate all subjects' data into a big cell
% WMlabel
for i = 1:length(WMlabelFiles)
    tmp = load(WMlabelFiles{i});
    for j = 1:length(WM_label_BrainRegion)
        WMlabel_Array_Data{i,j} = tmp(j);
    end
end
% WMtract
for i = 1:length(WMtractFiles)
    tmp = load(WMtractFiles{i});
    for j = 1:length(WM_tract_BrainRegion)
        WMtract_Array_Data{i,j} = tmp(j);
    end
end

% Define result Name
if ~exist(ResultantFolder, 'dir')
    mkdir(ResultantFolder);
end
if strcmp(Type, 'FA')
    WMlabelResultPath = [ResultantFolder filesep 'WMlabelResults_FA.xls'];
    WMtractResultPath = [ResultantFolder filesep 'WMtractResults_FA.xls'];
elseif strcmp(Type, 'MD')
    WMlabelResultPath = [ResultantFolder filesep 'WMlabelResults_MD.xls'];
    WMtractResultPath = [ResultantFolder filesep 'WMtractResults_MD.xls'];
elseif strcmp(Type, 'L1')
    WMlabelResultPath = [ResultantFolder filesep 'WMlabelResults_L1.xls'];
    WMtractResultPath = [ResultantFolder filesep 'WMtractResults_L1.xls'];
elseif strcmp(Type, 'L23m')
    WMlabelResultPath = [ResultantFolder filesep 'WMlabelResults_L23m.xls'];
    WMtractResultPath = [ResultantFolder filesep 'WMtractResults_L23m.xls'];
end

% Write into excel
% WMlabel
g_xlswrite( WMlabelFiles, WM_label_BrainRegion, WMlabel_Array_Data, WMlabelResultPath );
% WMtract
g_xlswrite( WMtractFiles, WM_tract_BrainRegion, WMtract_Array_Data, WMtractResultPath );