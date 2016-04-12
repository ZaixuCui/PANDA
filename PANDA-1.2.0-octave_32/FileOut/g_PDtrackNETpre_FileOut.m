function [ FileOut ] = g_PDtrackNETpre_FileOut( ProbabilisticFolder, LabelVector )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
FileOut{1} = [ProbabilisticFolder filesep 'Seed2Target.txt'];
FileQuantityNeed = 1;
for i = 1:length(LabelVector)
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [ProbabilisticFolder filesep 'Label' num2str(LabelVector(i),'%02.0f') '_PDtrackNET' filesep 'Label' num2str(LabelVector(i), '%02.0f') '_SeedMask.nii.gz'];
    FileQuantityNeed = FileQuantityNeed + 1;
    FileOut{FileQuantityNeed} = [ProbabilisticFolder filesep 'Label' num2str(LabelVector(i),'%02.0f') '_PDtrackNET' filesep 'Label' num2str(LabelVector(i), '%02.0f') '_TermMask.nii.gz'];   
end
