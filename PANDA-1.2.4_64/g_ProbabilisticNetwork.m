function g_ProbabilisticNetwork( BedostxFolder, LabelSeedFileNameCell, LabelTermFileNameCell, TargetsTxtFileName, ProbabilisticTrackingType, ProbabilisticNetworkJobNum, JobName )
%
%__________________________________________________________________________
% SUMMARY OF G_PROBABILISTICNETWORK
%
% Constructing network according to the input.
%
% SYNTAX:
%
% 1) g_ProbabilisticNetwork( BedostxFolder, LabelSeedFileNameCell, LabelTermFileNameCell, TargetsTxtFileName, ProbabilisticTrackingType, ProbabilisticNetworkJobNum )
% 2) g_ProbabilisticNetwork( BedostxFolder, LabelSeedFileNameCell, LabelTermFileNameCell, TargetsTxtFileName, ProbabilisticTrackingType, ProbabilisticNetworkJobNum, JobName )
%__________________________________________________________________________
% INPUTS:
%
% BEDPOSTX_FOLDER
%        (string) 
%        The full path of the bedpostx result.
%
% LABELSEEDFILENAMECELL
%        (cell of strings) 
%        Each cell is the full path of the seed mask.
%
% LABELTERMFILENAMECELL
%        (cell of strings) 
%        Each cell is the full path of the terminate mask.
%
% TARGETSTXTFILENAME
%        (string) 
%        A txt file which contain all the target file path.
%
% PROBABILISTICTRACKINGTYPE
%        (string, 'OPD' or 'PD', default 'OPD')
%        'OPD' : Output path distribution.
%        'PD' : Correct path distribution for the length of the pathways and
%        output path distribution.
%
% PROBABILISTICNETWORKJOBNUM
%        (integer) 
%        The serial number of probabilistic network job.
%
% JOBNAME
%        (string) 
%        The name of the job which call the command this time.It is 
%        determined in the function g_dti_pipeline or g_tracking_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
%          
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
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

% SeedsQuantity = length(LabelSeedFileNameCell);
% SeedsPerJob = round(SeedsQuantity / 80);
% StartSeedNum = SeedsPerJob * (ProbabilisticNetworkJobNum - 1);
% if ProbabilisticNetworkJobNum == 80
%     Remainer = mod(SeedsQuantity, 10);
%     SeedsPerJob = SeedsPerJob + Remainer;
% end

SeedsQuantity = length(LabelSeedFileNameCell);
SeedsPerJob = fix(SeedsQuantity / 80);
Remainer = mod(SeedsQuantity, 80);
if Remainer
    if ProbabilisticNetworkJobNum <= Remainer
        SeedsPerJob = SeedsPerJob + 1;
        StartSeedNum = SeedsPerJob * (ProbabilisticNetworkJobNum - 1);
    else
        StartSeedNum = (SeedsPerJob + 1) * Remainer + SeedsPerJob * (ProbabilisticNetworkJobNum - Remainer - 1);
    end
else
    StartSeedNum = SeedsPerJob * (ProbabilisticNetworkJobNum - 1);
end

disp(StartSeedNum);
for i = 1:SeedsPerJob
    SeedCurrentNum = StartSeedNum + i;
    disp(SeedCurrentNum);
    SubJobName{i} = [JobName '_' num2str(i)];
    if strcmp(ProbabilisticTrackingType, 'OPD')

        g_OPDtrackNET( BedostxFolder, LabelSeedFileNameCell{SeedCurrentNum}, LabelTermFileNameCell{SeedCurrentNum}, TargetsTxtFileName, SubJobName{i} );

    elseif strcmp(ProbabilisticTrackingType, 'PD')

        g_PDtrackNET( BedostxFolder, LabelSeedFileNameCell{SeedCurrentNum}, LabelTermFileNameCell{SeedCurrentNum}, TargetsTxtFileName, SubJobName{i} )

    end
end

% Judge whether all the results are created

Success = 1;
if SeedsPerJob
    for i = 1:SeedsPerJob
        SeedCurrentNum = StartSeedNum + i;
        [SeedFolder, y, z] = fileparts(LabelSeedFileNameCell{SeedCurrentNum});
        if ~exist([SeedFolder filesep SubJobName{i} '.done'], 'file')
            Success = 0;
        end
    end
else
end
[SeedFolderParent, y, z] = fileparts(SeedFolder);
if Success == 1
    system(['touch ' SeedFolderParent filesep 'OutputDone' filesep JobName '.done']);
end