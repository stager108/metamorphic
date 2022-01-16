import numpy as np
import cv2
import argparse
from skimage.morphology import dilation, erosion, square


def process_image(prefix, n, bin_mode):
    for i in range(1, n):
        name = f'{prefix}_{i}'
        if bin_mode == 'treshold':
            _, th3 = cv2.threshold(cv2.cvtColor(cv2.imread(f'{prefix}_{i}.png'), cv2.COLOR_BGR2GRAY),
                                127, 255, cv2.THRESH_BINARY)
        elif bin_mode == 'adaptive':
            img = cv2.cvtColor(cv2.imread(f'{prefix}_{i}.png'), cv2.COLOR_BGR2GRAY)
            th3 = cv2.adaptiveThreshold(img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                        cv2.THRESH_BINARY, 11, 7)
            #th3 = cv2.adaptiveThreshold(cv2.cvtColor(cv2.imread(f'{prefix}_{i}.png',
            #                                                       cv2.COLOR_BGR2GRAY),
            #                                            255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            #                                            cv2.THRESH_BINARY, 11, 7))
        else:
            return
        cv2.imwrite(name + '_wb.png', th3)
        th3 = np.asarray(th3, dtype='int')
        th3 = erosion(th3, square(2))
        cv2.imwrite(name + '_e.png', th3)
        th3 = dilation(th3, square(2))
        cv2.imwrite(name + '_d.png', th3)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prefix", default="default")
    parser.add_argument("--n", type=int, default=10)
    parser.add_argument("--mode", default="strict")
    args = parser.parse_args()
    prefix = args.prefix
    mode = args.mode
    n = args.n
    process_image(prefix, n, mode)

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
