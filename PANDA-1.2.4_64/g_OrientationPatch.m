function g_OrientationPatch(BvecsFileCell, Inversion, Swap)
%
%__________________________________________________________________________
% SUMMARY OF G_OPDTRACKNETPRE
%
% Invert and swap b-vectors.
%
% SYNTAX:
%
% 1) g_OrientationPatch(BvecsFileCell, Inversion, Swap)
%__________________________________________________________________________
% INPUTS:
%
% BVECSFILECELL
%        (cell of strings) 
%        Each of the cell is the full path of the b-vector file.
%        
% INVERSION
%        (string, default 'No Inversion')
%        Four selections: 'No Inversion'
%                         'Invert X'
%                         'Invert Y'
%                         'Invert Z'.
%
% SWAP
%        (string, default 'No Swap')
%        Four selections: 'No Swap' 
%                         'Swap X/Y'  
%                         'Swap Y/Z'
%                         'Swap Z/X'.
%__________________________________________________________________________
% OUTPUTS:
%
% The bvectors after inversion and swap.       
%__________________________________________________________________________
% COMMENTS:
%
% Copyright (c) Gaolang Gong, Zaixu Cui, State Key Laboratory of Cognitive
% Neuroscience and Learning, Beijing Normal University, 2011.
% Maintainer: zaixucui@gmail.com
% See licensing information in the code
% keywords: bvector, inversion, swap

% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documation files, to deal in the
% Software without restriction, including without limitation the rights to
% use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

for i = 1:length(BvecsFileCell)
    
    Bvecs = load(BvecsFileCell{i});
    
    if strcmp(Inversion, 'Invert X')
        Bvecs(1, :) = -Bvecs(1, :);
    elseif strcmp(Inversion, 'Invert Y')
        Bvecs(2, :) = -Bvecs(2, :);
    elseif strcmp(Inversion, 'Invert Z')
        Bvecs(3, :) = -Bvecs(3, :);
    end
    
    if strcmp(Swap, 'Swap X/Y')
        tmp = Bvecs(1, :);
        Bvecs(1, :) = Bvecs(2, :); % Y -> X
        Bvecs(2, :) = tmp;         % X -> Y
    elseif strcmp(Swap, 'Swap Y/Z')
        tmp = Bvecs(2, :);
        Bvecs(2, :) = Bvecs(3, :); % Z -> Y
        Bvecs(3, :) = tmp;         % Y -> Z
    elseif strcmp(Swap, 'Swap Z/X')
        tmp = Bvecs(3, :);
        Bvecs(3, :) = Bvecs(1, :); % X -> Z
        Bvecs(1, :) = tmp;         % Z -> X
    end 
    
    save(BvecsFileCell{i}, 'Bvecs', '-ascii');
    
    [BvecsParentFolder, BvecsFileName, z] = fileparts(BvecsFileCell{i});
    system(['cp ' BvecsFileCell{i} ' ' BvecsParentFolder filesep BvecsFileName '_Orientation']);
end
