[![INFORMS Journal on Computing Logo](https://INFORMSJoC.github.io/logos/INFORMS_Journal_on_Computing_Header.jpg)](https://pubsonline.informs.org/journal/ijoc)

# CacheTest

This archive is distributed in association with the [INFORMS Journal on
Computing](https://pubsonline.informs.org/journal/ijoc) under the [MIT License](LICENSE).

The software and data in this repository are a snapshot of the software and data
that were used in the research reported on in the paper "Globalized Distributionally Robust Counterpart" (https://doi.org/10.1287/ijoc.2019.0000) by F. Liu, Z. Chen and S. Wang. 

## Cite

To cite the contents of this repository, please cite both the paper and this repo, using their respective DOIs.

https://doi.org/10.1287/ijoc.2019.0000

https://doi.org/10.1287/ijoc.2019.0000.cd

Below is the BibTex for citing this snapshot of the repository.

```
@article{GDRC,
  author =        {Feng Liu, Zhi Chen and Shuming Wang},
  publisher =     {INFORMS Journal on Computing},
  title =         {Globalized Distributionally Robust Counterpart},
  year =          {2023},
  doi =           {10.1287/ijoc.2019.0000.cd},
  url =           {https://github.com/INFORMSJoC/2022.0274},
}  
```

## Requirements

For these experiments, we use
* MATLAB 2017a
* Cplex 12.10.0

## Content

This repository includes the source code and computational results for all the experiments presented in the paper.

### Data files
The folder **data** includes all the samples used in our experiments.
1. The file [d_insample.xlsx](data/d_insample.xlsx) contains 20 randomly generated demand samples from a truncated normal distribution. 
2. The file [d_outsample.xlsx](data/d_outsample.xlsx) includes 2000 randomly generated demand samples from a truncated normal distribution.
3. The file [distance.xlsx](data/distance.xlsx) represents the distance between different stores.


### Code files 
The folder **scripts** includes all the codes used in our experiments.
1. The code files in the folder **GADRO-Violation** are for evaluating the constraint violation of G-ADRO models under different values of the Wasserstein distance between the out-of-sample distribution and the reference distribution, where the file [Violation_main] is the main program. The codes have been used in Section 5.1 of our paper.

2. The code files in the folder **GADRO-Trade_off** are for testing the out-of-sample performance of the G-ADRO models including the average total cost and the probability of exceeding the target, where the file [GADRO_main] is the main program. The codes have been used in Section 5.1 of our paper.

3. The code files in the folder **GARS-Violation** are for evaluating the constraint violation of G-ARS models under different values of the Wasserstein distance between the out-of-sample distribution and the reference distribution, where the file [Violation_main] is the main program. The codes have been used in Section 5.2 of our paper.

4. The code files in the folder **GARS-Trade_off** are for computing the average total cost and the average target deviation of G-ARS models under different values of target, where the file [GARS_main] is the main program. The codes have been used in Section 5.2 of our paper.

5. The code files in the folder **Cross-Validation** are for selecting a proper value of gamma using a 4-fold cross-validation technique.

## Results

"**GADRO-1**" shows the out-of-sample performance of the G-ADRO models on the trade-off between the average total cost and the probability of exceeding the target.

![Figure 1](results/GADRO-1.pdf)

"**GADRO-2**" zooms in the region [2650, 3000] of the average total cost in Figure "**GADRO-1**" and shows that there exists an efficient portion of the frontier.
![Figure 2](results/GADRO-2.pdf)

"**GARS-1**" compares the average total cost of G-ARS models under different values of target.
![Figure 3](results/GARS-1.pdf)

"**GARS-2**" compares the average total cost of G-ARS models under different values of target.
![Figure 4](results/GARS-2.pdf)

"**CV_train**" shows the average total cost and probability of exceeding target of the G-ADRO model with different values of gamma.
![Figure 5](results/CV_train.pdf)

"**CV_test**" shows the out-of-sample performance of the G-ADRO model with different values of gamma, including the average total cost and probability of exceeding target.
![Figure 5](results/CV_test.pdf)

## Replicating

To replicate any of the results presented above, run the main program in the relevant folder.
