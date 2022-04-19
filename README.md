# ECG-Arrhythmia-Detection-with-Machine-Learning
Premature Ventricular Complex (PVC) Arrhythmia Detection with Machine Learning
 
In this project, the aim is detecting PVC beats and Normal beats from ECG records. MIT-BIH Arrhythmia Database is used for this project. Especially datas had PVC beats are chosen.  Firstly, ignal processing stage is applied, it is important for studying signals without noise. After signal processing, R wave, Q wave, S wave are found. Other stage is extraction features (RR intervals, R amplitude, QRS width). After feature extraction machine learning models(Decision Trees,KNN,SVM,Ensemble) are trained with MATLAB Classification Learner and models are tested with test data. High accuracy classification resaults are observed.



In Feature matris, There are 3 data parts. There are all datas, traning data and test data. There are also 6 columns (R amplitude,QRS width,RR interval, Gender,age,arrhytmia type). Age and gender are not used as a feature. 
