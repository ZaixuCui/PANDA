function [ FileOut ] = g_bedpostx_FileOut( NativeFolderPath, Fibers )
%G_BEDPOSTX_FILEOUT Summary of this function goes here
%   Detailed explanation goes here
FileOut{1} = [ NativeFolderPath '.bedpostX ' filesep 'xfms' filesep 'eye.mat'];

