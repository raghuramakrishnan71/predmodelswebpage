# predmodelswebpage

Filename: step1modified.bash

Description:
1. convert csv to arff
2. randomize contents of arff
3. truncate dataset to include attributes relevant for onload (remove fields 1,2,3,5,6,51)
4. truncate dataset to include attributes relevant for fullyloaded (remove fields 1,2,3,4,6,51)

Input:
1. List of files: step1-datacreation-list.txt
2. Location of csv: ../datasets/csv

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
