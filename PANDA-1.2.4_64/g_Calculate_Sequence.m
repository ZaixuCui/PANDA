    
function SequenceNum = g_Calculate_Sequence( DataRaw_folder_path )
%
%__________________________________________________________________________
% SUMMARY OF G_CALCULATE_SEQUENCE
% 
% This is to sort DICOM into different sequence 
%
% SYNTAX:
%
% 1) g_Calculate_Sequence( DataRaw_folder_path )
%__________________________________________________________________________
% INPUTS:
%
% DATARAW_FOLDER_PATH
%       (string) 
%       The full path of the folder containing DICOM files.
%__________________________________________________________________________
% OUTPUTS:
%
% The quantity of sequences.
%__________________________________________________________________________
% COMMENTS:
% 
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: dicominfo

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
DataRawtmp = dir([DataRaw_folder_path,filesep,'*']);
DataRaw = DataRawtmp(3:end);
% check if containing dicoms or subdirectory
isdir = [DataRaw.isdir];
if isempty(find(isdir == 1))
    DataNum = length(DataRaw);
    for j = 1:DataNum
        Dicominfotmp = dicominfo([DataRaw_folder_path,filesep,DataRaw(j).name]);
        Indextmp = ['0000',int2str(Dicominfotmp.SeriesNumber)];
        DataRawSeq_name = [DataRaw_folder_path,filesep,Indextmp(end-3:end),'_DTISeries'];%,Dicominfotmp.SeriesDescription];%Dicominfotmp.ProtocolName];
        if ~exist(DataRawSeq_name, 'dir')
            mkdir(DataRawSeq_name);
        end
        movefile([DataRaw_folder_path,filesep,DataRaw(j).name],DataRawSeq_name);
    end
end 

DataRawSeq_cell = g_ls(cat(2, DataRaw_folder_path, '/*/'));
SequenceNum = length(DataRawSeq_cell);


