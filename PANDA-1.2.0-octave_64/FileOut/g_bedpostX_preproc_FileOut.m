function [ FileOut ] = g_bedpostX_preproc_FileOut( NativeFolder )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
BedpostXFolder = [NativeFolder '.bedpostX'];
FileOut{1} = [BedpostXFolder filesep 'bvals'];
FileOut{2} = [BedpostXFolder filesep 'bvecs'];
FileOut{3} = [BedpostXFolder filesep 'nodif_brain_mask.nii.gz'];
FileOut{4} = [BedpostXFolder filesep 'diff_slices' filesep 'DataSlice.done'];
FileOut{5} = [BedpostXFolder filesep 'diff_slices' filesep 'MaskSlice.done'];

