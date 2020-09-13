#!/usr/bin/env python3
import os
import random

def generate_varfile_insert(chrom_num, insert_num, indel, file_length, vaf='0.99'):
    chrom_num = str(chrom_num)
    ans = ''
    for i in range(insert_num):
        position = random.randint(0, file_length - 1)
        ans += ' '.join([chrom_num, 
                        str(position),
                        str(position + 1),
                        str(vaf),
                        indel + '\n'])
    return ans

def write_to_file(file, text, mode='w'):
    with open(file, mode) as f:
        f.write(text)
      
    
if __name__ == "__main__":
    ans = generate_varfile_insert(1, 3, 'AAA', 1000)
    write_to_file('./carsonella/test_indel.txt', ans, 'a')
    ans = generate_varfile_insert(1, 3, 'BBB', 1000)
    write_to_file('./carsonella/test_indel.txt', ans, 'a') 
