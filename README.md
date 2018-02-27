# Predictive Model Evaluation

Scripts for forthcoming work, tentatively titled "Evaluating Predictive Models of Student Success: Closing the Methodological Gap".

Maintainer: Josh Gardner jpgard@umich.edu

To run analysis:

``` 
python3 run_model_comparison.py --data_dir=./data
```

`./data` should be a directory with `course_name/session_number/` directories containing raw MOOC data exports from the Coursera platform (having data stored locally is easier than push/pulling from S3)).

