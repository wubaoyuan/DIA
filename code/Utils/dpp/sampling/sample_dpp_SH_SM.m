function Y = sample_dpp_SH_SM(L,k, SH_pair, SM_pair)
% sample a set Y from a dpp.  L is a decomposed kernel, 
% and k is (optionally) the size of the set to return.

num_class = size(L.V,1); 
if ~exist('SH_pair','var') || numel(SH_pair)==0
    ancestor_cell = {};
    child_cell = {};
else
    [ancestor_cell, child_cell] = change_SHpair_to_cell(SH_pair, num_class); 
end

if ~exist('SM_pair','var') || numel(SM_pair)==0
    SM_cell = {};
else
    SM_cell = change_SMpair_to_cell(SM_pair, num_class); 
end

% Y = sample_dpp_SH_SM_cell(L, k, ancestor_cell, child_cell, SM_cell)

if ~exist('k','var')  
  % choose eigenvectors randomly
  D = L.D ./ (1+L.D);
  v = find(rand(length(D),1) <= D);
else
  % k-DPP
  v = sample_k(L.D,k);
end
k = length(v);    
V = L.V(:,v);

% iterate
Y = zeros(k,1);
ancestor_vec = [];
child_vec = [];
SM_vec = []; 
for i = k:-1:1
  
  % compute probabilities for each item
  P = sum(V.^2,2);
  P = P / sum(P);
  
  P(ancestor_vec) = 0;
  P(child_vec) = 0;
  P(SM_vec) = 0;
  Y_valid = Y(Y>0)';
  P(Y_valid) = 0; 
%   if ~isempty([ancestor_vec, child_vec, Y_valid])
%      % set the probabilities of all ancestors 
%      % and children of existing items/classes as 0
%      P([ancestor_vec, child_vec, Y_valid]) = 0; 
%   end
  if sum(P) == 0
      break;
  else
      P = P / sum(P);
  end

  %--------------- choose a new item to include
  % since sometimes it gives an empty item,
  % we try 3 times until get a new item
  trial = 1; 
  while trial <= 3
      new_item = find(rand <= cumsum(P),1);
      if ~isempty(new_item)
           Y(i) = new_item;
           trial = 4; 
      else
          Y(i) = -1; 
          trial = trial + 1; 
          % continue; 
      end
  end
  if Y(i) == -1, 
      continue; 
  end
  
  % add new ancestors and children
  if ~isempty(ancestor_cell)
      ancestor_vec = [ancestor_vec, ancestor_cell{Y(i)}'];
  end
  if ~isempty(child_cell)
      child_vec = [child_vec, child_cell{Y(i)}'];
  end
  if ~isempty(SM_cell)
      SM_vec = [SM_vec, SM_cell{Y(i)}];
  end

  % choose a vector to eliminate
  j = find(V(Y(i),:),1);
  Vj = V(:,j);
  V = V(:,[1:j-1 j+1:end]);

  % update V
  V = V - bsxfun(@times,Vj,V(Y(i),:)/Vj(Y(i)));

  % orthogonalize
  for a = 1:i-1
    for b = 1:a-1
      V(:,a) = V(:,a) - V(:,a)'*V(:,b)*V(:,b);
    end
    V(:,a) = V(:,a) / norm(V(:,a));
  end

end

Y(Y<=0) = []; 
Y = fliplr(Y); % flip the order, to follow the sampling order 


end % of function 

function [ancestor_cell, child_cell] = change_SHpair_to_cell(SH_pair, num_class)
 
ancestor_cell = cell(num_class, 1);
child_cell = cell(num_class, 1);
for i = 1:num_class
    location_i_as_child = find(SH_pair(:,1)==i); 
    if ~isempty(location_i_as_child)
        ancestor_cell{i} = SH_pair(location_i_as_child,2);
    end
    
    location_i_as_ancestor = find(SH_pair(:,2)==i); 
    if ~isempty(location_i_as_ancestor)
        child_cell{i} = SH_pair(location_i_as_ancestor,1);
    end
end

end % of function

function SM_cell = change_SMpair_to_cell(SM_pair, num_class)

SM_cell = cell(num_class, 1);
for i = 1:num_class
    location_i_in_col1 = find(SM_pair(:,1)==i);
    location_i_in_col2 = find(SM_pair(:,2)==i);
    tem = [];
    if ~isempty(location_i_in_col1)
        tem = [tem; SM_pair(location_i_in_col1, 2)];
    end
    if ~isempty(location_i_in_col2)
        tem = [tem; SM_pair(location_i_in_col2, 1)];
    end
    SM_cell{i} = tem; 
end

end % of function
