
function g_CopyT1(T1Path, T1ResultantFolder)

[T1ParentFolder T1FileName Suffix] = fileparts(T1Path);
if ~strcmp(T1ParentFolder, T1ResultantFolder)
    if ~exist(T1ResultantFolder)
        mkdir(T1ResultantFolder)
    end
    system(['cp ' T1Path ' ' T1ResultantFolder]);
end

if strcmp(Suffix, '.nii')
    system(['fslchfiletype NIFTI_GZ ' T1ResultantFolder filesep T1FileName Suffix]);
end