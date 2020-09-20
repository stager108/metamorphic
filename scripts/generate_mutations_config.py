#!/usr/bin/env python3
import os
import random


def generate_varfile_mutation(chromosome_number, mut_amount, mut_type='INS', indel='AAA',
                              start=0, length=150, vaf='0.99'):

    '''chromosome_number - name of needed chromosome,
    mut_amount - general amount of mutations to generate,
    mut_type \in ['INS', 'DEL'],
    indel - value of insertion,
    start - start coordinate of needed region,
    length - length of neede region.'''

    chromosome_number = str(chromosome_number)
    ans = ''
    for i in range(mut_amount):
        position = random.randint(0, length - 1) + start
        if mut_type == 'INS':
            ans += ' '.join([chromosome_number,
                             str(position),
                             str(position + 1),
                             str(vaf),
                             'INS',
                             indel + '\n'])
        elif mut_type == 'DEL':
            ans += ' '.join([chromosome_number,
                             str(position),
                             str(position + random.randint(0, length - 1)),
                             str(vaf),
                             'DEL\n'])
    return ans


def write_to_file(file, text, mode='w'):
    with open(file, mode) as f:
        f.write(text)


def generate_cascade_inserts(path, file_prefix, configuration):
    '''Configuration: [[start, length, insertion]].'''
    ans = ''
    for i, mut in enumerate(configuration):
        ans += generate_varfile_mutation('Chromosome', 1, 'INS', indel=mut[2],
                                         start=mut[0], length=mut[1], vaf='0.99')
        write_to_file(os.path.join(path, file_prefix + '_' + str(i + 1) + '.txt'), ans, 'w')


def generate_cascade_deletions(path, file_prefix, configuration):
    '''Configuration: [[start, length]].'''
    ans = ''
    for i, mut in enumerate(configuration):
        ans += generate_varfile_mutation('Chromosome', 1, 'DEL',
                                         start=mut[0], length=mut[1], vaf='0.99')
        write_to_file(os.path.join(path, file_prefix + '_' + str(i + 1) + '.txt'), ans, 'w')


def generate_inserts(path, file_name, configuration, mode='w'):
    '''Configuration: [[start, length, insertion]].'''
    ans = ''
    for i, mut in enumerate(configuration):
        ans += generate_varfile_mutation('Chromosome', 1, 'INS', indel=mut[2],
                                         start=mut[0], length=mut[1], vaf='0.99')
    write_to_file(os.path.join(path, file_name + '.txt'), ans, mode)


def generate_deletions(path, file_name, configuration, mode='w'):
    '''Configuration: [[start, length]].'''
    ans = ''
    for i, mut in enumerate(configuration):
        ans += generate_varfile_mutation('Chromosome', 1, 'DEL',
                                         start=mut[0], length=mut[1], vaf='0.99')
    write_to_file(os.path.join(path, file_name + '.txt'), ans, mode)


def generate_test_independent_1():
    path = './results'
    file_pref_1 = 'test_insert'
    file_pref_2 = 'test_del'
    generate_cascade_inserts(path, file_pref_1, [[0, 1000, 'AAAAAAAAAAAAAAAAAAAA'],
                                                 [10000, 1000, 'GGGGGGGGGGGGGGGGGGGG'],
                                                 [20000, 1000, 'TTTTTTTTTTTTTTTTTTTT'],
                                                 [30000, 1000, 'CCCCCCCCCCCCCCCCCCCC']])
    generate_cascade_deletions(path, file_pref_2, [[0, 1000],
                                                   [10000, 1000],
                                                   [20000, 1000]])


if __name__ == "__main__":
    generate_test_independent_1()
