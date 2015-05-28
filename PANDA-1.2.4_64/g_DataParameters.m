function g_DataParameters( DataRaw_folder_path, DataNii_folder_path )

global PANDAPath;
[PANDAPath y z] = fileparts(which('PANDA.m'));

ScanningParameterFolder = [DataNii_folder_path filesep 'quality_control' filesep 'Scanning_Parameter'];
if ~exist(ScanningParameterFolder, 'dir')
    mkdir(ScanningParameterFolder);
end
MatFile = [ScanningParameterFolder filesep 'ScanningParameters.mat'];
TxtFile = [ScanningParameterFolder filesep 'ScanningParameters.txt'];
system(['touch ' MatFile]);
system(['touch ' TxtFile]);

try 
    
    DataRawSeq_cell = g_ls(cat(2, DataRaw_folder_path, '/*/'));
    QuantityOfSequence = length(DataRawSeq_cell);

    DataRawSeq_path = DataRawSeq_cell{1};
    DataRaw_cell = g_ls([DataRawSeq_path filesep '*']);

    if length(DataRaw_cell) == 3
        % If the input data type is NIfTI
        try
            NII_Path = g_ls([DataRawSeq_path filesep '*nii*']);
            bval_Path = g_ls([DataRawSeq_path filesep '*bval*']);
            bvec_Path = g_ls([DataRawSeq_path filesep '*bvec*']);
        catch
            error('Please check your data.');
        end

        % Read information from NIfTI
        [status,message] = system(cat(2, 'fslinfo ', NII_Path{1}));
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

        tmp = strcmpi('data_type', cell_item);
        data_type_tmp = cell_item(find(tmp==1)+1);
        data_type = data_type_tmp{1};

        tmp = strcmpi('dim1', cell_item);
        dimstr = cell_item(find(tmp == 1) + 1);
        dim(1) = str2num(dimstr{1});

        tmp = strcmpi('dim2', cell_item);
        dimstr = cell_item(find(tmp == 1) + 1);
        dim(2) = str2num(dimstr{1});

        tmp = strcmpi('dim3', cell_item);
        dimstr = cell_item(find(tmp == 1) + 1);
        dim(3) = str2num(dimstr{1});

        tmp = strcmpi('dim4', cell_item);
        dimstr = cell_item(find(tmp == 1) + 1);
        Volumes = str2num(dimstr{1});

        tmp = strcmpi('pixdim1', cell_item);
        pixdimstr = cell_item(find(tmp == 1) + 1);
        pixdim(1) = str2num(pixdimstr{1});

        tmp = strcmpi('pixdim2', cell_item);
        pixdimstr = cell_item(find(tmp == 1) + 1);
        pixdim(2) = str2num(pixdimstr{1});

        tmp = strcmpi('pixdim3', cell_item);
        pixdimstr = cell_item(find(tmp == 1) + 1);
        pixdim(3) = str2num(pixdimstr{1});

        ScanningParameters.Voxels = mat2str(dim);
        ScanningParameters.Dimensions = mat2str(pixdim);
        ScanningParameters.Volumes = num2str(Volumes);
        ScanningParameters.DataType = data_type;

        % Store the parameters to .mat file
        save(MatFile, '-struct', 'ScanningParameters');
        % Display the parameters to the text file
        fid = fopen(TxtFile, 'w');
        FieldNames = fieldnames(ScanningParameters);
        for i = 1:length(FieldNames)
            fprintf(fid, FieldNames{i});fprintf(fid, ' \t');
            fprintf(fid, ScanningParameters.(FieldNames{i}));fprintf(fid, '\n');
        end

    else
        % If the input data type is DICOM
        delete([DataRawSeq_path filesep '*nii*']);
        delete([DataRawSeq_path filesep '*bval*']);
        delete([DataRawSeq_path filesep '*bvec*']);

        DataRaw_cell = g_ls([DataRawSeq_path filesep '*']);

        % Read information of DICOM
        DICOMInfo = dicominfo(DataRaw_cell{1});
        % Name
        ScanningParameters.Name = DICOMInfo.PatientName.FamilyName;
        % Sex
        ScanningParameters.Sex = DICOMInfo.PatientSex;
        % Birth date
        ScanningParameters.BirthDate = DICOMInfo.PatientBirthDate;
        % Scanning date
        ScanningParameters.ScanningDate = DICOMInfo.AcquisitionDate;
        % Age
        BirthDateVector(1) = str2num(ScanningParameters.BirthDate(1:4));
        BirthDateVector(2) = str2num(ScanningParameters.BirthDate(5:6));
        BirthDateVector(3) = str2num(ScanningParameters.BirthDate(7:8));
        ScanningDateVector(1) = str2num(ScanningParameters.ScanningDate(1:4));
        ScanningDateVector(2) = str2num(ScanningParameters.ScanningDate(5:6));
        ScanningDateVector(3) = str2num(ScanningParameters.ScanningDate(7:8));
        ScanningParameters.Age = num2str((datenum(ScanningDateVector) - datenum(BirthDateVector))/365);
        % TR
        ScanningParameters.TR = num2str(DICOMInfo.RepetitionTime);
        % TE
        ScanningParameters.TE = num2str(DICOMInfo.EchoTime);
        % Flip angle
        ScanningParameters.FlipAngle = num2str(DICOMInfo.FlipAngle);
        % Acquisition matrix
        AcquisitionMatrix(1) = DICOMInfo.AcquisitionMatrix(1);
        AcquisitionMatrix(2) = DICOMInfo.AcquisitionMatrix(4);
        AcquisitionMatrix = reshape(AcquisitionMatrix, length(AcquisitionMatrix), 1);
        ScanningParameters.AcquisitionMatrix = mat2str(AcquisitionMatrix);
        % Slice thickness
        ScanningParameters.SliceThickness = num2str(DICOMInfo.SliceThickness);
        % Spacing between slices
        ScanningParameters.SpacingBetweenSlices = num2str(DICOMInfo.SpacingBetweenSlices);
        % Magnetic field strength
        ScanningParameters.MagneticFieldStrength = num2str(DICOMInfo.MagneticFieldStrength);
        % Resolution
        ScanningParameters.Resolution = mat2str([DICOMInfo.PixelSpacing; DICOMInfo.SliceThickness]);
        % FOV
        ScanningParameters.FOV = mat2str([DICOMInfo.PixelSpacing .* double(AcquisitionMatrix)]);

        % Store the parameters to .mat file
        save(MatFile, '-struct', 'ScanningParameters');
        % Display the parameters to the text file
        fid = fopen(TxtFile, 'w');
        FieldNames = fieldnames(ScanningParameters);
        for i = 1:length(FieldNames)
            fprintf(fid, FieldNames{i});fprintf(fid, ' \t');
            fprintf(fid, ScanningParameters.(FieldNames{i}));fprintf(fid, '\n');
        end
    end
    
catch
    
    none = 1;
    
end