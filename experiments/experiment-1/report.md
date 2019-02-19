# Comparing the performance of positional, named and mixed arguments in Dart
## Hypothesis
I expect the difference in the results to be minimal. But, given a large enough sample size, I do expect to see a sub-microsecond performance differential.
## Methods
The experiment will go as follows;
1. Produce a randomly generated dataset, consisting of objects which each have two properties.
2. Start the stopwatch.
3. Use a for-loop to run the workload with positional arguments a given number of times.
4. Stop the stopwatch.
5. Start the stopwatch.
6. Use a for-loop to run the workload with named arguments a given number of times.
7. Stop the stopwatch.
8. Start the stopwatch.
9. Use a for-loop to run the workload with mixed arguments a given number of times.
10. Stop the stopwatch.
## Execution
I ran the following command five times;  
`dart code.dart 20000000 2573284342`  
- 20.000.000 samples
- The RNG's seed is 2573284342
## Results
### Run 1
| Positional arguments | Named arguments | Run time **(μs)** |
|:---:|:---:| --- |
| ✔️ | ❌ | 0,0084 |
| ❌ | ✔️ | 0,0078 |
| ✔️ | ✔️ | 0,0076 |
### Run 2
| Positional arguments | Named arguments | Run time **(μs)** |
|:---:|:---:| --- |
| ✔️ | ❌ | 0,0085 |
| ❌ | ✔️ | 0,0079 |
| ✔️ | ✔️ | 0,0074 |
### Run 3
| Positional arguments | Named arguments | Run time **(μs)** |
|:---:|:---:| --- |
| ✔️ | ❌ | 0,0077 |
| ❌ | ✔️ | 0,0077 |
| ✔️ | ✔️ | 0,0075 |
### Run 4
| Positional arguments | Named arguments | Run time **(μs)** |
|:---:|:---:| --- |
| ✔️ | ❌ | 0,0076 |
| ❌ | ✔️ | 0,0075 |
| ✔️ | ✔️ | 0,0086 |
### Run 5
| Positional arguments | Named arguments | Run time **(μs)** |
|:---:|:---:| --- |
| ✔️ | ❌ | 0,0092 |
| ❌ | ✔️ | 0,0087 |
| ✔️ | ✔️ | 0,0087 |
### Average
| Positional arguments | Named arguments | Run time **(μs)** |
|:---:|:---:| --- |
| ✔️ | ❌ | 0,0083 |
| ❌ | ✔️ | 0,0079 |
| ✔️ | ✔️ | 0,0080 |
## Conclusion
The data shows no significant  performance differential between positional, named and mixed arguments. Although I do have to note the following;

Whenever I would run the experiment multiple times in quick succession, the run time would increase, I think this is related to the CPU core temperature increase.