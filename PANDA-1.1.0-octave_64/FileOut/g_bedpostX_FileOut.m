function [ FileOut ] = g_bedpostX_FileOut( BedpostxFolder, BedpostXJobNum )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

FileOut{1} = [BedpostxFolder filesep 'diff_slices' filesep 'BedpostX' num2str(BedpostXJobNum) '.done'];


