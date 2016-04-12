function [ FileOut ] = g_dtifit_FileOut( JobName,NiiOutputPath,NumberOfSubject_String,dtifit_Prefix )
%
% FileOut contain all the files' full path of the job dtifit output 
% 12 files will be produced: _FA.nii.gz, _L1.nii.gz, _L2.nii.gz,  
%                            _L3.nii.gz, _L23m.nii.gz, _MD.nii.gz, 
%                            _MO.nii.gz, _S0.nii.gz, _V1.nii.gz,
%                            _V2.nii.gz, _V3.nii.gz, .done 
% .done file is sign of the completion of the job
%
FileOut{1} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_FA.nii.gz' ];
FileOut{2} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_L1.nii.gz' ];
FileOut{3} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_L2.nii.gz' ];
FileOut{4} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_L3.nii.gz' ];
FileOut{5} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_L23m.nii.gz' ];
FileOut{6} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_MD.nii.gz' ];
FileOut{7} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_MO.nii.gz' ];
FileOut{8} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_S0.nii.gz' ];
FileOut{9} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_V1.nii.gz' ];
FileOut{10} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_V2.nii.gz' ];
FileOut{11} = [NiiOutputPath NumberOfSubject_String filesep 'native_space' filesep dtifit_Prefix '_V3.nii.gz' ];
FileOut{12} = [NiiOutputPath NumberOfSubject_String filesep 'tmp' filesep 'OutputDone' filesep JobName '.done' ];