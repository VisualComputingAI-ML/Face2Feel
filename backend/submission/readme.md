The dataset that should be downloaded are:
https://www.kaggle.com/datasets/ananthu017/emotion-detection-fer
https://www.kaggle.com/datasets/mstjebashazida/affectnet

The file structure is given below.
Directory names of for the for the dataset have to be changed to match the one listed below, and some folders like 'Contempt' would need to be deleted to have 7 classes in total

Running the notebook would create folders
- One where the processed data would be saved
- One for saving the training and test results


```
root folder
├── data
│   ├── AffectNet
│   │   ├── labels.csv
│   │   ├── test
│   │   │   ├── anger
│   │   │   ├── disgust
│   │   │   ├── fear
│   │   │   ├── happy
│   │   │   ├── neutral
│   │   │   ├── sad
│   │   │   └── surprise
│   │   └── train
│   │       ├── anger
│   │       ├── disgust
│   │       ├── fear
│   │       ├── happy
│   │       ├── neutral
│   │       ├── sad
│   │       └── surprise
│   ├── AffectNet-aligned
│   │   ├── test
│   │   │   ├── anger
│   │   │   ├── disgust
│   │   │   ├── fear
│   │   │   ├── happy
│   │   │   ├── neutral
│   │   │   ├── sad
│   │   │   └── surprise
│   │   └── train
│   │       ├── anger
│   │       ├── disgust
│   │       ├── fear
│   │       ├── happy
│   │       ├── neutral
│   │       ├── sad
│   │       └── surprise
│   ├── FER-2013
│   │   ├── test
│   │   │   ├── anger
│   │   │   ├── disgust
│   │   │   ├── fear
│   │   │   ├── happy
│   │   │   ├── neutral
│   │   │   ├── sad
│   │   │   └── surprise
│   │   └── train
│   │       ├── anger
│   │       ├── disgust
│   │       ├── fear
│   │       ├── happy
│   │       ├── neutral
│   │       ├── sad
│   │       └── surprise
│   └── FER-2013-aligned
│       ├── test
│       │   ├── anger
│       │   ├── disgust
│       │   ├── fear
│       │   ├── happy
│       │   ├── neutral
│       │   ├── sad
│       │   └── surprise
│       └── train
│           ├── anger
│           ├── disgust
│           ├── fear
│           ├── happy
│           ├── neutral
│           ├── sad
│           └── surprise
└── 'Training Notebook.ipynb'
```