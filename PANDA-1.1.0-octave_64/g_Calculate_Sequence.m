    
function SequenceNum = g_Calculate_Sequence( DataRaw_folder_path )
%
%__________________________________________________________________________
% SUMMARY OF G_CALCULATE_SEQUENCE
% 
% Calculate the quantity of sequences.
%
% SYNTAX:
%
% 1) SequenceNum = g_Calculate_Sequence( DataRaw_folder_path )
%__________________________________________________________________________
% INPUTS:
%
% RAW_FILENAME
%        (string) 
%        The full path of the folder containg DICOM.
%__________________________________________________________________________
% OUTPUTS:
%
% The quantity of sequences.     
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% See licensing information in the code
% keywords: sequence number
% Please report bugs or requests to:
%   Zaixu Cui:         <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%   Suyu Zhong:        <a href="suyu.zhong@gmail.com">suyu.zhong@gmail.com</a>
%   Gaolang Gong (PI): <a href="gaolang.gong@gmail.com">gaolang.gong@gmail.com</a>

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
isdir = g_struc2array(DataRaw, {'isdir'});
if isempty(find(isdir == 1));
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

DataRawSeq_cell = g_ls(cat(2, DataRaw_folder_path, '/*/'),'d');
SequenceNum = length(DataRawSeq_cell);


