%---------------------------------------
function nor_L = normalization_DPP(L, k)
%---------------------------------------
% compute the normalization term of the DPP or k-DPP with kernel L

m = size(L, 1); 
if nargin == 1
    %---------- normalization term of DPP of L
    nor_L = det(L+eye(m));
else
    %---------- normalization term of k-DPP of L
    % elementary symmetric polynomial of k terms
    L_decomposed = decompose_kernel(L); 
    lambda = L_decomposed.D;
    E = elem_sympoly(lambda,k); 
    nor_L = E(end, end); 
end

end % of function