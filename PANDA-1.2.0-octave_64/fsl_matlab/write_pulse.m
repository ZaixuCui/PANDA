function write_pulse(fname,mat)
% WRITE_PULSE(fname,mat)
%
%  write a matrix (mat) to a file in the binary format written by
%  write_binary_matrix() in miscmaths (FSL library)
%
%  See also: read_pulse (for binary matrices), save (for ascii matrices)

magicnumber=42;
dummy=0;
[nrows ncols]=size(mat);

% open file and write contents (with native endian-ness)
fp=fopen(fname,'w');
fwrite(fp,magicnumber,'uint32');
fwrite(fp,dummy,'uint32');
fwrite(fp,nrows,'uint32');
fwrite(fp,ncols,'uint32');
fwrite(fp,mat,'double');
fclose(fp);
