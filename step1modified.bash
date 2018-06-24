#!/bin/bash
CLAZZ_PATH="-cp /home/anakinskywalker/weka-3-8-1/weka.jar:/home/anakinskywalker/weka-3-8-1/mtj.jar:/home/anakinskywalker/weka-3-8-1/model-eval.jar:/home/anakinskywalker/jars/commons-cli-1.4.jar:/home/anakinskywalker/jars/commons-csv-1.5.jar:/home/anakinskywalker/jars/commons-math3-3.6.1.jar"
JVM_MEM=-Xmx3072m
RANDOM_SEED=967825
TRAIN_PERCENT=66

INPUT="./step1-datacreation-list.txt"
CSV_LOCATION="../datasets/csv"
ARFF_LOCATION="../datasets/arff"

while IFS= read -r var
do

COUNT=`cat ${CSV_LOCATION}/${var}.csv|wc -l`

echo "Processing ${var} = ${COUNT}"

#convert csv to arff
echo "Converting to arff"
java $CLAZZ_PATH $JVM_MEM weka.core.converters.CSVLoader "${CSV_LOCATION}/${var}.csv" -S "1,3"  > "${ARFF_LOCATION}/${var}.arff"

#randomize contents of arff
echo "Randomizing arff file"
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.instance.Randomize -S $RANDOM_SEED -i "${ARFF_LOCATION}/${var}.arff" -o "${ARFF_LOCATION}/${var}_randomized.arff"

#truncate dataset to include attributes relevant for onload
echo "Creating onload data file"
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.attribute.Remove -R 1,2,3,5,6,52 -i "${ARFF_LOCATION}/${var}_randomized.arff" -o "${ARFF_LOCATION}/${var}_onload.arff"

echo "Creating fullyloaded data file"
#truncate dataset to include attributes relevant for fullyloaded
java $CLAZZ_PATH $JVM_MEM weka.filters.unsupervised.attribute.Remove -R 1,2,3,4,6,52 -i "${ARFF_LOCATION}/${var}_randomized.arff" -o "${ARFF_LOCATION}/${var}_fullyloaded.arff"

done < "$INPUT"

COUNT=`ls ${CSV_LOCATION}/*.csv | wc -l`
echo "Total csv files = ${COUNT}"
COUNT=`ls ${ARFF_LOCATION}/*.arff | wc -l`
echo "Total arff files = ${COUNT}"
COUNT=`ls ${ARFF_LOCATION}/*_randomized.arff | wc -l`
echo "Total randomized arff files = ${COUNT}"
COUNT=`ls ${ARFF_LOCATION}/*_onload.arff | wc -l`
echo "Total onload arff files = ${COUNT}"
COUNT=`ls ${ARFF_LOCATION}/*_fullyloaded.arff | wc -l`
echo "Total fullyloaded arff files = ${COUNT}"
