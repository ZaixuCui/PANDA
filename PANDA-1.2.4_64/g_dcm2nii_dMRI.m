function g_dcm2nii_dMRI(DICOMFolder, Prefix, OutputDirectory)
%
%__________________________________________________________________________
% SUMMARY OF G_DCM2NII_DMRI
% 
% Convert DICOM to NIfTI for dMRI data.
%
% SYNTAX:
%
% 1) g_dcm2nii_dMRI( DICOMFolder, Prefix, OutputDirectory )
%__________________________________________________________________________
% INPUTS:
%
% DICOMFOLDER
%        (string)
%        The full path of the folder containing DICOM files.
%
% PREFIX
%        (string)
%        The prefix of output dMRI image.
%
% OUTPUTDIRECTORY
%        (string)
%        The full path of folder storing the results.
%__________________________________________________________________________
% OUTPUTS:
%     
% NIfTI images converted from the DICOM files.       
%__________________________________________________________________________
% COMMENTS:
%
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Zaixu Cui, Gaolang Gong, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: dcm2nii, dMRI

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

DataRawSeq_cell = g_ls(cat(2, DICOMFolder, '/*/'));
QuantityOfSequence = length(DataRawSeq_cell);

if ~exist(OutputDirectory, 'dir')
    mkdir(OutputDirectory);
end

[PANDAPath, y, z] = fileparts(which('PANDA.m'));
system(['chmod +x ' PANDAPath filesep 'dcm2nii' filesep 'dcm2nii']);

SuccessFinal = 1;
for i = 1:QuantityOfSequence
    
    try 
        delete([DataRawSeq_cell{i} '*nii*']);
        delete([DataRawSeq_cell{i} '*bval*']);
        delete([DataRawSeq_cell{i} '*bvec*']);

        DICOMFiles = g_ls([DataRawSeq_cell{i} filesep '*']);

        [~, FolderName, ~] = fileparts(DataRawSeq_cell{i});

        Outputdir = [OutputDirectory filesep FolderName];
        if ~exist(Outputdir)
            mkdir(Outputdir);
        end
        cmd = [PANDAPath filesep 'dcm2nii' filesep 'dcm2nii -r n -g n -o ' Outputdir ' ' DICOMFiles{3}];
        disp(cmd);
        system(cmd);

        NIfTIFiles = g_ls([Outputdir filesep '*.nii']);

        for i = 1:length(NIfTIFiles)
            cmd = ['fslchfiletype NIFTI_GZ ' NIfTIFiles{i}];
            system(cmd);
            NewNIfTIFile = [NIfTIFiles{i} '.gz'];
            cmd = ['fslswapdim ' NewNIfTIFile ' RL PA IS ' Outputdir filesep 'tmp.nii.gz'];
            system(cmd);
            cmd = ['mv ' Outputdir filesep 'tmp.nii.gz ' NewNIfTIFile];
            system(cmd);
        end

        NIfTIFiles = g_ls([Outputdir filesep '*.nii.gz']);
        BvalsFiles = g_ls([Outputdir filesep '*bval*']);
        BvecsFiles = g_ls([Outputdir filesep '*bvec*']);

        system(['mv ' NIfTIFiles{1} ' ' Outputdir filesep Prefix '.nii.gz']);
        system(['mv ' BvalsFiles{1} ' ' Outputdir filesep Prefix '.bval']);
        system(['mv ' BvecsFiles{1} ' ' Outputdir filesep Prefix '.bvec']);
    catch
        tmp = 1;
    end
    
    Success = 1;
    if ~exist([Outputdir filesep Prefix '.nii.gz'], 'file') ...
            | ~exist([Outputdir filesep Prefix '.bval'], 'file') ...
            | ~exist([Outputdir filesep Prefix '.bvec'], 'file')
        Success = 0;
    end
    SuccessFinal = SuccessFinal * Success;
    
end

if SuccessFinal == 1
    system(['touch ' OutputDirectory filesep 'dcm2nii.done']);
end


