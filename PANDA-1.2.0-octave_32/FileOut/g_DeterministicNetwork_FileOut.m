function [ FileOut ] = g_DeterministicNetwork_FileOut( NiiOutputPath,NumberOfSubject_String,Option,PartitionTemplate,Prefix )
%G_FIBERNUMMATRIX_FILEOUT Summary of this function goes here
%   Detailed explanation goes here
Prefix = [NiiOutputPath NumberOfSubject_String filesep 'Network' filesep 'Deterministic' filesep Prefix '_dti_' Option.PropagationAlgorithm '_'];
if ~strcmp(Option.PropagationAlgorithm, 'FACT')
    Prefix = [Prefix num2str(Option.StepLength) '_'];
% else
%     Prefix = [Prefix '_'];
end
Prefix = [Prefix num2str(Option.AngleThreshold) '_' num2str(Option.MaskThresMin) '_' num2str(Option.MaskThresMax) ];
if Option.RandomSeed_Flag
    Prefix = [Prefix '_' num2str(Option.RandomSeed)];
else
    Prefix = [Prefix '_0'];
end
Prefix = strrep(Prefix, '.', '');
Prefix = strrep(Prefix, ' ', '');
Prefix = strrep(Prefix, '-', '');

% Acquire the max value in the partition template, the value will be in the
% name of the adjacency matrix
if ~exist([NiiOutputPath NumberOfSubject_String], 'dir')
    mkdir([NiiOutputPath NumberOfSubject_String]);
end
if ~exist([NiiOutputPath NumberOfSubject_String filesep 'tmp'], 'dir')
    mkdir([NiiOutputPath NumberOfSubject_String filesep 'tmp']);
end
PartitionTemplateTmpe = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'Template'];
system(['fslchfiletype NIFTI_PAIR ' PartitionTemplate ' ' PartitionTemplateTmpe]);
fid = fopen(cat(2,PartitionTemplateTmpe,'.hdr'),'rb');
fseek(fid,40,'bof');
dim=fread(fid,8,'short');
fseek(fid,14,'cof');
datatype=fread(fid,1,'short');
fclose(fid);
prec   = {'uint8','int16','int32','float32','float64','int8','uint16','uint32'};
types  = [    2      4      8   16   64   256    512    768];

sel = find(types == datatype);

fid = fopen(cat(2,PartitionTemplateTmpe,'.img'),'rb');
Atlas = fread(fid,prec{sel});
fclose(fid);
delete(cat(2,PartitionTemplateTmpe,'.img'));
delete(cat(2,PartitionTemplateTmpe,'.hdr'));

Atlas = reshape(Atlas,dim(2),dim(3),dim(4));
Num_node=max(max(max(Atlas)));

PartitionTemplatePrefix = '';
if strcmp(PartitionTemplate(end - 6:end),'.nii.gz')
    [x, y, z] = fileparts(PartitionTemplate);
    PartitionTemplatePrefix = y(1:end - 4);
else
    [x, PartitionTemplatePrefix, z] = fileparts(PartitionTemplate);
end
Prefix2 = '';   
if Option.PartitionOfSubjects 
    if ~isempty(strfind(PartitionTemplate, 'Parcellated'))
        Prefix2 = PartitionTemplatePrefix((strfind(PartitionTemplatePrefix, 'Parcellated')+12):end);
    else
        Prefix2 = PartitionTemplatePrefix;
    end
elseif Option.T1
    Prefix2 = PartitionTemplatePrefix;
end
FileOut{1} = [Prefix '_Matrix_FN_' Prefix2 '_' num2str(Num_node) '.txt'];
FileOut{2} = [Prefix '_Matrix_FA_' Prefix2 '_' num2str(Num_node) '.txt'];
FileOut{3} = [Prefix '_Matrix_Length_' Prefix2 '_' num2str(Num_node) '.txt'];
FileOut{4} = [Prefix '_ROIVoxelSize_' Prefix2 '_' num2str(Num_node) '.txt'];
FileOut{5} = [Prefix '_ROISurfaceSize_' Prefix2 '_' num2str(Num_node) '.txt'];



