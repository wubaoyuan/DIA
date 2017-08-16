function L = decompose(A)
% Computes eigenvalues and eigenvectors of A and stores the results in a
% struct.  Decomposition has fields:
%   .M = original matrix
%   .V = eigenvectors (columns)
%   .D = eigenvalues
% In summary: L.V * L.D * L.V' = L.M.

[L.V, L.D] = eig(A);
L.D = diag(L.D);

% Make sure eigenvalues are real and non-negative.
thresh = get_error_threshold(L.D);
check_imaginary_part(L.D, thresh);
L.D = real(L.D);
assert(all(L.D >= -thresh), 'PSD matrix required.');
L.D(L.D < 0) = 0;

% Make sure eigenvectors are real.
thresh = get_error_threshold(L.V);
check_imaginary_part(L.V, thresh);
L.V = real(L.V);

L.M = A;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function thresh = get_error_threshold(A)
A = abs(A(:));
vals = find(A > 1e-8);
if isempty(vals)
  thresh = 1e-3;
else
  thresh = 1e-3 * mean(A(vals));
end


function check_imaginary_part(A, thresh)
assert(all(abs(imag(A(:))) <= thresh), 'PSD matrix required.');
