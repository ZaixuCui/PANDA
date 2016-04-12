function [ filenames ] = g_ls(input, directory_flag)
%-------------------------------------------------------------------------- 
%	Copyright(c) 2011
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Zaixu Cui, Gaolang Gong
%	Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%                    <a href="gaolang.gong@gmail.com">gaolang.gong@gmail.com</a>
%--------------------------------------------------------------------------
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
    [row, column] = size(txt);
    for i = 1:row
        for j = 1:column
            filenames{i}(j) = txt(i,j);
        end
    end
    if ~isempty(filenames)
        filenames = reshape(filenames, length(filenames), 1);
    end
else
    filenames = '';
end





