function [ FileOut ] = g_track4NETpost_fdt_FileOut( NativePathFolder, Prefix, ProbabilisticNetworkPostJobNum )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[SubjectFolder, b, c] = fileparts(NativePathFolder);
FileOut{1} = [ SubjectFolder filesep 'Network' filesep 'Probabilistic' filesep 'tmp' filesep Prefix '_ProbabilisticMatrix_' num2str(ProbabilisticNetworkPostJobNum, '%2d') '.mat' ];



