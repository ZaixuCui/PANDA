function [ FileOut ] = g_OPDtrackNET_FileOut( Label_seed_fileName, JobName )
%G_PDTRACKNET_FILEOUT Summary of this function goes here
%   Detailed explanation goes here
[output_dir, b, c] = fileparts(Label_seed_fileName);
FileOut{1} = [output_dir, filesep, JobName, '.done'];
