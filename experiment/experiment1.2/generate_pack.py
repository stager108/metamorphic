#!/usr/bin/env python3

import random
import argparse

def generate_cascade_test(file, prefix, n):
    tum_list = [list() for i in range(n)]
    norm_list = [list() for i in range(n)]
    with open(file, 'r') as f:
        for line in f.readlines():
            x = random.random()
            p = random.random()
            for treshold in range(1, n+1):
                if x <= treshold/n and x > (treshold - 1)/n:
                    for j in range(treshold - 1, n):
                        tum_list[j].append(line)
                    if p <= 1/2:
                        for j in range(treshold - 1, n):
                            norm_list[j].append(line)
                    break
    for i in range(n):
        with open(prefix + '0' + str(i) + '_tum.txt', 'w') as f:
            for elem in tum_list[i]:
                f.write(elem)
        with open(prefix + '0' + str(i) + '_norm.txt', 'w') as f:
            for elem in norm_list[i]:
                f.write(elem)                


if __name__ == '__main__':
	parser = argparse.ArgumentParser(description='Process file.')

	parser.add_argument('file',  help='file name')
	parser.add_argument('prefix', help='file prefix')
	parser.add_argument('n', type=int, help='an integer for the accumulator')

	args = parser.parse_args()
	generate_cascade_test(args.file, args.prefix, args.n)
