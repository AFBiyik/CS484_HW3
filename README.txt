Ahmet Furkan Biyik
21501084
14.12.2019

=========================================================
You need external source for SLIC segmentation. 
You need to download and compile authors' codes provided in description from the link 
"https://ivrl.epfl.ch/research-2/research-current/research-superpixels/"
You only need to compile "slicomex.c" file in the source folder.
You can compile C file using "mex slicomex.c".
If you don't have compiler, you can download MinGW compiler from Home/Add-Ons.
Make sure you have compiled slicomex before running.

=========================================================
Source files are in source folder. Result images are saved in results folder.
Result images used in the report are in report_results folder. Data images are in data folder.

=========================================================
Code requires image data. Extract files in the image data that shared on course page 
"http://www.cs.bilkent.edu.tr/~saksoy/courses/cs484/src/cs484_hw3_data.tar.gz"
inside of data folder or change "dataPath" variable in 
"main.m" file to execute code in these files.

"Input.JPG" file in the data folder is the image I used for take-home quiz in the beginning of the semester.

=========================================================
main.m creates over segmentation, merge superpixels and save results to results folder.
This operation takes some time (around 1 hour). Wait until it finishes.

=========================================================
Comments in main.m file explains how to use code.

