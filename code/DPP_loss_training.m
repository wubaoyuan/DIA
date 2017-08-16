%--------------------------------------------------------------------------
function DPP_loss_training(data_name, params)
%--------------------------------------------------------------------------

%addpath(genpath(pwd))

%% default params
initial_params = struct('batch_size',1024, 'lr_0',1e0, 'lr_gap',5e1, ...
    'lr_decreasing', 0.98, 'momentum', 0.9, 'maxIter', 2e0, ...
    'weightDecay', 1e-4, 'biasFactor', 80, 'threshold', 1e-8);

if ~exist('params','var'), 
    params = []; 
    display('--- WARNING: params not provided ---\n')
end
param_names = fieldnames(initial_params);
for p = 1:numel(param_names)    
    if ~isfield(params,param_names(p))
        params.(param_names{p}) = initial_params.(param_names{p});
    end
end

%% load data
load(strcat(data_name, '_semantic_hierarchy_structure'));
label_train = full(semantic_hierarchy_structure.label_train_SH_augmented);
num_class = size(label_train,1);
dataset_train= dlmread([data_name, '_data_vggf_pca_train.txt'])'; 
[num_dimension, num_sample_train] = size(dataset_train);

% load S matrix, computed based on GloVe of classes
load(['S_psd_gloVe_', data_name, '.mat']); % S

%% learning
Theta_0 = randn(num_dimension+1, num_class)./ (num_dimension+1);  
X_train = single([dataset_train; ones(1, num_sample_train)./params.biasFactor]); 
[Theta_new, Theta_struct, obj_curve] = ...
          main_training(Theta_0, X_train, label_train, S, params);

result_struct_Theta_obj = struct(...
          'Theta', single(Theta_new), ...
          'Theta_struct', Theta_struct, ...
          'obj_curve', obj_curve, ...
          'S', S, ...
          'params', params);    

%% save results                             
result_path = fullfile('./result', data_name);  
if ~exist(result_path), mkdir(result_path); end
result_name = sprintf([data_name, '_Theta_', ...
                      'bs_%d_lr0_%1.2f_lrGap_%d_', ...
                      'lrDec_%1.2f_moment_%1.1f_iter_%d_', ...
                      'decay_%1.4f_biasF_%d.mat'], ...
                      params.batch_size, ...
                      params.lr_0, ...
                      params.lr_gap, ...
                      params.lr_decreasing, ...
                      params.momentum, ...
                      params.maxIter, ...
                      params.weightDecay, ...
                      params.biasFactor ...
                     );
save(fullfile(result_path, result_name), 'result_struct_Theta_obj'); 
display('--- The learned model has been saved ---\n')
end % of function

%--------------------------------------------------------------------------
function [Theta_new, Theta_struct, obj_curve] = main_training(Theta_0, X, Y, S, params)
%--------------------------------------------------------------------------

% Given S, learn the quality parameters

% X,  d x N matrix, each column is the feature vector of one instance
% Y,  m x N matrix, each column is the label vector of one instance, {0, 1}
% S,  m x m matrix, the diversity (similarity) matrix
% Theta, d x m matrix, each column is the parameter vector of one class

% for reproduciable
rng('default')

batch_size = params.batch_size;
lr = params.lr_0;
lr_gap = params.lr_gap;
lr_decreasing = params.lr_decreasing;
momentum = params.momentum; 
threshold = params.threshold;
maxIter = params.maxIter;
eta = params.weightDecay;

[num_dimension, num_class] = size(Theta_0); % i.e., m
numInstance = size(X, 2); % i.e., N

obj_curve = zeros(maxIter, 1);
Theta_old = Theta_0;
Theta_struct = struct('Theta', repmat({[]}, fix(maxIter/50) + 1, 1), ...
                      'iter', repmat({[]}, fix(maxIter/50) + 1, 1));
t = 1; 
Theta_struct(t).Theta = single(Theta_0);
Theta_struct(t).iter = 0; 
momentum_gradient = zeros(size(Theta_old));
for iter = 1:maxIter
    tic
    Theta = Theta_old;
    
    % determine the batch
    batch_instance_index = randperm(numInstance, batch_size); 
    X_batch = X(:, batch_instance_index);
    Y_batch = Y(:, batch_instance_index);
    
    % backward, update theta
    [Theta, momentum_gradient] = update_Theta(Theta, X_batch, ...
            Y_batch, S, eta, lr, momentum, momentum_gradient);
                          
    % forward, compute objective
    obj_curve(iter) = obj_computation(Theta, X_batch, Y_batch, S, eta); 
    runtime =  toc;  
   
    fprintf(['=====  iter = [%3d]: obj = %1.4f, ', ...
            'runtime = %1.3f, alpha = %1.3f ===== \n'], ... 
             iter, obj_curve(iter), runtime, lr) ;
    
    % save Theta every 50 iterations
    if ~mod(iter,50)
        Theta_struct(t+1).Theta = single(Theta);
        Theta_struct(t+1).iter = iter; 
        t = t+1; 
    end
    
    % check convergence
    change_of_Theta = norm(Theta - Theta_old, 'fro') / (num_dimension * num_class);
    if change_of_Theta < threshold
        break;
    else
        Theta_old = Theta;
        if mod(iter, lr_gap) == 0
            lr = lr * lr_decreasing;
        end
    end 
end

Theta_new = Theta;
end % of function


%--------------------------------------------------------------------------
function [Theta, momentum_gradient] = update_Theta(...
         Theta, X, Y, S, eta, lr, momentum, momentum_gradient)
%--------------------------------------------------------------------------
grad_DPP = negative_log_dpp_loss(X, Y, Theta, S, 'gradient');
gradient = grad_DPP + eta .* Theta;
momentum_gradient = momentum .* momentum_gradient - lr .* gradient;
Theta = Theta + momentum_gradient;
end % of function


%--------------------------------------------------------------------------
function obj = obj_computation(Theta, X, Y, S, eta)
%--------------------------------------------------------------------------
obj_DPP = negative_log_dpp_loss(X, Y, Theta, S, 'objective');
obj = obj_DPP + 0.5 * eta * norm(Theta, 'fro')^2;
end % of function

