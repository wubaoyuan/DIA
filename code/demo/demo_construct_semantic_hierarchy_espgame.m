clear 
clear all
base_path = 'code';
chdir(base_path)
addpath(genpath(pwd))

data_name = 'espgame';

%% the label hierarchy of ESP-GAME
same_meaning_pair = [ 1, 181; % airplane, plane
    29, 30; % book, books
    45, 106; % chart, graph
    47, 137; %child, kid
    75, 186; % dot, point
    80, 107; % earth, globe
    89, 160; % film, movie
    172, 179; %painting, picture (partially same)
    178, 179; %photo, picture (partially same)
    193, 15; %ring, band (partially same)
    196, 230; % rock, stone
    205, 231; % shop, store
    233, 15; % stripes, band (partially same)
    251, 3; % usa, america
    257, 258; % web, website
    175, 176; % people, person
    ];
    
directed_edges = [ 2, 44; % album, cd   (child, parent)
    3, 60; %  america, country
    5, 41; % anime, cartoon
    5, 218; % anime, sketch
    7, 113; % army, group
    10, 176; % asian, person
    10, 175; % asian, people  
    11, 175; % baby, people
    11, 176; % baby, person
    17, 159; % beak, mouth
    18, 4; % bear, animal
    19, 83; % beard, face
    23, 4; % bird, animal
    24, 67; % black, dark
    24, 56; % black, colors
    25, 117; % blonde, hair
    26, 56; % blue, colors
    33, 175; % boy, people
    33, 176; % boy, person
    35, 56; % brown, colors
    41, 160;  % cartoon, movie
    41, 89; % cartoon, film
    42, 37; % castle, building
    43, 4; % cat, animal
    47, 175; % child, people
    47, 176; % child, person
    48, 10; % chinese, asian
    49, 37; %church, building
    50, 170; % circle, oval
    53, 219; % cloud, sky
    55,152; % coin, metal
    55, 155; % coin, money
    59, 147; % computer, machine
    61, 84; % couple, family
    64, 113; % crowd, group
    64, 175; % crowd, people
    64, 176; % crowd, person    
    66, 9; % dance, art
    68, 201; % desert, sand
    70, 76; % diagram, drawing
    72, 4; % dog, animal
    73, 245; %doll, toy
    74, 252; % door, wall
    79, 83; % ear, face
    81, 98; % eat, food
    82, 83; % eye, face
    84, 113; % family, group
    89, 211; % film, show
    90, 118; % finger, hand
    92, 4; % fish, animal
    93, 226; % fishing, sport
    95, 198; % floor, room
    96, 183; % flower, plant
    99, 14; % football, ball
    99, 103; % football, game
    99, 226; % football, sport
    100, 247; % forest, tree
    102, 117; % fur, hair
    104, 175; % girl, people
    104, 176; % girl, person
    108, 56; % gold, colors
    108, 152; % gold, metal    
    110, 183; % grass, plant
    111, 56; % gray, colors   
    112, 56; %green, colors
    116, 150; % guy, man
    118, 6;% hand, arm
    127, 4; % horse, animal
    129, 125; % house, home
    129, 37; % house, building
    130, 255; % ice, water
    132, 4; % insect, animal
    134, 54; % jacket, coat
    135, 10; % japanese, asian
    137, 175; % kid, people 
    137, 176; % kid, person
    138, 263; % lady, woman
    139, 255; % lake, water
    140, 183; % leaf, plant
    142, 265; % letter, word
    145, 159; % lip, mouth
    148, 29; % magazine, booktower
    148, 30; % magazine, books
    150, 175; % man, people  
    150, 176; % man, person
    158, 4; % mouse, animal
    159, 83; % mouth, face
    160, 211; % movie, show
    164, 83; % nose, face
    166, 255; % ocean, water
    169, 56; % orange, colors
    171, 173; % page, paper
    172, 9; % painting, art
    174, 113; % party, group
    180, 56; % pink, colors
    190, 56; %purple, colors
    192, 56; % red, colors
    194, 255; % river, water
    197, 37; % roof, building
    198, 129; % room, house
    204, 255; % sea, water
    205, 67; % shadow, dark
    213, 152; % silver, metal
    214, 161; % sing, music
    215, 161; % singer, music
    215, 175; % singer, people    
    215, 176; % singer, person
    221, 83; % smile, face
    223, 255; % snow, water
    224, 175; % soldier, people  
    224, 176; % soldier, person
    227, 51; % square, city
    229, 9; % statue, art
    235, 228; % sun, star
    232, 195; % street, road
    234, 77; % suit, dress    
    236, 226; % swim, sport
    240, 159; % teeth, mouth
    247, 183; % tree, plant
    250, 203; % tv, screen
    251, 60; % usa, country
    252, 37; % wall, building
    260, 56; % white, colors
    261, 252; % window, wall
    262, 23; % wing, bird
    263, 175; % woman, people   
    263, 176; % woman, person
    265, 267; % word, writing
    268, 56 % yellow, colors
    ];

class_name = importdata('espgame_dictionary.txt')';
num_class = numel(class_name); 

%% the parent_matrix and ancestor_matrix
numEdges = size(directed_edges,1); % 129 edges
parent_matrix = zeros(num_class, num_class);
for i = 1:numEdges
    parent_matrix(directed_edges(i,1),directed_edges(i,2)) = 1;
end
%view(biograph(parent_matrix', class_name))

ancestor_matrix = zeros(num_class, num_class);
for i = 1:num_class
    ac_i = parent_transfer(parent_matrix, i);
    no_pa = length(ac_i);
    ac_j = cell(no_pa, 1);
    for j = 1:no_pa
        ac_j{j} = parent_transfer(parent_matrix, ac_i(j));
    end
    ac_complete = unique( [ac_i, [ac_j{:}] ] );
    ancestor_matrix(i, ac_complete) = 1;
end

ancestor_cell = cell(num_class, 1);
descendant_cell = cell(num_class, 1);
for i = 1:num_class
   ancestor_cell{i} = find(ancestor_matrix(i,:)==1); 
   descendant_cell{i} = find(ancestor_matrix(:,i)==1); 
end

%% nodes_structure
single_class_set = [];
root_class_set = [];
leaf_class_set = [];
median_class_set = [];
for i = 1:num_class
   ancestor_i = ancestor_cell{i};
   child_i = descendant_cell{i}; 
   if isempty(ancestor_i) && isempty(child_i)
       single_class_set = [single_class_set, i];
   elseif isempty(ancestor_i) && ~isempty(child_i)
       root_class_set = [root_class_set, i];
   elseif ~isempty(ancestor_i) && isempty(child_i)
       leaf_class_set = [leaf_class_set, i];
   else
       median_class_set = [median_class_set, i]; 
   end
end

nodes_structure = struct('single', single_class_set, ...
                         'root', root_class_set, ...   
                         'median', median_class_set, ...
                         'leaf', leaf_class_set);

%% read the original ground-truth label matrix, 268 classes
label_train_original=double(vec_read([data_name, '_train_annot.hvecs']))';
label_test_original =double(vec_read([data_name, '_test_annot.hvecs']))';

[~, num_sample_train] = size(label_train_original);
[~, num_sample_test] = size(label_test_original);

% complete the label matrix according to the label hierarchy
label_train_full = label_train_original; 
label_test_full = label_test_original; 
for i = 1:num_class
    ancestor_i = ancestor_cell{i};

    sample_i_train = find(label_train_original(i,:)==1);
    label_train_full(ancestor_i, sample_i_train) = 1;
    
    sample_i_test = find(label_test_original(i,:)==1);
    label_test_full(ancestor_i, sample_i_test) = 1;
end

%% summarization and save                
semantic_hierarchy_structure = struct('data_name', data_name, ...
    'class_name', {class_name}, ...
    'directed_edges', directed_edges, ...
    'parent_matrix', parent_matrix, ...
    'ancestor_cell', {ancestor_cell}, ...
    'descendant_cell', {descendant_cell}, ...
    'same_meaning_pair', same_meaning_pair, ...
    'nodes_structure', nodes_structure, ...
    'label_train_SH_augmented', sparse(label_train_full), ...
    'label_test_SH_augmented', sparse(label_test_full) ); 

save_path = fullfile(base_path, 'data', data_name); 
save(fullfile(save_path, [data_name, '_semantic_hierarchy_structure']), 'semantic_hierarchy_structure'); 


%% load the semantic hierarchy structure and display it
load(fullfile(save_path, [data_name, '_hierarchy_structure.mat']))
parent_matrix = semantic_hierarchy_structure.parent_matrix; 
class_name = semantic_hierarchy_structure.class_name; 
view(biograph(parent_matrix',class_name))
