%--------------------------------------------------------------------------
function output = negative_log_dpp_loss(X, Y, Theta, S, mode)
%--------------------------------------------------------------------------

% This function implemented the pairwise loss, used for multi-label learning
% 
% X -- dataset matrix
% Y -- label matrix
% Theta -- parameter matrix
% S -- similarity matrix between classes
% mode -- {'objective', 'gradient'}
%
% Obj = 1/n * \sum_t^n -\log( det(Ly(x_t; Theta)) / det(L(x_t; Theta)+I) ) 
%
% L_{i,j}(x_t; Theta) = q_i(x_t) * phi_i(x_t)' * phi_i(x_t) * q_i(x_t)
% q_i(x_t) = exp(0.5 * Theta_i' * x_t)
% S(x_t) = phi_i(x_t) * phi_i(x_t)' % here we use constant S for all x_t
%
% gradient(Theta_i) = 1/n * sum_t^n (Kii(x_t) - I(i \in Y_t)) .* X(:,t)
%
% Kii(x_t) = \sum_{j}^m v_j(i)^2 * (lambda_j / (1+lambda_j))
% L(x_t; Theta) = \sum_{j}^m lambda_j .* v_j * v_j' 
% v_j is the j-th eigenvector of L(x_t; Theta), 
% and lambda_j is the eigenvalue

% if ~exist('usingClassWeight', 'var')
%     usingClassWeight = true;
% end
% 
% if usingClassWeight
%     W = compute_label_cost_matrix(Y);
% else
%     W = ones(size(Y));
% end


[numDimension, numClass] = size(Theta);
numInstance = size(X, 2);
I = sparse(eye(numClass));

logitMat = Theta' * X; 
qMat = exp(0.5 .* logitMat);
gradMat = zeros([numDimension, numClass, numInstance]);
objVec = zeros(1, numInstance);
if strcmp(mode, 'objective')
    
    %--------------  compute the objective function, forward
    for t = 1 : numInstance
        qVec = double(qMat(:, t));
        qVec = min(100, qVec);
        yt = Y(:,t) == 1; 
        L = (qVec * qVec') .* S; % m x m, the kernel matrix L
        Ly = L(yt , yt);
        objVec(t) = -log( det(Ly) / det(L + I) + 1e-100.* eps );
    end
    output = mean(objVec);
    
elseif strcmp(mode, 'gradient')
    
    %--------------  compute the gradient over Theta, backward
    for t = 1 : numInstance
        qVec = qMat(:, t);
        qVec = min(100, qVec);
        L = (qVec * qVec') .* S; % m x m, the kernel matrix
        [V,D] = eig(L);
        d = real(diag(D)); % m x 1 

        % 1 x m, Kii for each class
        Kii_vec = arrayfun(@(i) V(i, :).^2 * (d./(1+d)), 1:numClass);
        gradMat(:,:,t) = X(:,t) * (Kii_vec - Y(:,t)');  
    end
    output = sum(gradMat, 3)./numInstance;
end

end % of function 


