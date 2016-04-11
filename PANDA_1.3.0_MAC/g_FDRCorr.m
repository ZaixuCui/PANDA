
function [Pthreshold RetainID] = g_FDRCorr(PValues, q)

% FDR correction
%    First, sort p values ascending
%    Second, select the biggest positive integer 'i', p_sort(i) <= (i * q) / m,
%            p_sort(1), p_sort(2), ..., p_sort(i) are significant after correction

[PValuesRanking OriginPos] = sort(PValues, 2, 'ascend');
FeatureQuantity = length(PValuesRanking);
Subscripts = [1 : FeatureQuantity];
Pthreshold = PValuesRanking(find(PValuesRanking <= (Subscripts * q) / FeatureQuantity, 1, 'last'));
RetainID = find(PValues <= Pthreshold);



