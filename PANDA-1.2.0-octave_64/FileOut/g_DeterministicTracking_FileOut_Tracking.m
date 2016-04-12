function FileOut = g_DeterministicTracking_FileOut_Tracking( NativeFolderPath, Option, Prefix )
%G_TRACKING_FILEOUT_ALONE Summary of this function goes here
%   Detailed explanation goes here
[NativeParentFolderPath, b, c] = fileparts(NativeFolderPath);
FileOut{1} = [NativeParentFolderPath filesep 'trackvis' filesep Prefix '_dti_' Option.PropagationAlgorithm '_'];
if ~strcmp(Option.PropagationAlgorithm, 'FACT')
    FileOut{1} = [FileOut{1} num2str(Option.StepLength) '_'];
% else
%     FileOut{1} = [FileOut{1} '_'];
end
FileOut{1} = [FileOut{1} num2str(Option.AngleThreshold) '_' num2str(Option.MaskThresMin) '_' num2str(Option.MaskThresMax) ];
if Option.RandomSeed_Flag
    FileOut{1} = [FileOut{1} '_' num2str(Option.RandomSeed)];
else
    FileOut{1} = [FileOut{1} '_0'];
end
FileOut{1} = strrep(FileOut{1}, '.', '');
FileOut{1} = strrep(FileOut{1}, ' ', '');
FileOut{1} = strrep(FileOut{1}, '-', '');
FileOut{1} = [FileOut{1} '.trk'];
if strcmp(Option.ApplySplineFilter, 'Yes')
    [a,b,c] = fileparts(FileOut{1});
    FileOut{2} = [ a filesep b '_S.trk'];
end


