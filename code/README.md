This folder includes all required datas and codes to implement the proposed method in "Diverse Image Annotation". 

Usage
----
#### Step 1: 
Unzip the data.zip

#### Step 2: 
Start MATLAB, and run the following demo. This demo will show you how to do training, inference and evaluation based on our model. 
```
run('demo/demo_main.m')
```

#### Step 3:
Since the semantic hierarchy (SH) and the weighted semantic paths (SP) play important roles in our model, we also provide demos to 
introduce how to derive them. Following the demos, you can easily obtain the SH and SP of your own multi-label datasets. 
In the folder ```demo/```, there are four demos corresponding to two datasets ```espgame``` and ```iaprtc12```. Let's take the espgame demo 
as example, 
```
1) 'demo_construct_semantic_hierarchy_espgame.m' will show you how to generate the semantic hiearchy structure, 
that will be used in our codes. However, there are two manual and dataset-dependent inputs: 'same_meaning_pair' 
(i.e., synonyms, see Line 10) and 'directed_edges' (i.e., semantic relationship between child and parent, see 
Line 28). You can explore this two inputs from WordNet, based on all candidate classes of your own datasets. 

2) 'demo_construct_semantic_path_espgame.m' will show you how to generate the weighted semantic paths of the set 
of all candidate classes, and the weighted semantic paths of the ground-truth tag subset of each instance, 
according to the semantic hiearchy. Similarly, there are also two manual inputs, 'semantic_path_cell' (see Line  
20) and 'node_layer_of_each_path' (see Line 133). They are derived from the semantic hiearchy (see our paper for 
more detailed instructions). 
```
