function [ filenames ] = g_ls(input, directory_flag)

none = 0;
if nargin < 2; 
    try
        txt = ls(input, '-x');
    catch
        none = 1;
    end
else
    try
        txt = ls(input, '-dx');
    catch 
        none = 1;
    end
end

if none == 0
    index = isspace(txt);
    space_index = find(index == 1);
    end_index = space_index - 1;
    start_index = space_index + 1;
    start_index(length(start_index)) = [];
    start_index = [1,start_index];
    j = 1;
    for i = 1:length(start_index)
        if start_index(i) < end_index(i)
            filenames{j,1} = txt(start_index(i):end_index(i));
            j = j + 1;
        end
    end
else
    filenames = '';
end



