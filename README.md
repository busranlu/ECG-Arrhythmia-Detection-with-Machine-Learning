# ECG-Arrhythmia-Detection-with-Machine-Learning
Premature Ventricular Complex (PVC) Arrhythmia Detection with Machine Learning
 
In this project, the aim is detecting PVC beats and Normal beats from ECG records. MIT-BIH Arrhythmia Database is used for this project. Especially datas had PVC beats are chosen.  Firstly, signal processing stage is applied, it is important for studying signals without noise. After signal processing, R waves, Q waves, S waves are found. Other stage is extraction features (RR intervals, R amplitude, QRS width). After feature extraction, machine learning models(Decision Trees,KNN,SVM,Ensemble) are trained with MATLAB Classification Learner and models are tested with test data. High accuracy classification results are observed.


In 'Feature_matris2.xlsx', there are 3 data file ("all datas(includes training and test data), traning data and test data")
In Feature matris, there are 6 columns(5 dimention-features and 1 label) (R amplitude,QRS width,RR interval,gender,age and arrhytmia type). Age and gender are not used as a feature. 

Model Training outputs from MATLAB Classification Learner Outputs are given below:

![9nisan_modelçiktilar](https://user-images.githubusercontent.com/47025526/164173926-41dc2cc7-4635-417f-a438-a53197b002ac.PNG)
![9nisan_modelçiktilar2](https://user-images.githubusercontent.com/47025526/164173951-b2aef90f-2c95-4ebc-8f73-f2cb0f882460.PNG)



Testing results are given below:

![image](https://user-images.githubusercontent.com/47025526/164175534-40829e38-97d7-439b-8ed2-b0402727a7e8.png)

