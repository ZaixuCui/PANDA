
function [ FileOut ] = g_DeterministicTracking_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,Option,Prefix )
%
% FileOut contain all the files' full path of the job BET_2 output 
% 3 files will be produced: nodif_brain.nii.gz, nodif_brain_mask.nii.gz, 
%                           .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'trackvis' filesep Prefix '_dti_' Option.PropagationAlgorithm '_'];
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
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];

