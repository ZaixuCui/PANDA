function g_DeterministicNetwork(trackfilepath, ROIfilepath, FAfilepath)
%
%__________________________________________________________________________
% SUMMARY OF G_FIBERNUMMATRIX
% 
% Abstract the fiber which connected the ROIm and ROIn. ROI1 and ROI2 are 
% the label according to the aal.nii
%
% SYNTAX:
% 1) g_DeterministicNetwork(trackfilepath, ROIfilepath, FAfilepath)
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
%__________________________________________________________________________
% OUTPUTS:
%
% Matrix M-N.mat
%        The new fiber file which connected the ROI m and n.
% Three file named ..._Matrix_FN_..., ..._Matrix_FA_..., 
% ..._Matrix_Length_..., ..._ROIVoxelSize_..., ..._ROISurfaceSize_..., 
% in the parent folder of TrackFilePathCell{i}.
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
% See licensing information in the code
% keywords: fiber, ROI, deterministic network
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

Matrix_FN = zeros(Num_node,Num_node);
Matrix_FA= zeros(Num_node,Num_node);
Matrix_Voxel=zeros(Num_node,Num_node);
Matrix_Length=zeros(Num_node,Num_node);
ROISurface_temp=cell(90,1);
% Matrix_FNCorrectedROI=zeros(Num_node,Num_node);
for i = 1:length(Fibers)
    pStart = floor(Fibers{i}(1,:)+1);
    pEnd = floor(Fibers{i}(end,:)+1);
    
    if pStart(1)>0 && pStart(1)<=XLim &&  pStart(2)>0 && pStart(2)<=YLim && pStart(3)>0 && pStart(3)<=ZLim && pEnd(1)>0 && pEnd(1)<=XLim && pEnd(2)>0 && pEnd(2)<=YLim && pEnd(3)>0 && pEnd(3)<=ZLim
        m = Atlas(pStart(1),pStart(2),pStart(3));
        n = Atlas(pEnd(1),pEnd(2),pEnd(3));
        Index_Start=sub2ind(size(Atlas),pStart(1),pStart(2),pStart(3));
        Index_End=sub2ind(size(Atlas),pEnd(1),pEnd(2),pEnd(3));
        
        if m > 0 && n > 0 && m ~= n && m <= Num_node && n <= Num_node
            Len_m=length(ROISurface_temp{m});
            Len_n=length(ROISurface_temp{n});
            ROISurface_temp{m}(Len_m+1,1)=Index_Start;
            ROISurface_temp{n}(Len_n+1,1)=Index_End;
            Matrix_FN(m,n) = Matrix_FN(m,n) + 1;
            Matrix_FN(n,m) = Matrix_FN(n,m) + 1;
%             Matrix_FNCorrectedROI(m,n)=2*Matrix(m,n)/(ROISize(m)+ROISize(n));

            
             for j=1:size(Fibers{i},1)
                 point(j,:)=floor(Fibers{i}(j,:)+1);
                 if point(j,1)>0 && point(j,1)<=XLim &&  point(j,2)>0 && point(j,2)<=YLim && point(j,3)>0 && point(j,3)<=ZLim
                     FA(i,j)=FA_Matrix(point(j,1),point(j,2),point(j,3));
                     Matrix_FA(m,n)=Matrix_FA(m,n)+FA_Matrix(point(j,1),point(j,2),point(j,3));
                     Matrix_FA(n,m)=Matrix_FA(m,n);
%                      Matrix_FA(n,m)=Matrix_FA(n,m)+FA_Matrix(point(j,1),point(j,2),point(j,3));
                     Matrix_Voxel(m,n)=Matrix_Voxel(m,n)+1;
                     Matrix_Voxel(n,m)=Matrix_Voxel(n,m)+1;
                     if j>=2
                         Matrix_Length(m,n)=Matrix_Length(m,n)+sqrt(sum(((point(j,:)-point(j-1,:)).*Voxel_size(1,:)).^2));
                         Matrix_Length(n,m)=Matrix_Length(m,n);
                         %Matrix_Length(n,m)=Matrix_Length(n,m)+sqrt(sum(((point(j,:)-point(j-1,:)).*Voxel_size(1,:)).^2));
                     end
                 end
            end
        end     
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Update by Suyu Zhong,2012_04_28
% Matrix_bin=Matrix;
for i=1:length(ROISurface_temp)
    Sizetemp=unique(ROISurface_temp{i});
    if isempty(Sizetemp)
        ROISurfaceSize(i,1)=0;
    else ROISurfaceSize(i,1)=length(Sizetemp);
    end
end
        

for i=1:Num_node
    for j=1:Num_node
        if Matrix_FA(i,j)~=0
           Matrix_FA(i,j)=Matrix_FA(i,j)/Matrix_Voxel(i,j);
           Matrix_Length(i,j)=Matrix_Length(i,j)/Matrix_FN(i,j);
                     
       end
    end
end

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
save([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_FA_' Prefix '_' num2str(Num_node) '.txt'], 'Matrix_FA', '-ascii');
save([DeterministicNetworkFolder filesep FileNamePrefix '_Matrix_Length_' Prefix '_' num2str(Num_node) '.txt'], 'Matrix_Length', '-ascii');
save([DeterministicNetworkFolder filesep FileNamePrefix '_ROIVoxelSize_' Prefix '_' num2str(Num_node) '.txt'], 'ROIVoxelSize', '-ascii');
save([DeterministicNetworkFolder filesep FileNamePrefix '_ROISurfaceSize_' Prefix '_' num2str(Num_node) '.txt'], 'ROISurfaceSize', '-ascii');



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

   
