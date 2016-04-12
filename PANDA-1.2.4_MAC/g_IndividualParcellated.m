function g_IndividualParcellated( FAPath, T1BetName, PartitionTemplatePath, T1toFAMat, T1toMNI152_warp_inv )
%
%__________________________________________________________________________
% SUMMARY OF G_INDIVIDUALPARCELLATED
% 
% Produce the individual parcellated image according to the atlas. 
%
% SYNTAX:
%
% 1) g_IndividualParcellated( FAPath, T1BetName, PartitionTemplatePath, T1toFAMat, T1toMNI152_warp_inv )
%__________________________________________________________________________
% INPUTS:
%
% FAPATH
%        (string) 
%        The full path of the FA image.
%
% T1BETNAME
%        (string) 
%        The full path of T1 image after brain extraction.
%
% PARTITIONTEMPLATEPATH
%        (string) 
%        The full path of gray matter altas in standard space.
%
% T1TOFAMAT
%        (string)
%        The matrix produced by registering T1 to FA.
%
% T1TOMNI152_WARP_INV
%        (string)
%        The T1 image registered to MNI152 space and then invwarped.
%__________________________________________________________________________
% OUTPUTS:
%
% The individual parcellated image.
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: applywarp, slicer, slicesdir

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

[NativeFolder, FAFileName, FASuffix] = fileparts(FAPath); 
[SubjectFolder, b, c] = fileparts(NativeFolder);
[a, PartitionTemplateName, PartitionTemplateSuffix] = fileparts(PartitionTemplatePath);
if strcmp(FASuffix, '.gz')
    if strcmp(PartitionTemplateSuffix, '.gz')
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName(1:end-4) '_Parcellated_' PartitionTemplateName(1:end-4)];
    elseif strcmp(PartitionTemplateSuffix, '.nii') || isempty(PartitionTemplateSuffix)
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName(1:end-4) '_Parcellated_' PartitionTemplateName];
    end
elseif strcmp(FASuffix, '.nii');
    if strcmp(PartitionTemplateSuffix, '.gz') 
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateName(1:end-4)];
    elseif strcmp(PartitionTemplateSuffix, '.nii') || isempty(PartitionTemplateSuffix)
        T1toFA_PartitionTemplate = [NativeFolder filesep FAFileName '_Parcellated_' PartitionTemplateName];
    end
end
        
command = cat(2,'applywarp -i ', PartitionTemplatePath, ' -o ', T1toFA_PartitionTemplate, ' -r ',FAPath,' -w ',...
          T1toMNI152_warp_inv, ' --postmat=', T1toFAMat, ' --interp=nn');
disp(command);
system(command);

if strcmp(FAPath(end-2:end), '.gz')
    filename_FA_binarise = [FAPath(end-6:end) '_bin.nii.gz'];
elseif strcmp(FAPath(end-3:end), '.nii')
    filename_FA_binarise = [FAPath(end-3:end) '_bin.nii'];
end
system(['fslmaths ' FAPath ' -bin ' filename_FA_binarise]);
system(['fslmaths ' T1toFA_PartitionTemplate ' -mul ' filename_FA_binarise ' ' T1toFA_PartitionTemplate]);

% Quality control for T1
T1Slicerdir = [SubjectFolder filesep 'quality_control' filesep 'T1'];
if ~exist(T1Slicerdir, 'dir')
    mkdir(T1Slicerdir);
end 
[a, T1Name, T1Suffix] = fileparts(T1BetName); 
if strcmp(T1Suffix, '.gz')
    system(['slicer ' T1BetName ' -a ' T1Slicerdir filesep T1Name(1:end-4) '_QC.png']);
elseif strcmp(T1Suffix, '.nii')
    system(['slicer ' T1BetName ' -a ' T1Slicerdir filesep T1Name '_QC.png']);
end
% Quality control for individual partition 
IndividualParcellatedSlicesdir = [SubjectFolder filesep 'quality_control' filesep 'Individual_Parcellated'];
if ~exist(IndividualParcellatedSlicesdir, 'dir')
    mkdir(IndividualParcellatedSlicesdir);
end

system(['cd ' IndividualParcellatedSlicesdir ' && slicesdir -o ' T1toFA_PartitionTemplate ' ' FAPath]);

