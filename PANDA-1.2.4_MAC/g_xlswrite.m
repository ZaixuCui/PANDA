function [ output ] = g_xlswrite( Cell_left, Cell_up, Array_data_cell, output_fileName )
%
%__________________________________________________________________________
% SUMMARY OF G_XLSWRITE
%
% Write infomation into excel.
%
% SYNTAX:
%
% 1) g_xlswrite( Cell_left, Cell_up, Array_data_cell, output_fileName )
%__________________________________________________________________________
% INPUTS:
%
% CELL_LEFT
%        (cell of strings) 
%        Cell_left{i} stores the i-th subject' information.
%
% CELL_UP
%        (cell of strings) 
%        Cell_up{i} stores information about a region of the brain.
%
% ARRAY_DATA_CELL
%        (array) 
%        Store the data, a two dimension cell of data. The element is the
%        value in one brain region of a subject.
%
% OUTPUT_FILENAME
%        (string) 
%        The full path of the output excel.
%__________________________________________________________________________
% OUTPUTS:
%
% A cell with the data the same as the excel to be produced.       
%__________________________________________________________________________
% COMMENTS:
% 
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: cell, excel

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

% Calculate the size of the cells and array
try
    Cell_left=strrep(Cell_left, ' ', '.');
    Cell_up=strrep(Cell_up,' ', '.');
catch
    none = 1;
end
[SubjectRow,SubjectColumn] = size(Cell_left); 
[BrainRow,BrainColumn] = size(Cell_up);
[DataRow,DataColumn] = size(Array_data_cell);

if(SubjectRow ~= DataRow | BrainColumn ~= DataColumn)
    error('not match!');
end

% Convert data array to a cell
% Array_data_cell = cell(DataRow,DataColumn);
% for i = 1:DataRow*DataColumn
%     Array_data_cell{i} = Array_data(i);
% end

blank = cell(BrainRow,SubjectColumn);
for i=1:BrainRow*SubjectColumn
    blank{i}='';
end

% Make four cell array together into one
% if ~exist(output_fileName, 'file')
    output = [blank,Cell_up;Cell_left,Array_data_cell];
% else
%     % Cell_up is columns' names
%     % If the file already exists, columns' names are not needed
%     output = [Cell_left,Array_data_cell];
% end

output_row = BrainRow + SubjectRow;
output_column = SubjectColumn + BrainColumn;

% Write to file
if ~exist(output_fileName, 'file')
    fid = fopen(output_fileName, 'w');
else
    fid = fopen(output_fileName, 'a+');
    fprintf( fid, '\n' );
end

for i = 1:output_row 
    for j = 0:(output_column - 1)
        if(i > BrainRow & j >= SubjectColumn)
            if isnumeric(output{j * output_row + i})
                fprintf( fid, '%f\t ',output{j * output_row + i} );
            else
                fprintf( fid, '%s\t ',output{j * output_row + i} );
            end
        else
            fprintf( fid, '%s\t ',output{j * output_row + i} );
        end
    end
    fprintf( fid, '\n' );
end
fclose(fid);

