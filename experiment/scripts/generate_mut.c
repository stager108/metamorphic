#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <regex.h>

const int MAX_SMALL_MUT_SIZE = 50;
const int MIN_COPY_SIZE = 5000;
const int COPY_INTERVAL = 5000;
const int INTERVAL = 10000;

const double INDEL_PROBABILITY = 0.0001;
const double COPYNUMBER_PROBABILITY = 0.001;
const double POINT_MUTATION_PROBABILITY = 0.005;


char header[1000];
FILE *infile, *config, *inner_config;
char a;
int filesize = 0;
int position = 0;
char *chromosome;

void open_files(char *argv[]) {
    infile = fopen(argv[1], "r");
    config = fopen(argv[2], "w");
    char *inn_config_name = (char *) malloc(strlen(argv[2]) + 7);
    strcpy(inn_config_name, argv[2]);
    inner_config = fopen(strcat(inn_config_name, ".inner"), "w");
    free(inn_config_name);
}

void close_files() {
    fclose(infile);
    fclose(config);
    fclose(inner_config);
}

double randfrom(double min, double max) {
    double range = (max - min);
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

char random_nucleotide(char inp) {
    char letters[] = {'A', 'G', 'C', 'T'};
    if ((inp != 'A') & (inp != 'G') & (inp != 'C') & (inp != 'T')) {
        return inp;
    }
    return letters[rand() % 4];
}

int is_nucleotide(char inp) {
    if ((inp != 'A') & (inp != 'G') & (inp != 'C') & (inp != 'T') & (inp != 'N')) {
        return 0;
    } else {
        return 1;
    }
}

char *get_chromosome(char *header) {
    size_t i = 0;
    size_t len_num = (int) strlen(header);
    while ((header[i] != ' ') && (i < len_num)) {
        i++;
    }
    char *substr = (char *) malloc((i + 10) * sizeof(char));
    strncpy(substr, header + 1 * sizeof(char), (i - 1) * sizeof(char));
    substr[i - 1] = 0;
    return substr;
}

char random_point_mut(char inp, double prob) {
    double p = randfrom(0.0, 1.0);
    char letters[] = {'A', 'G', 'C', 'T'};
    if ((inp != 'A') & (inp != 'G') & (inp != 'C') & (inp != 'T')) {
        return inp;
    }
    if (p < prob) {
        int x = rand() % 4;
        while (1 == 1) {
            if (inp != letters[x]) {
                return letters[x];
            }
            x = rand() % 4;
        }
    } else {
        return inp;
    }
}

int add_point_mutations(int edge) {
    while ((fscanf(infile, "%c", &a) == 1) && (position < edge)) {
        int x = rand() % 3;
        char b = random_point_mut(a, POINT_MUTATION_PROBABILITY);
        double p = randfrom(0.0, 1.0);
        if ((is_nucleotide(a)) & (p < POINT_MUTATION_PROBABILITY)) {
            // 0 - del, 1 - replace, 2 - insert
            if (x == 0) {
                fprintf(config, "%s %d %d 1.00 DEL \n", chromosome, position + 1, position + 2);
                fprintf(inner_config, "d %d %d\n", position, 1);
            }
            if (x > 0) {
                filesize += 2;
                fprintf(config, "%s %d %d 1.00 INS %c\n", chromosome, position + 1, position + 2, b);
                fprintf(inner_config, "i %d %d %c\n", position, 1, b);
            }
            position++;
        } else {
            position += is_nucleotide(a);
        }
    }
    return 0;
}

int add_insertions(int edge) {

    while ((fscanf(infile, "%c", &a) == 1) && (position < edge)) {
        double p = randfrom(0.0, 1.0);
        if (p < INDEL_PROBABILITY) {
            int length = (rand() % MAX_SMALL_MUT_SIZE) + 1;
            fprintf(config, "%s %d %d 1.00 INS ", chromosome, filesize + 1, filesize + 2);
            fprintf(inner_config, "i %d %d ", filesize, length);

            for (int i = 0; i < length; i++) {
                char b = random_nucleotide('A');
                fprintf(config, "%c", b);
                fprintf(inner_config, "%c", b);
                filesize++;
            }
            fprintf(config, "%c", '\n');
            fprintf(inner_config, "%c", '\n');
        }
        filesize += is_nucleotide(a);
        position += is_nucleotide(a);
    }
    return 0;
}


int add_deletions(int edge) {
    int i = 0;
    int k = 0;
    while ((fscanf(infile, "%c", &a) == 1) && (position < edge)) {
        double p = randfrom(0.0, 1.0);
        if (p < INDEL_PROBABILITY) {
            int length = (rand() % MAX_SMALL_MUT_SIZE) + 1;
            k = 0;
            while (k < length) {
                if ((fscanf(infile, "%c", &a) != 1) || (position >= edge)) {
                    length = k;
                    break;
                } else {
                    i += is_nucleotide(a);
                    k += is_nucleotide(a);
                }
            }
            fprintf(config, "%s %d %d 1.00 DEL \n", chromosome, i + 1, i + length + 1);
            fprintf(inner_config, "d %d %d\n", i, length);
            i += length;
        } else {
            filesize += is_nucleotide(a);
            i += is_nucleotide(a);
        }
    }
    return 0;
}

int add_copies(int edge) {
    int k;
    while ((fscanf(infile, "%c", &a) == 1) && (position < edge)) {
        double p = randfrom(0.0, 1.0);
        if (p < COPYNUMBER_PROBABILITY) {
            int length = (rand() % COPY_INTERVAL) + MIN_COPY_SIZE;
            k = 0;
            while (k < length) {
                if ((fscanf(infile, "%c", &a) != 1) || (position >= edge)) {
                    length = k;
                    break;
                } else {
                    filesize += is_nucleotide(a);
                    k += is_nucleotide(a);
                }
            }

            fprintf(config, "%s %d %d DUP %d 1.0 ", chromosome, filesize + 1, filesize + length + 1, rand() % 3 + 1);
            fprintf(inner_config, "c %d %d\n", filesize, length);
            filesize += length;
            position += length;
            fprintf(config, "%c", '\n');
        }
        filesize += is_nucleotide(a);
        position += is_nucleotide(a);
    }
    return 0;
}

int add_big_deletions(char *argv[]) {
    int k;
    int position = 0;
    while (fscanf(infile, "%c", &a) == 1) {
        double p = randfrom(0.0, 1.0);
        if (p < COPYNUMBER_PROBABILITY) {
            int length = (rand() % COPY_INTERVAL) + MIN_COPY_SIZE;
            k = 0;
            while (k < length) {
                if (fscanf(infile, "%c", &a) != 1) {
                    length = k;
                    break;
                } else {
                    filesize += is_nucleotide(a);
                    k += is_nucleotide(a);
                }
            }
            fprintf(config, "%s %d %d BIGDEL 0.5 ", chromosome, filesize + 1, filesize + length + 1);
            fprintf(inner_config, "d %d %d ", filesize, length);
            fprintf(config, "%c", '\n');
            fprintf(inner_config, "%c", '\n');
        }
        filesize += is_nucleotide(a);
        position += is_nucleotide(a);
    }
    return 0;
}

int generate_mix(char *argv[], char opt) {

    open_files(argv);
    int length = 0;
    fscanf(infile, "%[^\n]", header);
    chromosome = get_chromosome(header);
    while (fscanf(infile, "%c", &a) == 1) {
        filesize += is_nucleotide(a);
        position += is_nucleotide(a);
        length = rand() % INTERVAL;
        add_copies(position + length);
        length = rand() % INTERVAL;
        switch (opt) {
            case 'd':
                add_deletions(position + length);
                break;
            case 'i':
                add_insertions(position + length);
                break;
            case 'p':
                add_point_mutations(position + length);
                break;
            default:
                break;
        }
    }

    close_files();
    free(chromosome);
    return 0;
}


int main(int argc, char *argv[]) {

    int opt;
    while ((opt = getopt(argc, argv, "idp")) != -1) {
        switch (opt) {
            case 'i':
            case 'd':
            case 'p':
                generate_mix(argv, opt);
                break;

            default:
                fprintf(stderr, "Usage: %s [-pr] [input file, output config file]\n", argv[0]);
                fprintf(stderr, "-i insertions -d deletions -p point mutations\n");
                exit(EXIT_FAILURE);
        }
    }

    return 0;
}
