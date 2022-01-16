import numpy as np
import argparse
import cv2
from scipy.stats import multivariate_normal


def create_blanc_image(width, height, image_name):
    img = np.ones([width, height, 3]) * 255.0
    cv2.imwrite(image_name, img)


def generate_stat_image(width, height, image_name):
    img = np.ones([width, height, 3]) * 255.0
    a = multivariate_normal.rvs(mean=(25, 25), cov=15, size=100, random_state=None)
    b = a.astype(int)
    for e in b:
        img[e[0], e[1], :] = 0
    cv2.imwrite(image_name, img)


def add_pepper_noise(image):
    s_vs_p = 0.05
    out = np.copy(image)
    coords = np.random.binomial(n=1, p=(1. - s_vs_p), size=image.shape)
    out = out * coords
    return out


def generate_data_strict(prefix, n, width, height):
    create_blanc_image(width, height, f'{prefix}_0.png')
    for i in range(1, n):
        img = cv2.imread(f'{prefix}_{i-1}.png', cv2.IMREAD_COLOR)
        out = add_pepper_noise(img)
        cv2.imwrite(f'{prefix}_{i}.png', out)


def generate_data_stat(prefix, n, width, height):
    for i in range(1, n):
        generate_stat_image(width, height, f'{prefix}_{i}.png')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--prefix", type=str, default="default")
    parser.add_argument("--n", type=int, default=10)
    parser.add_argument("--w", type=int, default=50)
    parser.add_argument("--h", type=int, default=50)
    parser.add_argument("--mode", type=str, default='strict')

    args = parser.parse_args()
    prefix = args.prefix
    width = args.w
    height = args.h
    n = args.n
    mode = args.mode
    if mode == 'strict':
        generate_data_strict(prefix, n, width, height)
    elif mode == 'stat':
        generate_data_stat(prefix, n, width, height)

    '''
    global RUN_NAME, DATA_PATH, MODELS_PATH, RESULTS_PATH, LOG_PATH

    RUN_NAME = run_name
    DATA_PATH = "./data"
    MODELS_PATH = f"./models/{run_name}"
    RESULTS_PATH = f"./results/{run_name}"
    LOG_PATH = f"./log/{run_name}"

    make_dir(f"{MODELS_PATH}")
    make_dir(f"{LOG_PATH}/log")
    make_dir(f"{LOG_PATH}/log_tb")
    make_dir(F"{RESULTS_PATH}")

    X_train, X_dev, y_train, y_dev = loadData()
    model = loadModel()
    model = trainModel(model, numOfEpochs, X_train, y_train)
    saveModel(model)
    saveResult(model, X_dev, y_dev)
    '''


if __name__ == "__main__":
    main()
