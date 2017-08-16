%--------------------------------------------------------------------------
function [precision, recall, F1] = DIA_evaluation(data_name, ...
             predicted_subset, gt_subset)
%--------------------------------------------------------------------------

%{
  This function evaluate the label prediction by precision, recall and F1
  based on the ground-truth semantic paths of one instance
  the prediction score of each semantic path could be [0, 1]
  we compute the score of each label in each semantic path
  then the largest label score in this path will be the path score
%}

addpath(genpath(pwd))

load([data_name, '_SH_and_SP_structure.mat']); % SH_and_SP_structure

[path_cell_of_gt_subset, weight_cell_of_gt_subset] = ...
    find_path_and_weight_of_subset(gt_subset, SH_and_SP_structure);
[path_cell_of_pred_subset, ~] = ...
    find_path_and_weight_of_subset(predicted_subset, SH_and_SP_structure);

num_gt_path = numel(path_cell_of_gt_subset); 
num_pred_path = numel(path_cell_of_pred_subset); 
num_pred_labels = numel(predicted_subset);

score_cell = cell(1, num_gt_path);
for i = 1:num_pred_labels
    ci = predicted_subset(i);
    for j = 1:num_gt_path
        path_j = path_cell_of_gt_subset{j}; 
        weight_path_j = weight_cell_of_gt_subset{j}; 
        location_ci_in_path_j = find(path_j == ci); 
        if ~isempty(location_ci_in_path_j)
            score_cell{j} = [score_cell{j}, weight_path_j(location_ci_in_path_j)]; 
        end
    end
end

score_vec = zeros(1, num_gt_path);
for j = 1:num_gt_path
    if ~isempty(score_cell{j})
        score_vec(j) = max(score_cell{j}); 
    end
end

sum_score = sum(score_vec);
precision = sum_score / (num_pred_path + eps); 
recall =  sum_score / (num_gt_path + eps); 
F1 = 2 * precision * recall / (precision + recall + eps); 
end % of function 