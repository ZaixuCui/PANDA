function g_DCMsorter(directory, appendix, number)
%
%__________________________________________________________________________
% SUMMARY OF G_DCMSORTER
%
% Convert images from the proprietary scanner format to the NIfTI format
% used by FSL. 
%
% SYNTAX:
% G_DCMSORTER( DIRECTORY, APPENDIX )
%__________________________________________________________________________
% INPUTS:
%
% DIRECTORY
%        (string) the full path of the DICOM data 
%
% APPENDIX
%        (string) the suffix of the DICOM data
%        For example: if the suffix is 'IMA', the appendix should be '*.IMA'
%__________________________________________________________________________
% OUTPUTS:
%
%__________________________________________________________________________
% USAGE:
%
%        1) g_DCMsorter(directory, appendix)
%__________________________________________________________________________
% COMMENTS:
% 
% This function will sort DICOM data into different series.
%
% Copyright (c) Gaolang Gong, State Key Laboratory of Cognitive 
% Neuroscience and Learning, Beijing Normal University, 2011.
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
if nargin<2; appendix='*';end;

files_cell=g_ls(cat(2, directory, filesep, appendix));
fprintf(1,'%s',[num2str(length(files_cell)) ' files to sort, % remaining: 100 ']);
for i=1:length(files_cell)
    if rem(i,floor(length(files_cell)/10))==0 
        fprintf(1,'%s',[num2str(round(100*(1-i/length(files_cell)))) ' ']);
    end
    headerinfo = dicominfo(files_cell{i});
    tmp1=headerinfo.ProtocolName; tmp1=deblank(tmp1);tmp1=strrep(tmp1, ' ', '_');
    tmp2=headerinfo.SeriesNumber; %tmp2=deblank(tmp2);tmp2=strrep(tmp2, ' ', '_');
    tmp3=headerinfo.PatientID;tmp3=deblank(tmp3);tmp3=strrep(tmp3, ' ', '_');
    output_dir=cat(2, directory, filesep, tmp3, filesep, tmp1, filesep, num2str(tmp2));
    if ~isdir(output_dir);mkdir(output_dir);end
    movefile(files_cell{i},output_dir);
end
fprintf('\n');
