function result_DIA_inference_struct = DIA_inference(data_name, feature_matrix, options)
%{
  feature_matrix: num_instance x num_dim
%}

addpath(genpath(pwd))

if ~exist('options', 'var')
    options = struct('k1', 8, 'k2', 5, 'num_trials', 10);
    display('--- Options for inference is not provided ---\n');
end
k1 = options.k1;
k2 = options.k2; 
num_trials = options.num_trials;

%% load semantic hierarchy and semantic path
load([data_name, '_SH_and_SP_structure.mat']); % SH_and_SP_structure
semantic_hierarchy_structure = SH_and_SP_structure.semantic_hierarchy;
semantic_path_structure = SH_and_SP_structure.semantic_path;

ancestor_cell = semantic_hierarchy_structure.ancestor_cell;
same_meaning_pair = semantic_hierarchy_structure.same_meaning_pair; 
class_name = semantic_hierarchy_structure.class_name;
weight_of_each_class = semantic_path_structure.weight_of_each_class; 

%% load the learned parameter Theta
Thete_file = dir(['result\', data_name, '\', data_name, '_Theta_*']');
load(Thete_file.name); % result_struct_Theta_obj
Theta = result_struct_Theta_obj.Theta;
S = result_struct_Theta_obj.S;

num_instance= size(feature_matrix,1);
X = single([feature_matrix'; ones(1, num_instance)./result_struct_Theta_obj.params.biasFactor]); 
logit = Theta' * X; 
qMat = exp(0.5 .* logit);

%% k-DPP sampling
label_sampling_cell = cell(num_instance, 1);
label_name_sampling_cell = cell(num_instance, 1);
for i = 1:num_instance
    qVec = qMat(:, i);
    L = ( qVec * qVec' ) .* S;

    % pick the top-K1 predicted labels according to qVec
    [~, sort_set] = sort(qVec, 'descend');
    label_pred_k1 = sort_set(1:k1); 
    label_name_pred_k1 = class_name(label_pred_k1)';
    Ly = L(label_pred_k1, label_pred_k1); 

    SH_pair = find_SH_pair(label_pred_k1, ancestor_cell);
    SM_pair = find_SM_pair(label_pred_k1, same_meaning_pair);

    % conduct num_trials to obtain different sampled subsets
    index_sampling = cell(num_trials, 1);
    label_pred_sampling = cell(num_trials, 1); 
    label_name_pred_sampling = cell(num_trials, 1); 
    weight_of_sampling = zeros(num_trials, 1); 
    for trial = 1:num_trials
        % k-DPP sampling k2 labels from k1 classes based on Ly
        index_sampling{trial} = sample_dpp_SH_SM(decompose(Ly), k2, SH_pair, SM_pair);
        subset_k2_trial = label_pred_k1(index_sampling{trial});
        label_pred_sampling{trial} = subset_k2_trial;
        label_name_pred_sampling{trial} = label_name_pred_k1(index_sampling{trial}); 
        weight_of_sampling(trial) = sum(weight_of_each_class(subset_k2_trial));
    end 

    % choose the subset with the largest weight summation
    [~, max_location] = max(weight_of_sampling); 
    label_sampling_cell{i} = label_pred_sampling{max_location};
    label_name_sampling_cell{i} = label_name_pred_sampling{max_location};
end

result_DIA_inference_struct = struct(...
    'data_name', data_name, ...
    'feat_image', feature_matrix, ...
    'sampled_label_subsets', {label_sampling_cell}, ...
    'sampled_label_names', {label_name_sampling_cell}, ...
    'options', options);

