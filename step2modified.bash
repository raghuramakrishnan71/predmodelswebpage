#!/bin/bash
CLAZZ_PATH="-cp /home/anakinskywalker/weka-3-8-1/weka.jar:/home/anakinskywalker/weka-3-8-1/mtj.jar:/home/anakinskywalker/weka-3-8-1/model-eval.jar:/home/anakinskywalker/jars/commons-cli-1.4.jar:/home/anakinskywalker/jars/commons-csv-1.5.jar:/home/anakinskywalker/jars/commons-math3-3.6.1.jar:/home/anakinskywalker/wekafiles/packages/isotonicRegression/isotonicRegression.jar:/home/anakinskywalker/wekafiles/packages/leastMedSquared/leastMedSquared.jar:/home/anakinskywalker/wekafiles/packages/paceRegression/paceRegression.jar:/home/anakinskywalker/wekafiles/packages/RBFNetwork/RBFNetwork.jar"
JVM_MEM=-Xmx3072m

RANDOM_SEED=967825
TRAIN_PERCENT=66

INPUT="./step2-feature-selection-list.txt"
CSV_LOCATION="../datasets/csv"
ARFF_LOCATION="../datasets/arff"
BESTFIRST_LOCATION="../datasets/bf"
GREEDY_LOCATION="../datasets/gr"
RESULTS_LOCATION="../datasets/results"

RESULTS_FILE_BF="${RESULTS_LOCATION}/top-features-bf.csv"
RESULTS_FILE_GR="${RESULTS_LOCATION}/top-features-gr.csv"

echo "Cleaning results files"
>  ${RESULTS_FILE_BF}
>  ${RESULTS_FILE_GR}

while IFS= read -r var
do

INPUT_FILE="${ARFF_LOCATION}/${var}.arff"
OUTPUT_REDUCED_FILE_BF="${BESTFIRST_LOCATION}/${var}-bf-reduced"
OUTPUT_REDUCED_FILE_GR="${GREEDY_LOCATION}/${var}-gr-reduced"

echo "Processing ${var}"


#attribute selection
echo "Selecting attributes using BestFit"
java $CLAZZ_PATH $JVM_MEM weka.filters.supervised.attribute.AttributeSelection -E "weka.attributeSelection.CfsSubsetEval -P 1 -E 1" -S  "weka.attributeSelection.BestFirst -D 1 -N 5" -i "$INPUT_FILE" -c 1 -o "${OUTPUT_REDUCED_FILE_BF}.arff"

echo "Selecting attributes using GreedyStepwise"
java $CLAZZ_PATH $JVM_MEM weka.filters.supervised.attribute.AttributeSelection -E "weka.attributeSelection.CfsSubsetEval -P 1 -E 1" -S  "weka.attributeSelection.GreedyStepwise -T -1.7976931348623157E308 -N -1 -num-slots 1" -i "$INPUT_FILE" -c 1 -o "${OUTPUT_REDUCED_FILE_GR}.arff"

#selected attribute counting
echo "Counting attributes of BestFit"
cat ${OUTPUT_REDUCED_FILE_BF}.arff | grep "@attribute" | awk -v label="${OUTPUT_REDUCED_FILE_BF}|" '{print label, $2}' >> ${RESULTS_FILE_BF}

echo "Counting attributes of GreedyStepwise"
cat ${OUTPUT_REDUCED_FILE_GR}.arff | grep "@attribute" | awk -v label="${OUTPUT_REDUCED_FILE_GR}|" '{print label, $2}' >> ${RESULTS_FILE_GR}

#split dataset into training and test
echo "Genertaing training data from BestFit reduced file"
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.instance.RemovePercentage -P $TRAIN_PERCENT -i "${OUTPUT_REDUCED_FILE_BF}.arff" -o "${OUTPUT_REDUCED_FILE_BF}_train.arff"

echo "Genertaing training data from GreedyStepwise reduced file"
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.instance.RemovePercentage -P $TRAIN_PERCENT -i "${OUTPUT_REDUCED_FILE_GR}.arff" -o "${OUTPUT_REDUCED_FILE_GR}_train.arff"

echo "Genertaing test data from BestFit reduced file"
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.instance.RemovePercentage -P $TRAIN_PERCENT -i "${OUTPUT_REDUCED_FILE_BF}.arff" -o "${OUTPUT_REDUCED_FILE_BF}_test.arff" -V

echo "Genertaing test data from GreedyStepwise reduced file"
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.instance.RemovePercentage -P $TRAIN_PERCENT -i "${OUTPUT_REDUCED_FILE_GR}.arff" -o "${OUTPUT_REDUCED_FILE_GR}_test.arff" -V


done < "$INPUT"

COUNT=`ls ${ARFF_LOCATION}/*.arff | wc -l`
echo "Total arff files = ${COUNT}"
COUNT=`ls ${BESTFIRST_LOCATION}/*-bf-reduced.arff | wc -l`
echo "Total BestFit reduced randomized files = ${COUNT}"
COUNT=`ls ${GREEDY_LOCATION}/*-gr-reduced.arff | wc -l`
echo "Total GreedyStepwise reduced randomized files = ${COUNT}"
COUNT=`ls ${BESTFIRST_LOCATION}/*-bf-reduced_train.arff | wc -l`
echo "Total BestFit reduced training files = ${COUNT}"
COUNT=`ls ${GREEDY_LOCATION}/*-gr-reduced_train.arff | wc -l`
echo "Total GreedyStepwise reduced training files = ${COUNT}"
COUNT=`ls ${BESTFIRST_LOCATION}/*-bf-reduced_test.arff | wc -l`
echo "Total BestFit reduced test files = ${COUNT}"
COUNT=`ls ${GREEDY_LOCATION}/*-gr-reduced_test.arff | wc -l`
echo "Total GreedyStepwise reduced test files = ${COUNT}"
