%---------------------------------------
function nor_L = normalization_kDPP(L_decomposed, k)
%---------------------------------------
% compute the normalization term of k-DPP with kernel L


%---------- normalization term of k-DPP of L
% elementary symmetric polynomial of k terms
lambda = L_decomposed.D;
E = elem_sympoly(lambda,k); 
nor_L = E(end, end); 

end % of function