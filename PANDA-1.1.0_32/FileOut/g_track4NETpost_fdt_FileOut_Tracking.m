function [ FileOut ] = g_track4NETpost_fdt_FileOut_Tracking( NativeFolder, Prefix )
%G_TRACK4NETPOST_FDT_FILEOUT_TRACKING Summary of this function goes here
%   Detailed explanation goes here
[SubjectFolder, b, c] = fileparts(NativeFolder);
FileOut{1} = [ SubjectFolder filesep 'Network' filesep 'Probabilistic' filesep Prefix '_ProbabilisticMatrix.mat' ];


