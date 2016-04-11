function [ FolderFileList ] = g_ls(input)

% Replace string '//', '///', ... with '/'
tmp = input;
input = '';
input(1) = tmp(1);
m = 1;
for i = 2:length(tmp)
    if tmp(i) == filesep & tmp(i - 1) == filesep
        continue;
    else
        m = m + 1;
        input(m) = tmp(i);
    end
end

% Separate the path
SeprateLocations = find(input == filesep);
SeprateQuantity = length(SeprateLocations);
for i = 1:SeprateQuantity - 1
    PathUnits{i} = input(SeprateLocations(i) + 1:SeprateLocations(i + 1) - 1);
end
if input(end) ~= filesep
    PathUnits{SeprateQuantity} = input(SeprateLocations(SeprateQuantity) + 1:end);
end

% Initialize the Result folders & files List
FolderFileList{1} = filesep;

% Get all the folders & files user needs
for i = 1:length(PathUnits)
    % Seek all the index of '*'
    StarSymbolIndex = find(PathUnits{i} == '*');
    StarSymbolQuantity = length(StarSymbolIndex);
           
    if ~StarSymbolQuantity
        for j = 1:length(FolderFileList)
            if FolderFileList{j} == filesep
                FolderFileList{j} = [FolderFileList{j} PathUnits{i}];
            else
                FolderFileList{j} = [FolderFileList{j} filesep PathUnits{i}];
            end
        end
    else
        WholeSubDirFile = [];
        Quantity = 0;
        for j = 1:length(FolderFileList)
        % Search all the subfolders and subfiles that meet the rule of PathUnits{i}

            % Seek all the subfolders and subfiles under the folders of FoldersList
            SubDirFile = [];
            if isdir(FolderFileList{j})
                SubDirFile = dir(FolderFileList{j});
                SubDirFile = {SubDirFile.name};
            end

            % Judge whether the folder & file in WholeSubDirFile meet the rule of PathUnits{i}
            for m = 1:length(SubDirFile)
                if ~StarSymbolQuantity
                    % No star symbol
                    if ~strcmp(SubDirFile{m}, PathUnits{i})
                        SubDirFile{m} = '';
                    end
                else
                    if PathUnits{i}(1) ~= '*'
                        Prefix = PathUnits{i}(1:StarSymbolIndex(1) - 1);
                        if length(SubDirFile{m}) >= length(Prefix)
                            if ~strcmp(Prefix, SubDirFile{m}(1:length(Prefix)))
                                SubDirFile{m} = '';
                            end
                        else
                            SubDirFile{m} = '';
                        end
                    end
                    if PathUnits{i}(end) ~= '*'
                        Suffix = PathUnits{i}(StarSymbolIndex(end) + 1:end);
                        if length(SubDirFile{m}) >= length(Suffix)
                            if ~strcmp(Suffix, SubDirFile{m}(end - length(Suffix) + 1:end))
                                SubDirFile{m} = '';
                            end
                        else
                            SubDirFile{m} = '';
                        end
                    end

                    for t = 1:StarSymbolQuantity - 1
                        Unit = PathUnits{i}(StarSymbolIndex(t) + 1:StarSymbolIndex(t + 1) - 1);
                        if isempty(findstr(SubDirFile{m}, Unit))
                            SubDirFile{m} = '';
                        end
                    end
                end

                if ~isempty(SubDirFile{m})
                    if ~strcmp(SubDirFile{m}, '.') & ~strcmp(SubDirFile{m}, '..')
                        Quantity = Quantity + 1;
                        if strcmp(FolderFileList{j}, filesep)
                            SubDirFile{m} = [FolderFileList{j} SubDirFile{m}];
                            WholeSubDirFile{Quantity} = SubDirFile{m};
                        else
                            SubDirFile{m} = [FolderFileList{j} filesep SubDirFile{m}];
                            WholeSubDirFile{Quantity} = SubDirFile{m};
                        end
                    end
                end
            end  
        end
        FolderFileList = WholeSubDirFile;
    end
end

if input(end) == filesep
    tmp = FolderFileList;
    FolderFileList = '';
    j = 0;
    for i = 1:length(tmp)
        if isdir(tmp{i})
            j = j + 1;
            FolderFileList{j} = tmp{i};
        end
    end
end

FolderFileList = reshape(FolderFileList, length(FolderFileList), 1);





