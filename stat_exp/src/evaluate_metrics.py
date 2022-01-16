import numpy as np
import cv2
import argparse


def check_relations_strict(prefix, n):
    for i in range(1, n-1):
        for suff in ('wb', 'e', 'd'):
            img1 = np.asarray(cv2.imread(f'{prefix}_{i}_{suff}.png'), dtype='int')
            img2 = np.asarray(cv2.imread(f'{prefix}_{i + 1}_{suff}.png'), dtype='int')
            print(np.all(img1 >= img2))
            print(np.sum(img1 >= img2), np.sum(img1 < img2))


def check_relations_stat(prefix, n):
    for i in range(1, n):
        pass


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prefix", type=str, default="default")
    parser.add_argument("--n", type=int, default=10)
    parser.add_argument("--mode", type=str, default='strict')

    args = parser.parse_args()
    prefix = args.prefix
    n = args.n
    mode = args.mode
    if mode == 'strict':
        check_relations_strict(prefix, n)
    elif mode == 'stat':
        check_relations_stat(prefix, n)

    '''
    global RUN_NAME, DATA_PATH, MODELS_PATH, RESULTS_PATH, LOG_PATH

    RUN_NAME = run_name
    DATA_PATH = "./data"
    MODELS_PATH = f"./models/{run_name}"
    RESULTS_PATH = f"./results/{run_name}"
    LOG_PATH = f"./log/{run_name}"

    X_train, X_dev, X_test, y_train, y_dev, y_test = load_data()
    model = load_model()
    predict_and_save(model, X_train, y_train, f"{RESULTS_PATH}/train_report.csv")
    predict_and_save(model, X_dev, y_dev, f"{RESULTS_PATH}/dev_report.csv")
    predict_and_save(model, X_test, y_test, f"{RESULTS_PATH}/test_report.csv")
    '''


if __name__ == "__main__":
    main()
