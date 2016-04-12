function [ FileOut ] = g_OPDtrackNET_FileOut_Alone( BedpostxFolder, Label_vector )
%G_PDTRACKNET_FILEOUT_ALONE Summary of this function goes here
%   Detailed explanation goes here
[SubjectFolder, b, c] = fileparts(BedpostxFolder);
resultant_folder = [SubjectFolder filesep 'Network' filesep 'Probabilistic'];
FileQuantityNeed = 0;
for i = 1:length(Label_vector)
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'fdt_paths.nii.gz'];
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'Label' num2str(Label_vector(i), '%02.0f') '_SeedMask.nii.gz'];
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'Label' num2str(Label_vector(i), '%02.0f') '_TermMask.nii.gz'];
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'matrix_seeds_to_all_targets'];
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'probtrackx.log'];
    for i = 1:length(Label_vector)
        FileQuantityNeed = FileQuantityNeed + 1;
        FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'seeds_to_Label' num2str(Label_vector(i), '%02.0f') '_SeedMask.nii.gz'];
    end
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [resultant_folder filesep 'Label' num2str(Label_vector(i),'%02.0f') '_OPDtrackNET' filesep 'waytotal'];
end
