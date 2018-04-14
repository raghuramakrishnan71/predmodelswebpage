#!/bin/bash
CLAZZ_PATH="-cp /home/anakinskywalker/weka-3-8-1/weka.jar:/home/anakinskywalker/weka-3-8-1/mtj.jar:/home/anakinskywalker/weka-3-8-1/model-eval.jar:/home/anakinskywalker/jars/commons-cli-1.4.jar:/home/anakinskywalker/jars/commons-csv-1.5.jar:/home/anakinskywalker/jars/commons-math3-3.6.1.jar:/home/anakinskywalker/wekafiles/packages/isotonicRegression/isotonicRegression.jar:/home/anakinskywalker/wekafiles/packages/leastMedSquared/leastMedSquared.jar:/home/anakinskywalker/wekafiles/packages/paceRegression/paceRegression.jar:/home/anakinskywalker/wekafiles/packages/RBFNetwork/RBFNetwork.jar"
JVM_MEM=-Xmx3072m

INPUT="./step2-feature-selection-list.txt"
CSV_LOCATION="../datasets/csv"
ARFF_LOCATION="../datasets/arff"
BESTFIRST_LOCATION="../datasets/bf"
GREEDY_LOCATION="../datasets/gr"
RESULTS_LOCATION="../datasets/results"
BFPREDICT_LOCATION="../datasets/bfpredict"
GRPREDICT_LOCATION="../datasets/grpredict"

echo "Cleaning results file"
> ${RESULTS_LOCATION}/evaluation_bf.csv

while IFS= read -r var
do

INPUT_REDUCED_TRAIN_FILE="${BESTFIRST_LOCATION}/${var}-bf-reduced_train"
INPUT_REDUCED_TEST_FILE="${BESTFIRST_LOCATION}/${var}-bf-reduced_test"
ACTUAL_VS_PREDICT_FILE="${BFPREDICT_LOCATION}/${var}-bf-reduced_test"

#5 RBF regression
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.RBFRegressor -N 2 -R 0.01 -L 1.0E-6 -C 2 -P 1 -E 1 -S 1  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-rbfreg.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "rbf regression  $START $END $DIFF seconds"


java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-rbfreg.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-rbfreg" -append true -etime $DIFF -debug false -technique rbfreg

#6 RBF network
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.RBFNetwork -B 2 -S 1 -R 1.0E-8 -M -1 -W 0.1  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-rbfnet.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "rbf network took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-rbfnet.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-rbfnet" -append true -etime $DIFF -debug false -technique rbfnet
 
#7 pace regression
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.PaceRegression -E eb  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-pacer.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "pace regression took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-pacer.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-pacer" -append true -etime $DIFF -debug false -technique pacer

#8 isotonic regression
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.IsotonicRegression  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-isor.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "isotonic regression took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-isor.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-isor" -append true -etime $DIFF -debug false -technique isor

#9 Least median square
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.LeastMedSq -S 4 -G 0  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-lms.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Leastmediansquare took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-lms.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-msq" -append true -etime $DIFF -debug false -technique msq

#10 mlp
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-mlp.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Mlp took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-mlp.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-mlp" -append true -etime $DIFF -debug false -technique mlp

#11 mlr, change S to 1 - attribute selection method None
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.LinearRegression -S 1 -R 1.0E-8 -num-decimal-places 4   -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-lr.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Mlr took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-lr.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-lr" -append true -etime $DIFF -debug false -technique lr

#12 slr
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.SimpleLinearRegression  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-slr.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Slr took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-slr.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-slr" -append true -etime $DIFF -debug false -technique slr

#13 smo
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.functions.SMOreg -C 1.0 -N 0 -I "weka.classifiers.functions.supportVector.RegSMOImproved -T 0.001 -V -P 1.0E-12 -L 0.001 -W 1" -K "weka.classifiers.functions.supportVector.PolyKernel -E 1.0 -C 250007"  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-smo.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Smo took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-smo.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-smo" -append true -etime $DIFF -debug false -technique smo

#14 dt
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.rules.DecisionTable -X 1 -S "weka.attributeSelection.BestFirst -D 1 -N 5"  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-dt.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Dt took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-dt.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-dt" -append true -etime $DIFF -debug false -technique dt

#15 m5rules
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.rules.M5Rules -M 4.0  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-m5r.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "M5rules took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-m5r.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-m5r" -append true -etime $DIFF -debug false -technique m5r

#16 zr
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.rules.ZeroR  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-zr.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Zr took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-zr.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-zr" -append true -etime $DIFF -debug false -technique zr

#17 m5p
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.trees.M5P -M 4.0  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-m5p.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "M5p took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-m5p.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-m5p" -append true -etime $DIFF -debug false -technique m5p

#18 ds
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.trees.DecisionStump  -t  "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-ds.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Ds took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-ds.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-ds" -append true -etime $DIFF -debug false -technique ds

#19 randforest
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.trees.RandomForest -P 100 -I 100 -num-slots 1 -K 0 -M 1.0 -V 0.001 -S 1  -t  "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-randfor.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Randforest took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-randfor.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-randfor" -append true -etime $DIFF -debug false -technique randfor

#20 randtree
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.trees.RandomTree -K 0 -M 1.0 -V 0.001 -S 1  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-randtree.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Randtree took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-randtree.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-randtree" -append true -etime $DIFF -debug false -technique randtree

#21 reptree
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.trees.REPTree -M 2 -V 0.001 -N 3 -S 1 -L -1 -I 0.0  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-reptree.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Reptree took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-reptree.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-reptree" -append true -etime $DIFF -debug false -technique reptree

#22 Ibk
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.lazy.IBk -K 1 -W 0 -A "weka.core.neighboursearch.LinearNNSearch -A \"weka.core.EuclideanDistance -R first-last\""   -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-ibk.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Ibk took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-ibk.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-ibk" -append true -etime $DIFF -debug false -technique ibk

#23 Kstar
START=$(date +%s)
#java $CLAZZ_PATH $JVM_MEM weka.classifiers.lazy.KStar -B 20 -M a  -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-kstar.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "Kstar took $START $END $DIFF seconds"

#java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-kstar.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-kstar" -append true -etime $DIFF -debug false -technique kstar

#24 LWL
START=$(date +%s)
java $CLAZZ_PATH $JVM_MEM weka.classifiers.lazy.LWL -U 0 -K -1 -A "weka.core.neighboursearch.LinearNNSearch -A \"weka.core.EuclideanDistance -R first-last\"" -W weka.classifiers.trees.DecisionStump -t "${INPUT_REDUCED_TRAIN_FILE}.arff" -T "${INPUT_REDUCED_TEST_FILE}.arff" -c last  -classifications "weka.classifiers.evaluation.output.prediction.CSV -file ${ACTUAL_VS_PREDICT_FILE}-lwl.csv"
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "LWL took $START $END $DIFF seconds"

java $CLAZZ_PATH $JVM_MEM model.evaluation.ModelPerformance -i ${ACTUAL_VS_PREDICT_FILE}-lwl.csv -o ${RESULTS_LOCATION}/evaluation_bf.csv -p1 0.25 -p2 0.30 -label "${INPUT_REDUCED_TEST_FILE}-lwl" -append true -etime $DIFF -debug false -technique lwl

done < "$INPUT"
