
function g_average( files_in,QuantityOfSequence,Prefix,JobName )
%
%__________________________________________________________________________
% SUMMARY OF G_AVERAGE
% 
% Calculate the average of saveral runs
%
% SYNTAX:
% G_AVERAGE( DATANII_FOLDER,FILES_IN,PREFIX,JOBNAME )
%__________________________________________________________________________
% INPUTS:
%
% FILES_IN
%        (string) the full path of a .mat file which store three variables
%                 'VolumeEddycurrent_fileName','VolumePerSequence' and 
%                 'bvecsVectorNew'
%        VolumePerSequence:
%                 (integer)
%                 the quantity of volume for one scan 
%        VolumeEddycurrent_fileName:
%                 (cell of string)
%                 VolumeCropped_fileName{i} is ith volume data after
%                 eddy_correct
%                 as we know, the quantity of volume is 
%                 QuantityOfSequence*VolumePerSequence
%
% QUANTITYOFSEQUENCE
%        (integer) the quantity of scan
%
% PREFIX
%        (string) basename for the output file name
%
% JOBNAME
%        (string) the name of the job which call the command this time.It
%        is determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%     
% See g_average_FileOut.m file
%__________________________________________________________________________
% USAGES:
%
%        1) g_average( files_in,DataNii_folder )
%        2) g_average( files_in,DataNii_folder,Prefix,JobName )
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
% Neuroscience and Learning, Beijing Normal University, 2011.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fslroi, fslmaths

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

load(files_in);
[a,b,c] = fileparts(VolumeEddycurrent_fileName{1});

if QuantityOfSequence == 1
    for i = 1:VolumePerSequence
        cmd = ['cp ' VolumeEddycurrent_fileName{i} ' ' a filesep Prefix '_DWI_' num2str(i - 1,'%04.0f') '_average.nii.gz'];
        system(cmd);
    end
    cmd = ['cp ' a filesep Prefix '_bvecs_01 ' a filesep Prefix '_bvecs_average'];
    system(cmd);
    cmd = ['cp ' a filesep Prefix '_bvals_01 ' a filesep Prefix '_bvals_average'];
    system(cmd);
elseif QuantityOfSequence > 1
    for i = 1:VolumePerSequence
        VolumeAveraged{i} = [a filesep Prefix '_DWI_' num2str(i - 1,'%04.0f') '_average.nii.gz'];
        system(['cp ' VolumeEddycurrent_fileName{i} ' ' VolumeAveraged{i}]);
        for j = 1:QuantityOfSequence - 1 
            % sumed volume data
            cmd = ['fslmaths ' VolumeAveraged{i} ' -add ' VolumeEddycurrent_fileName{i + j * VolumePerSequence} ...
                   ' ' VolumeAveraged{i}];
            system(cmd);
            % sumed bvector, stored in the last sequence
            bvecsVectorNew(1,i + j * VolumePerSequence) = bvecsVectorNew(1,i + (j - 1) * VolumePerSequence) + bvecsVectorNew(1,i + j * VolumePerSequence);
            bvecsVectorNew(2,i + j * VolumePerSequence) = bvecsVectorNew(2,i + (j - 1) * VolumePerSequence) + bvecsVectorNew(2,i + j * VolumePerSequence);
            bvecsVectorNew(3,i + j * VolumePerSequence) = bvecsVectorNew(3,i + (j - 1) * VolumePerSequence) + bvecsVectorNew(3,i + j * VolumePerSequence);
        end
        % averaged volume data
        cmd = ['fslmaths ' VolumeAveraged{i} ' -div ' num2str(QuantityOfSequence) ' ' VolumeAveraged{i}];
        system(cmd);
        % averaged bvector
        bvecsVectorAverage(1,i) = bvecsVectorNew(1,i + (QuantityOfSequence - 1) * VolumePerSequence) / QuantityOfSequence; 
        bvecsVectorAverage(2,i) = bvecsVectorNew(2,i + (QuantityOfSequence - 1) * VolumePerSequence) / QuantityOfSequence; 
        bvecsVectorAverage(3,i) = bvecsVectorNew(3,i + (QuantityOfSequence - 1) * VolumePerSequence) / QuantityOfSequence; 
    end
    % averaged bvalue
    bvalsSum = 0;
    for i = 1:QuantityOfSequence
        bvals{i} = load([a filesep Prefix '_bvals_' num2str(i,'%02.0f')]);
        bvalsSum = bvalsSum + bvals{i};
    end
    bvalsAveraged = bvalsSum / QuantityOfSequence;
    
    % write averaged bvecs to file
    bvecsAverageFile = [a filesep Prefix '_bvecs_average'];
    fid = fopen(bvecsAverageFile,'w');
    if (fid == 0)
        error('Cannot open the file bvecs.');
    end
    for i = 1:3
        fprintf(fid,'  %e',bvecsVectorAverage(i,:));
        fprintf(fid,'\n');
    end
    fclose(fid);
    % write averaged bvals to file
    bvalsAverageFile = [a filesep Prefix '_bvals_average'];
    fid = fopen(bvalsAverageFile,'w');
    if (fid == 0)
        error('Cannot open the file bvals.');
    end
    fprintf(fid,'  %e',bvalsAveraged);
    fclose(fid);
end

save ([a filesep 'average_output.mat'],'VolumePerSequence');

% cp b0 to ..../data_b0.nii.gz
system(['cp ' a filesep Prefix '_DWI_01_0000_crop_eddy.nii.gz ' a(1:end - 4) filesep 'native_space' filesep 'data_b0_eddy.nii.gz']);

disp(cat(2, 'averaged is done'));
if nargin == 4
    cmd = ['touch ' a(1:end-4) filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end



