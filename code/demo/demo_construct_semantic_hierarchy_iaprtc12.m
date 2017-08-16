clear 
clear all
base_path = 'code';
chdir(base_path)
addpath(genpath(pwd))

data_name = 'iaprtc12';

%% the label hierarchy of ESP-GAME
same_meaning_pair = [
2 186; % aiplane, plane
14 230; % beach, shore
20 21; % bicycle, bike
25 95;  % bloom, flower
37 232; % bush, shrub
47 161; % centre, middle
49 141; % child, kid
%60 270; % column, tower
173 274; % pant, trousers
180 181; % people, person
213 251 % rock, stone  
];
    
directed_edges = [ 
1, 180; %adult, people
1, 181; %adult, person
3, 90; %airport, field
4, 134; %anorak, jacket
6, 233; % back, side
7, 8; %backpack, bag
10, 117; %bank, group
11, 215; %bar, room
13, 284; %bay, water
14, 99; %beach, formation
17, 15; % bedside, bed
17, 233; %bedside, side
19, 222; %bench, seat
24, 55; % blanket, cloth
29, 28; % bone, body
31, 180; %boy, people
31, 181; %boy, person
37, 187; %bush, plant
38, 187; %cactus, plant
40, 278; %canyon, valley
42, 55; % cape, cloth
44, 55; % carpet, cloth
45, 50; %cathedral, church
46, 233; %ceiling, side
46, 215; % ceiling, room
47, 5; %centre, area
48, 222; %chair, seat
49, 180; %child, people
49, 181; %child, person
50, 35; %church, building
52, 215; %classroom, room
53, 99; %cliff, formation
57, 237; % cloud, sky
58, 230; %coast, shore
59, 251; %cobblestone, stone
61, 22; %condor, bird
62, 5; %corner, area
64, 222; %couch, seat
66, 117; %couple, group
67, 215; %court, room
68, 5; %courtyard, area
69, 284; %creek, water
72, 55; % curtain, cloth
74, 180; %cyclist, people
74, 181; %cyclist, person
75, 150; %deck, level
76, 117; %desert, group
76, 83; %desert, dune
77, 259; %desk, table
81, 86; % door, entrance
83, 210; %dune, ridge
83, 220; % dune, sand
84, 153; %edge, line
85, 128; %embankment, hill
87, 28; % face, body
89, 187; %fern, plant
91, 284; %fjord, water
92, 170; %flag, ornament
94, 150; %floor, level
94, 215; % floor, room
95, 187; %flower, plant
97, 175; %footpath, path
98, 279; %forest, vegetation
100, 284; % fountain, water
102, 233; %front, side
103, 187; % fruit, plant
107, 180; %girl, people
107, 181; %girl, person
108, 99; % glacier, formation
110, 117; % grandstand, group
110, 222; % grandstand, seat
111, 187; %grass, plant
113, 213; %gravel, rock
118, 28; % hair, body
119, 63; %hall, corridor
120, 128; %hammock, hill
121, 28; % hand, body
122, 194; %harbour, port
124, 28; % head, body
125, 88; %hedge, fence
126, 188; %helmet, plate
127, 212; %highway, road
128, 99; %hill, formation
129, 153; %horizon, line
131, 35; %house, building
132, 225; %hut, shelter
133, 116; %island, ground
134, 56; % jacket, clothes
135, 55; %jean, cloth
136, 43; %jeep, car
137, 227; %jersey, shirt
139, 180; %jumper, people
139, 181; %jumper, person
140, 98; % jungle, forest
141, 180; %kid, person
141, 181; %kid, person
142, 143; %lagoon, lake
143, 284; %lake, water
147, 90; %lawn, field
147, 111; %lawn, grass
149, 28; % leg, body
159, 1; %man, adult
160, 111; %meadow, grass
160, 117; %meadow, group
161, 5; %middle, area
163, 99; %mountain, formation
164, 28; %mummy, body
165, 28; % neck, body
172, 273; %palm, tree
173, 56; % pant, clothes
175, 153; %path, line
176, 175; %pavement, path
179, 22; %penguin, bird
185, 270; %pinnacle, tower
189, 180; %player, people
189, 181; %player, person
192, 143; %pond, lake
193, 143; % pool, lake
195, 183; %portrait, picture
198, 258; %pullover, sweater
201, 101; % rack, frame
202, 153; %rail, line
205, 278; %ravine, valley
207, 187; %reed, plant
209, 35; %restaurant, building
210, 99; %ridge, formation
211, 284; %river, water
214, 35; % roof, building
215, 5; %room, area
216, 153; %rope, line
218, 35; % ruin, building
221, 284; %sea, water
222, 243; %seat, space
224, 210; % shelf, ridge
227, 56; % shirt, clothes
230, 14;% shore, beach
232, 187; %shrub, plant
235, 56; % skirt, clothes
236, 29; %skull, bone
238, 237; % skyline, sky
239, 35; %skyscraper, building
242, 55; % sock, cloth
243, 5; %space, area
244, 180; %spectator, people
244, 181; %spectator, person
247, 150; %stage, level
252, 212; %street, road
253, 170; %stripe, ornament
254, 247; %summit, stage
255, 237; % sun, sky
256, 255; % subset, sun
257, 180; %surfer, people
257, 181; %surfer, person
258, 56; % sweater, clothes
260, 55; % table-cloth, cloth
261, 117; %team, group
262, 227; % tee-shirt, shirt
264, 225; %tent, shelter
265, 5; %terrace, area
268, 180; %tourist, people
268, 181; %tourist, person
269, 55; %towel, cloth
271, 175; %trail, path
273, 187; %tree, plant
274, 56; % trouser, clothes
275, 273; %trunk, tree
276, 111; %tussock, grass
276, 117; %tussock, group
277, 56; % uniform, clothes
278, 99; %valley, formation
279, 117; %vegetation, group
279, 187; %vegetation, plant
282, 56; % waistcoat, clothes
283, 35; % wall, building
285, 284; %waterfall, water
288, 101; %window, frame
288, 283; % window, wall
289, 1; %woman, adult
];

class_name = importdata([data_name, '_dictionary.txt']);
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

% remove the repeat images
load('iaprtc12_repeat_image_structure.mat'); % iaprtc12_repeat_image_structure
repeat_index_train = iaprtc12_repeat_image_structure.train.remove_image_list;
repeat_index_test  = iaprtc12_repeat_image_structure.test.remove_image_list;
label_train_original(:, repeat_index_train) = [];
label_test_original(:, repeat_index_test) = [];

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
