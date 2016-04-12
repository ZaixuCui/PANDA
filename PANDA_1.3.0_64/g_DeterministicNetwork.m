function g_DeterministicNetwork(trackfilepath, ROIfilepath,FAfilepath, JobName)
%
%__________________________________________________________________________
% SUMMARY OF G_FIBERNUMMATRIX
% 
% Abstract the fiber which connected the ROIm and ROIn. ROI1 and ROI2 are 
% the label according to the parcellated altas.
%
% SYNTAX:
% 
% 1) g_FiberNumMatrix(trackfilepath, ROIfilepath, FAfilepath)
% 2) g_FiberNumMatrix(trackfilepath, ROIfilepath, FAfilepath, JobName)
%__________________________________________________________________________
% INPUTS:
%
% TRACKFILEPATH
%       (string)
%       The full path of fiber tracking file.
%
% ROIFILEPATH
%       (string)
%       ROI label file.
%
% FAFILEPATH
%       (string)
%       The full path of FA in native space.
%
% JOBNAME
%        (string) 
%        The name of the job which call the command this time.It is 
%        determined in the function g_dti_pipeline.
%        If you use this function alone, this parameter is not needed.
%__________________________________________________________________________
% OUTPUTS:
%
% MatrixM-N.mat
%        the new fiber file which connected the ROI m and n.
%__________________________________________________________________________
% COMMENTS:
% 
% My work is based on the psom refered to http://code.google.com/p/psom/.
% It has an attractive feature: if the job breaks and you restart, it will
% excute the job from the break point rather than from the start.
% The output files jobs will produce are specifiled in the file named 
% [JOBNAME '_FileOut.m']
%
% Copyright (c) Suyu Zhong, Gaolang Gong, Zaixu Cui, State Key Laboratory 
% of Cognitive Neuroscience and Learning, Beijing Normal University, 2012.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: fiber, ROI, deterministic network

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

disp(trackfilepath);
disp(ROIfilepath);
[TrackingFolder,FileNamePrefix,c] = fileparts(trackfilepath);
[NativeFolder,ROIFileName,ROIFileNameSuffix] = fileparts(ROIfilepath);
[SubjectFolder,b,c] = fileparts(TrackingFolder);
DeterministicNetworkFolder = [SubjectFolder filesep 'Network' filesep 'Deterministic'];
if ~exist(DeterministicNetworkFolder, 'dir')
    mkdir(DeterministicNetworkFolder);
end
%%%%%%%%%%%%%%%%%%%%%%%updated By SuyuZhong 2012_04_28
% index_dir=findstr(SubjectFolder,'/');
% SubjectNum=SubjectFolder(index_dir(end):end);
%  
%FAfilepath = cat(2,NativeFolder,filesep,SubjectNum,'_FA.nii.gz')
[NativeFolder,FAFileName,FAFileNameSuffix] = fileparts(FAfilepath);

if strcmp(FAFileNameSuffix, '.nii') 
    cmd = [ 'fslchfiletype NIFTI_PAIR ' FAfilepath ' ' DeterministicNetworkFolder filesep FAFileName];
    system(cmd);
    FAfilepath = [DeterministicNetworkFolder filesep FAFileName];
elseif strcmp(FAFileNameSuffix, '.gz')
    cmd = [ 'fslchfiletype NIFTI_PAIR ' FAfilepath ' ' DeterministicNetworkFolder filesep FAFileName(1:end-4)];
    system(cmd);
    FAfilepath = [DeterministicNetworkFolder filesep FAFileName(1:end-4)];
end
disp(FAfilepath);

if strcmp(ROIFileNameSuffix, '.nii') 
    cmd = [ 'fslchfiletype NIFTI_PAIR ' ROIfilepath ' ' DeterministicNetworkFolder filesep ROIFileName];
    system(cmd);
    ROIfilepath = [DeterministicNetworkFolder filesep ROIFileName];
elseif strcmp(ROIFileNameSuffix, '.gz')
    cmd = [ 'fslchfiletype NIFTI_PAIR ' ROIfilepath ' ' DeterministicNetworkFolder filesep ROIFileName(1:end-4)];
    system(cmd);
    ROIfilepath = [DeterministicNetworkFolder filesep ROIFileName(1:end-4)];
end
disp(ROIfilepath);

prec   = {'uint8','int16','int32','float32','float64','int8','uint16','uint32'};
types  = [    2      4      8   16   64   256    512    768];

Fibers = {};
[f] = g_readTrack(trackfilepath);

Voxel_size=f.voxel_size;
XLim = f.dim(1);
YLim = f.dim(2);
ZLim = f.dim(3);
for i = 1:size(f.fiber,2)
    Fibers{i} = f.fiber(i).xyzFiberCoord; 
end


[status,message] = system(cat(2, 'fslinfo ', ROIfilepath));
message = strtrim(message);
label = isspace(message);
label = 1 - label;
diff = label(1:end - 1) - label(2:end);
start_index = find(diff == -1); 
start_index = [1, start_index + 1];
end_index = find(diff == 1); 
end_index = [end_index, length(label)];
for i = 1:length(start_index)
    cell_item{i, 1} = message(start_index(i):end_index(i));
end

tmp = strcmpi('datatype', cell_item);
data_type = cell_item(find(tmp==1)+1);
data_type_ROI = str2num(data_type{1});

tmp = strcmpi('pixdim1', cell_item);
pix_temp1 = cell_item(find(tmp==1)+1);
pixdim1 = str2num(pix_temp1{1});

tmp = strcmpi('pixdim2', cell_item);
pix_temp2 = cell_item(find(tmp==1)+1);
pixdim2 = str2num(pix_temp2{1});

tmp = strcmpi('pixdim3', cell_item);
pix_temp3 = cell_item(find(tmp==1)+1);
pixdim3 = str2num(pix_temp3{1});

sel = find(types == data_type_ROI);
fid = fopen(cat(2,ROIfilepath,'.img'),'rb');
Atlas = fread(fid,prec{sel});
fclose(fid);
delete(cat(2,ROIfilepath,'.img'));
delete(cat(2,ROIfilepath,'.hdr'));
Atlas = reshape(Atlas,XLim,YLim,ZLim);


[status,message] = system(cat(2, 'fslinfo ', FAfilepath));
message = strtrim(message);
label = isspace(message);
label = 1 - label;
diff = label(1:end - 1) - label(2:end);
start_index = find(diff == -1); 
start_index = [1, start_index + 1];
end_index = find(diff == 1); 
end_index = [end_index, length(label)];
for i = 1:length(start_index)
    cell_item{i, 1} = message(start_index(i):end_index(i));
end

tmp = strcmpi('datatype', cell_item);
data_type = cell_item(find(tmp==1)+1);
data_type_FA = str2num(data_type{1});

selFA = find(types == data_type_FA);

fid = fopen(cat(2,FAfilepath,'.img'),'rb');
FA_Matrix = fread(fid,prec{selFA});
fclose(fid);
delete(cat(2,FAfilepath,'.img'));
delete(cat(2,FAfilepath,'.hdr'));
FA_Matrix= reshape(FA_Matrix,XLim,YLim,ZLim);

Num_node=max(max(max(Atlas)));


for i=1:Num_node
    
  ROIVoxelSize(i,1)=length(find(Atlas==i));
  
end

%revised by Suyu according to Gong's script 20150507
global Length_Matrix_Fiber
global FA_SumAndVoxel_Fiber
for i=1:size(f.fiber,2)
    TP_1(i,1:3)=f.fiber(i).xyzFiberCoord(1,:);
    TP_2(i,1:3)=f.fiber(i).xyzFiberCoord(end,:);
    Length_Matrix_Fiber(i,1)=sum(sqrt(sum((Fibers{i}(1:end-1,:).*repmat(Voxel_size(1,:),(length(Fibers{i})-1),1)-Fibers{i}(2:end,:).*repmat(Voxel_size(1,:),(length(Fibers{i})-1),1)).^2,2)));
    MP=floor(f.fiber(i).xyzFiberCoord(:,:)+1);
    MP_Index=sub2ind(size(Atlas), MP(:,1),MP(:,2),MP(:,3));
    FA_SumAndVoxel_Fiber(i,1)=sum(FA_Matrix(MP_Index));
    FA_SumAndVoxel_Fiber(i,2)=length(MP_Index);
end
    TP_1_ijk=TP_1';
    TP_2_ijk=TP_2';
    TP_1_ijk = floor(TP_1_ijk(1:3,:)+1);
    TP_2_ijk = floor(TP_2_ijk(1:3,:)+1);


Matrix_FN = zeros(Num_node,Num_node);
Matrix_FA= zeros(Num_node,Num_node);
Matrix_Voxel=zeros(Num_node,Num_node);
Matrix_Length=zeros(Num_node,Num_node);
ROISurface_temp=cell(Num_node,1);
%update by Suyu acoording to Gong's Script 20150507

Index_TP_1= sub2ind(size(Atlas),TP_1_ijk(1,:), TP_1_ijk(2,:), TP_1_ijk(3,:));
Index_TP_2= sub2ind(size(Atlas),TP_2_ijk(1,:), TP_2_ijk(2,:), TP_2_ijk(3,:));

Index_TP_1_LabelIndex=Atlas(Index_TP_1);
Index_TP_2_LabelIndex=Atlas(Index_TP_2);

FiberIndex_matrix=cell(Num_node,Num_node);
% FiberLength_matrix=zeros(Num_node,Num_node);
% FiberNumber_matrix=zeros(Num_node,Num_node);
for j=1:f.nFiberNr
    
    if Index_TP_1_LabelIndex(j)*Index_TP_2_LabelIndex(j)~=0 && Index_TP_1_LabelIndex(j)~=  Index_TP_2_LabelIndex(j)
        Len_m=length(ROISurface_temp{Index_TP_1_LabelIndex(j)});
        Len_n=length(ROISurface_temp{Index_TP_2_LabelIndex(j)});
        FiberIndex_matrix{Index_TP_1_LabelIndex(j), Index_TP_2_LabelIndex(j)}=[FiberIndex_matrix{Index_TP_1_LabelIndex(j), Index_TP_2_LabelIndex(j)};j];
        Matrix_FN(Index_TP_1_LabelIndex(j), Index_TP_2_LabelIndex(j))=length([FiberIndex_matrix{Index_TP_1_LabelIndex(j), Index_TP_2_LabelIndex(j)}]);
        ROISurface_temp{Index_TP_1_LabelIndex(j)}(Len_m+1,1)=Index_TP_1(j);
        ROISurface_temp{Index_TP_2_LabelIndex(j)}(Len_n+1,1)=Index_TP_2(j);
        
    end
end
% [Matrix_Length] = cellfun(@Fiber2Length, FiberIndex_matrix);
[Matrix_FA,Matrix_Voxel,Matrix_Length] = cellfun(@Fiber2FAandLength, FiberIndex_matrix);
Matrix_FN=Matrix_FN'+Matrix_FN;
Matrix_Voxel = Matrix_Voxel'+ Matrix_Voxel;
Matrix_Length=(Matrix_Length'+Matrix_Length)./Matrix_FN;
Matrix_FA = (Matrix_FA' + Matrix_FA)./Matrix_Voxel;
ROISurfaceSize = cellfun(@ROISurfVoxnum,ROISurface_temp);
Matrix_FA(find(isnan(Matrix_FA)))=0;
Matrix_Length(find(isnan(Matrix_Length)))=0;
% save([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_'
% num2str(Num_node) '.mat'], 'Matrix');Update by Suyu Zhong,2012_04_28
[x, ROIFileName, z] = fileparts(ROIFileName);
Prefix = '';   
if ~isempty(strfind(ROIFileName, 'Parcellated'))
    Prefix = ROIFileName((strfind(ROIFileName, 'Parcellated')+12):end);
else
    Prefix = ROIFileName;
end
disp(ROIFileName);
save([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_FN_' Prefix '_' num2str(Num_node) '.txt'], 'Matrix_FN', '-ascii');
disp([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_FN_' Prefix '_' num2str(Num_node) '.txt']);
save([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_FA_' Prefix '_' num2str(Num_node) '.txt'], 'Matrix_FA', '-ascii');
save([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_Length_' Prefix '_' num2str(Num_node) '.txt'], 'Matrix_Length', '-ascii');
save([DeterministicNetworkFolder filesep FileNamePrefix '_ROIVoxelSize_' Prefix '_' num2str(Num_node) '.txt'], 'ROIVoxelSize', '-ascii');
save([DeterministicNetworkFolder filesep FileNamePrefix '_ROISurfaceSize_' Prefix '_' num2str(Num_node) '.txt'], 'ROISurfaceSize', '-ascii');

if nargin == 4
    cmd = ['touch ' SubjectFolder filesep 'tmp' filesep 'OutputDone' filesep JobName '.done '];
    system(cmd);
end


function [f] =g_readTrack(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program will read in a "dti.trk" file created
%   within Trackvis. 
%   SYNTAX:
%   G_READTRACK(FILENAME)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   INPUTS
%   FILENAME
%      (string)the full path of the .trk file
%      For example:'/data/node2/suyu/001+/trackvis_2/test_sl_nsf.trk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   OUTPUTS:
%   f.mat file format 
%		     - f.id_string               - ID string for track file.The first 5 characters must be "TRACK".
%            - f.dim                     - Dimension of the image volume.
%	     - f.voxel_size              - Voxel size of the image volume.
%		     - f.orgin                   - Origin of the image volume. 
%                                     		   This field is not yet being used by TrackVis.
%                                        	   That means the origin is always (0, 0, 0).
%            - f.n_scalars               - Number of scalars saved at each track point (besides x, y and z coordinates).
%		     - f.scalar_name             - Name of each scalar. Can not be longer than 20 characters each. Can only store up to 10 names.
%		     - f.n_properties            - Number of properties saved at each track.
%		     - f.property_name           - Name of each property. 
%                                        	   Can not be longer than 20 characters each. Can only store up to 10 names.
%            - f.vox_to_ras              - A 4x4 matrix for voxel to RAS (crs to xyz) transformation. 
%                                        	   If vox_to_ras[3][3] is 0, it means the matrix is not recorded. 
%            - f.reserved                - Reserved space for future version.
%		     - f.voxel_order             - Storing order of the original image data. 
%		     - f.pad2                    - Paddings.
%		     - image_orientation_patient - Image orientation of the original image. 
%		     - f.pad1                    - Paddings.
%            - f.invert_x                - Inversion/rotation flags used to generate this track file. 
%            - f.invert_y                - As above
%            - f.invert_z                - As above
%            - f.swap_xy                 - As above.
%		     - f.swap_yz                 - As above.
%		     - f.swap_zx                 - As above.
%		     - f.nFiberNr                - Number of tracks stored in this track file. 0 means the number was NOT stored.
%            - f.version                 - Version number of the trackvis.
%            - f.hdr_size                - Size of the header. Used to determine byte swap. Should be 1000.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Author  Suyu Zhong 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen(filename, 'rb', 'l');
f.id_string                 = fread(fid, 6, '*char')';% image dimenson
f.dim                       = fread(fid, 3, 'short')';% voxel size
f.voxel_size                = fread(fid, 3, 'float')';
f.origin                    = fread(fid, 3, 'float')';%Orign of the image volume.
f.n_scalars                 = fread(fid, 1, 'short')';
f.scalar_name               = fread(fid, [20,10], '*char')';
f.n_properties              = fread(fid, 1, 'short')';
f.property_name             = fread(fid, [20,10], '*char')';
f.vox_to_ras                = fread(fid, [4,4], 'float')';
f.reserved                  = fread(fid, 444, '*char');
f.voxel_order               = fread(fid, 4, '*char')';
f.pad2                      = fread(fid, 4, '*char')';
f.image_orientation_patient = fread(fid, 6, 'float')';
f.pad1                      = fread(fid, 2, '*char')';
f.invert_x                  = fread(fid, 1, 'uchar');
f.invert_y                  = fread(fid, 1, 'uchar');
f.invert_z                  = fread(fid, 1, 'uchar');
f.swap_xy                   = fread(fid, 1, 'uchar');
f.swap_yz                   = fread(fid, 1, 'uchar');
f.swap_zx                   = fread(fid, 1, 'uchar');
f.nFiberNr                   = fread(fid, 1, 'int')';
f.version                   = fread(fid, 1, 'int')';
f.hdr_size                  = fread(fid, 1, 'int')';% Preallocate 
f.fiber(1).nFiberLength = 0;
f.fiber(1).xyzFiberCoord = single(zeros(3, 100000));
ii=0;
 while feof(fid) == 0
    ii=ii+1;
	%each fiber is stored in following way:
	%int nFiberLength;	    // fiber length
     A= fread(fid, 1, 'int');
     if(A~=0)
	f.fiber(ii).nFiberLength=A; 

	% XYZ_TRIPLE    xyzFiberCoordinate[nFiberLength]; //x-y-x, 3 float data
	f.fiber(ii).xyzFiberCoord = fread(fid, [3+f.n_scalars f.fiber(ii).nFiberLength], 'float=>float')';
         if f.n_properties
           f.fiber(ii).props=fread(fid,f.n_properties,'float');
         end
          f.fiber(ii).xyzFiberCoord=double(f.fiber(ii).xyzFiberCoord./repmat(f.voxel_size,f.fiber(ii).nFiberLength,1));
        
        f.nFiberNr=ii;
    end
    
end

fclose(fid);

% function [MFA,VT]=Fiber2FA_T(a)
% global FiberIndex_matrix
% if a~=0
% % load('/data/s1/zhongsuyu/FA_SumAndVox.mat');
% 
% MFA=sum(FA_SumAndVoxel_Fiber(a,1))/sum(FA_SumAndVoxel_Fiber(a,2));
% VT=sum(FA_SumAndVoxel_Fiber(a,2));
% else
%     MFA=0;
% end

function [SumFA4Matrix,VoxelNum4Matrix,Fiberlength4Matrix]=Fiber2FAandLength(Index_Fiber)
global FA_SumAndVoxel_Fiber
global Length_Matrix_Fiber
if Index_Fiber~=0
    
SumFA4Matrix=sum(FA_SumAndVoxel_Fiber(Index_Fiber,1));
VoxelNum4Matrix=sum(FA_SumAndVoxel_Fiber(Index_Fiber,2));
Fiberlength4Matrix=sum(Length_Matrix_Fiber(Index_Fiber,1));
else
    SumFA4Matrix=0;
    VoxelNum4Matrix=0;
    Fiberlength4Matrix =0;
end


function [Voxnum]=ROISurfVoxnum(a)
    Voxnum=length(unique(a));
