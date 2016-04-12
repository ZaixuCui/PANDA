function ROIQuantity = g_CalculateROIQuantity(ROIFile_Path, TmpFolder)

if ~exist(TmpFolder, 'dir')
    mkdir(TmpFolder);
end

[x ROIFile_Name z] = fileparts(ROIFile_Path);
if strcmp(ROIFile_Path(end - 6:end), '.nii.gz')
    ROIFile_Img = [TmpFolder filesep ROIFile_Name(1:end - 4)];
    system(['fslchfiletype NIFTI_PAIR ' ROIFile_Path ' ' ROIFile_Img]);
elseif strcmp(ROIFile_Path(end - 2:end), '.nii')
    ROIFile_Img = [TmpFolder filesep ROIFile_Name];
    system(['fslchfiletype NIFTI_PAIR ' ROIFile_Path ' ' ROIFile_Img]);
end

prec   = {'uint8','int16','int32','float32','float64','int8','uint16','uint32'};
types  = [    2      4      8   16   64   256    512    768];

fid = fopen([ROIFile_Img '.hdr'],'rb');
fseek(fid,40,'bof');
dim=fread(fid,8,'short');
fseek(fid,14,'cof');
datatype=fread(fid,1,'short');
fclose(fid);

sel = find(types == datatype);

fid = fopen(cat(2,ROIFile_Img,'.img'),'rb');
Atlas = fread(fid,prec{sel});
fclose(fid);
delete(cat(2,ROIFile_Img,'.img'));
delete(cat(2,ROIFile_Img,'.hdr'));

Atlas = reshape(Atlas,dim(2),dim(3),dim(4));
ROIQuantity = length(unique(Atlas)) - 1;

