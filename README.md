# Chemical-Age-Using-Stochastic-Gradient
The MATLAB script developed to compute Chemical Age using stochastic Gradient (SGD)

#What the project Does and why is useful
The technique of chemical age dating using electron microprobe analyses is a useful tool for determining the age of individual mineral grains in geological studies. The process of calculating chemical age can be a manual and time-consuming involving guesswork and non-scientific methods that rely on tools like Excel spreadsheets. Fortunately, recent advancements have introduced the Stochastic Gradient Descent (SGD) method, which is a more scientific and effective approach for computing chemical age. This method optimizes the 't' values to estimate the age of individual mineral grains, providing more accurate and reliable results and eliminating the need for manual iteration. The availability of this algorithm makes chemical age dating more accessible and faster, providing precise information for geological studies.

#How user can get started with the project
1.Create a new folder and save the 'Chem_Age_SGD_MAE.m' script in that folder.
2.Create an Excel file called 'base.xlsx' and save it in the same folder.
3.The 'base.xlsx' file should have four columns of data. The first column should be Serial No, which numbers the data points. The second column should contain UO2(%), the third column should contain Tho2(%), and the last column should contain PbO(%).
4.For your reference, an example Excel file named 'base' has been included in the repository.
5.Open MATLAB and add the created folder to the MATLAB workspace.
6.Run the script. The amount of time it takes to run depends on the number of datasets and the pre-set threshold error.
7.The output will have five columns. The first four columns will be the same as the input, and the fifth column will contain the chemical age  in million year corresponding to the data point.


