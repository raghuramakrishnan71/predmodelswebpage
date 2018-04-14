# predmodelswebpage

Structure of data directories.
pagetime
  datasets
       csv
       arff
       bf
       gr
       results
  scripts
       step1-datacreation-list.txt
       step1modified.bash
       step2-feature-selection-list.txt
       step2modified.bash

---------------------------------------------------------------------------------------------------------------------------------
Filename: step1modified.bash

Description:
1. convert csv to arff
2. randomize contents of arff
3. truncate dataset to include attributes relevant for onload (remove fields 1,2,3,5,6,51)
4. truncate dataset to include attributes relevant for fullyloaded (remove fields 1,2,3,4,6,51)

Input:
1. List of files: step1-datacreation-list.txt
2. Location of csv: ../datasets/csv (contains 11 csv files)

Output:
1. Location of arff: ../datasets/arff

2. Location of randomized arff files: ../datasets/arff
Name of randomized arff files (e.g) : pages_all_randomized.arff
(suffix _randomized is added)

3. Location of randomized onload arff files: ../datasets/arff
Name of randomized onload arff files (e.g) : pages_all_onload.arff
(suffix _onload is added)

4. Location of randomized fullyloaded arff files: ../datasets/arff
Name of randomized onload arff files (e.g) : pages_all_fullyloaded.arff
(suffix _fullyloaded is added)

-----------------------------------------------------------------------------------------------------------------

Filename: step2modified.bash

1. Select attributes using BestFit
2. Select attributes using GreedyStepwise
3. List attributes selected using BestFit
4. List attributes select using GreedyStepwise
5. Generate training data from BestFit reduced file
6. Generate training data from GreedyStepwise reduced file
7. Generate test data from BestFit reduced file
8. Generate test data from GreedyStepwise reduced file

Input:
1. List of files: step2-feature-selection-list.txt
2. Location of arff: ../datasets/arff

Output:
1. Location of feature selected files: ../datasets/bf, ../datasets/gr
Name of feature selected files (e.g) :  pages_all_onload-bf-reduced.arff, pages_all_onload-gr-reduced.arff
(suffix -bf-reduced or -gr-reduced is added)

2. Location of selected attributes files: ../datasets/results
Name of selected attributes files (e.g) : top-features-bf.csv, top-features-gr.csv

3. Location of training data files: ../datasets/bf, ../datasets/gr
Name of training data files (e.g) : pages_all_onload-bf-reduced_train.arff, pages_all_onload-gr-reduced_train.arff
(suffix _train is added)

4. Location of test data files: ../datasets/bf, ../datasets/gr
Name of training data files (e.g) : pages_all_onload-bf-reduced_test.arff, pages_all_onload-gr-reduced_test.arff
(suffix _test is added)

