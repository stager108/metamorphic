#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>

const int STRELKA_CONST = 50;
char mutation[51];
char letters[] = {'A', 'G', 'C', 'T'};

double randfrom(double min, double max) {
    double range = (max - min);
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

int is_nucleotide(char inp) {
    if ((inp != 'A') & (inp != 'G') & (inp != 'C') & (inp != 'T')) {
        return 0;
    } else {
        return 1;
    }
}

char random_nucleotide(char inp) {
    if ((inp != 'A') & (inp != 'G') & (inp != 'C') & (inp != 'T')) {
        return inp;
    }
    return letters[rand() % 4];
}

int write_varfile_mutation(FILE *outfile, const char *mut_type, int position, int length) {

    if (strcmp(mut_type, "INS") == 0) {
        fprintf(outfile, "Chromosome %d %d 1.00 INS %s\n",
                position, position + 1, mutation);
    } else {
        if (strcmp(mut_type, "DEL") == 0) {
            fprintf(outfile, "Chromosome %d %d 1.00 DEL\n",
                    position, position + length);
        }
    }
    return 0;
}

int random_point() {
    int x = rand() % 4;
    mutation[0] = letters[x];
    mutation[1] = '\0';
    return 0;
}

int mut_random_point(char inp) {
    int x = rand() % 4;
    while (1 == 1) {
        if (inp != letters[x]) {
            mutation[0] = letters[x];
            mutation[1] = '\0';
            return 0;
        }
        x = rand() % 4;
    }
}

int get_file_length(char *filename) {
    FILE *infile;
    char c[1000];
    char a;
    int length = 0;

    infile = fopen(filename, "r");
    fscanf(infile, "%[^\n]", c);
    while (fscanf(infile, "%c", &a) == 1) {
        length += is_nucleotide(a);
    }
    fclose(infile);
    return length;
}

int add_point_mutations(char *argv[]) {
    char a, c[1000];
    double prob = 0.05;
    FILE *infile, *outfile;
    infile = fopen(argv[1], "r");
    fscanf(infile, "%[^\n]", c);
    outfile = fopen(argv[2], "w");
    int i = 0;
    while (fscanf(infile, "%c", &a) == 1) {
        if (is_nucleotide(a)) {
            double p = randfrom(0.0, 1.0);
            if (p < prob) { // 0 - del, 1 - replace, 2 - insert
                int x = rand() % 3;
                switch (x) {
                    case 0:
                        write_varfile_mutation(outfile, "DEL", i, 1);
                        break;
                    case 1:
                        mut_random_point(a);
                        write_varfile_mutation(outfile, "INS", i, 1);
                        write_varfile_mutation(outfile, "DEL", i, 1);
                        break;
                    case 2:
                        random_point();
                        write_varfile_mutation(outfile, "INS", i, 1);
                        break;
                }
            }
            i += 1;
        }
    }
    fclose(infile);
    fclose(outfile);
    return 0;
}

int add_one_type_mutations(char *argv[], char type) {

    FILE *outfile;
    double prob = 0.0001;
    int filesize = 0;
    int file_length = get_file_length(argv[1]);
    outfile = fopen(argv[2], "w");
    while (filesize < file_length) {
        double p = randfrom(0.0, 1.0);
        if (p < prob) {
            int length = (rand() % (STRELKA_CONST - 1)) + 1;
            for (int i = 0; i < length; i += 1) {
                mutation[i] = random_nucleotide('A');
            }
            mutation[length] = '\0';
            switch (type) {
                case 'r':
                    write_varfile_mutation(outfile, "INS", filesize, 1);
                    length = (rand() % (STRELKA_CONST - 1)) + 1;
                    write_varfile_mutation(outfile, "DEL", filesize, length);
                    break;
                case 'd':
                    write_varfile_mutation(outfile, "DEL", filesize, length);
                    break;
                case 'i':
                    write_varfile_mutation(outfile, "INS", filesize, 1);
                    break;
            }
            filesize += 4;
        }
        filesize += 1;
    }
    fclose(outfile);
    return 0;
}

int main(int argc, char *argv[]) {

//  int size = atoi(argv[3]);
    int opt;
    while ((opt = getopt(argc, argv, "dipr")) != -1) {
        switch (opt) {
            case 'p':
                add_point_mutations(argv);
                break;
            case 'd':
                add_one_type_mutations(argv, 'd');
                break;
            case 'i':
                add_one_type_mutations(argv, 'i');
                break;
            case 'r':
                add_one_type_mutations(argv, 'r');
                break;
            default:
                fprintf(stderr, "Usage: %s [-pr] [input file, output file]\n", argv[0]);
                fprintf(stderr, "-p point mutations -i insertions -d deletions -r replacements\n");
                exit(EXIT_FAILURE);
        }
    }

    return 0;
}
