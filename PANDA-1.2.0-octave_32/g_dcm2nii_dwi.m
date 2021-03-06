
function g_dcm2nii_dwi( DataRaw_folder_path, DataNii_folder_path, File_Prefix)
%
%__________________________________________________________________________
% SUMMARY OF G_DCM2NII_DWI
%
% Convert images from the proprietary scanner format to the NIfTI format
% used by FSL. 
%
% SYNTAX:
%
% g_dcm2nii_dwi( DataRaw_folder_path,DataNii_folder_path,File_Prefix)
%__________________________________________________________________________
% INPUTS:
%
% DATARAW_FOLDER_PATH
%        (string) 
%        The full path of the DICOM raw data which is to be to be handled 
%        for one subject. Under this folder, there shoud be multiple/single
%        subdirectories, each of which contains dicoms for each sequence.
%
% DATANII_FOLDER_PATH
%        (string) 
%        The full path of the folder storing the resultant files.
%        For example: '/data/Handled_Data/00001'
%
% File_Prefix
%        (string) 
%        Basename for the output files.
%__________________________________________________________________________
% OUTPUTS:
%
% See g_dcm2nii_dwi_FileOut.m file.
%__________________________________________________________________________
% COMMENTS:
% 
% This function will calculate the quantity of sequences of DICOM data in 
% DataRaw_folder_path, and then apply dcm2nii command to every sequence.
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% See licensing information in the code
% keywords: dcm2nii
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

global PANDAPath;
[PANDAPath y z] = fileparts(which('PANDA.m'));

DataRawSeq_cell = g_ls(cat(2, DataRaw_folder_path, '/*/'));
QuantityOfSequence = length(DataRawSeq_cell);

TmpFolder = [DataNii_folder_path filesep 'tmp' ];
if ~exist(TmpFolder, 'dir')
    mkdir(TmpFolder);
end
% For each sequence, apply dcm2nii command to its dicom data
            
for k = 1:QuantityOfSequence
    
    DataRawSeq_path = DataRawSeq_cell{k};
    DataRaw_cell = g_ls([DataRawSeq_path filesep '*']);
    
    if length(DataRaw_cell) == 3
        % If the input data type is NIfTI
        try
            NII_Path = g_ls([DataRawSeq_path filesep '*nii*']);
            bval_Path = g_ls([DataRawSeq_path filesep '*bval*']);
            bvec_Path = g_ls([DataRawSeq_path filesep '*bvec*']);
        catch
            error('Please check your data.');
        end
        
        if ~strcmp(NII_Path{1}(end - 1:end), 'gz')
            system(['fslchfiletype NIFTI_GZ ' NII_Path{1} ' ' [DataNii_folder_path filesep 'tmp' filesep File_Prefix '_DWI_' num2str(k,'%02.0f') '.nii.gz']]);
        else
            system(['cp ' NII_Path{1} ' ' [DataNii_folder_path filesep 'tmp' filesep File_Prefix '_DWI_' num2str(k,'%02.0f') '.nii.gz']]);
        end
        copyfile(bval_Path{1}, [DataNii_folder_path filesep 'tmp' filesep File_Prefix '_bvals_' num2str(k,'%02.0f')]);
        copyfile(bvec_Path{1}, [DataNii_folder_path filesep 'tmp' filesep File_Prefix '_bvecs_' num2str(k,'%02.0f')]);
    else
        % If the input data type is DICOM
        delete([DataRawSeq_path filesep '*nii*']);
        delete([DataRawSeq_path filesep '*bval*']);
        delete([DataRawSeq_path filesep '*bvec*']);

        DataRaw_cell = g_ls([DataRawSeq_path filesep '*']);
     
        system(['chmod +x ' PANDAPath filesep 'dcm2nii' filesep 'dcm2nii']);
        convert = cat(2, PANDAPath, filesep, 'dcm2nii', filesep, 'dcm2nii -a n -m n -d n -e n -f n -i n -p n -r n -x n ', DataRaw_cell{1});
        disp(convert);
        system(convert);

        if ~exist(DataNii_folder_path, 'dir')
            mkdir(DataNii_folder_path);
        end

        DataNii_cell = g_ls(cat(2,  DataRawSeq_path, '/*.nii.gz'));
        DataBval_cell = g_ls(cat(2, DataRawSeq_path, '/*.bval'));
        DataBvec_cell = g_ls(cat(2, DataRawSeq_path, '/*.bvec'));  
        niiNum = length(DataNii_cell);
        bvalNum = length(DataBval_cell);
        bvecNum = length(DataBvec_cell);
        if niiNum > 1 && bvalNum > 1 && bvecNum > 1
            error('more than one acqusition, check your data');
        end

        % Special for Dicom output from Philips scanner
        if niiNum == 2 && bvalNum == 1 && bvecNum == 1
            [a,b,c] = fileparts(DataBval_cell{1});
            DataNii_cell{1} = cat(2, a, filesep, b, '.nii');
        end
        % Special for Dicom output from Philips scanner
        movefile(DataNii_cell{1},  cat(2,DataNii_folder_path,filesep,'tmp',filesep,File_Prefix,'_DWI_',num2str(k,'%02.0f'),'.nii.gz'));
        movefile(DataBval_cell{1}, cat(2,DataNii_folder_path,filesep,'tmp',filesep,File_Prefix,'_bvals_',num2str(k,'%02.0f')));
        movefile(DataBvec_cell{1}, cat(2,DataNii_folder_path,filesep,'tmp',filesep,File_Prefix,'_bvecs_',num2str(k,'%02.0f')));
    end
   
end






