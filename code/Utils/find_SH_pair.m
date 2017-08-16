function SH_pair = find_SH_pair(subset, ancestor_cell)

SH_pair = [];
for i = 1:numel(subset)
   index = subset(i); 
   ancestor_index = ancestor_cell{index}; 
   ancestor_in_subset = intersect(ancestor_index, subset); 
   if ~isempty(ancestor_in_subset)
       num_ancestor = numel(ancestor_in_subset); 
       location = zeros(num_ancestor, 1);
       for j = 1:num_ancestor
          location(j) = find(subset == ancestor_in_subset(j)); 
       end
       SH_pair_index = [i .* ones(num_ancestor, 1), location];
       SH_pair = [SH_pair; SH_pair_index]; 
   end
end

end