    
function SequenceNum = g_Calculate_Sequence( DataRaw_folder_path,i )

DataRawtmp = dir([DataRaw_folder_path,filesep,'*']);
DataRaw = DataRawtmp(3:end);
% check if containing dicoms or subdirectory
isdir = g_struc2array(DataRaw, {'isdir'});
if isempty(find(isdir == 1));
    DataNum = length(DataRaw);
    for j = 1:DataNum
        Dicominfotmp = dicominfo([DataRaw_folder_path,filesep,DataRaw(j).name]);
        Indextmp = ['0000',int2str(Dicominfotmp.SeriesNumber)];
        DataRawSeq_name = [DataRaw_folder_path,filesep,Indextmp(end-3:end),'_DTISeries'];%,Dicominfotmp.SeriesDescription];%Dicominfotmp.ProtocolName];
        if ~exist(DataRawSeq_name, 'dir')
            mkdir(DataRawSeq_name);
        end
        movefile([DataRaw_folder_path,filesep,DataRaw(j).name],DataRawSeq_name);
    end
end 

DataRawSeq_cell = g_ls(cat(2, DataRaw_folder_path, '/*/'),'d');
SequenceNum = length(DataRawSeq_cell);


