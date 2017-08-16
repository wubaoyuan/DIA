function SM_pair = find_SM_pair(subset, same_meaning_pair)

SM_pair = [];
location = []; 
count = 1; 
for i = 1:numel(subset)
   if isempty(find(location==i)) % avoid (i,j) and (j,i) together
       index = subset(i);
       a1 = find(same_meaning_pair(:,1)==index); 
       a2 = find(same_meaning_pair(:,2)==index); 

       if ~isempty(a1)
           index_same_meaning = same_meaning_pair(a1,2);
       end

       if ~isempty(a2)
           index_same_meaning = same_meaning_pair(a2,1);
       end

       if ~isempty(a1) || ~isempty(a2)
           if ~isempty(intersect(subset, index_same_meaning))
               for j = 1:numel(index_same_meaning)
                   if ~isempty(find(subset == index_same_meaning(j)))
                       location(count) = find(subset == index_same_meaning(j));
                       tem_pair = [i, location(count)]; 
                       count = count + 1; 
                       SM_pair = [SM_pair; tem_pair]; 
                       clear tem_pair
                   end
               end
           end
       end
   end
end

end % of function