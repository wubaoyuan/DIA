
function ac_i = parent_transfer(parent_matrix, i)

ac_i=[];
parent_node_i = find(parent_matrix(i,:)==1);
ac_i = [ac_i, parent_node_i];
t=1;
while t<size(parent_matrix,1)
    parent_no = length(parent_node_i);
    %parent_node_i_cell = cell(1,parent_no);
    parent_node_i_new = [];
    for j = 1:parent_no
%         parent_node_i_cell(j) = find(parent_matrix(parent_node_i(j),:)==1);
        parent_node_i_new = [parent_node_i_new, find(parent_matrix(parent_node_i(j),:)==1)];
    end
   ac_i = [ac_i, parent_node_i_new];
   if length(parent_node_i_new)>0
       t = t+1;
       parent_node_i = parent_node_i_new;
   else
       break;
   end
end
