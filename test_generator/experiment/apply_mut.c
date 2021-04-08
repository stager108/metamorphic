#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include <regex.h>

const int MIN_COPY_SIZE = 10000;
const int COPY_INTERVAL = 20000;

char header[1000];
FILE *infile, *outfile, *config;
char tmp_file[8] = "raw.txt";

void open_files(char *argv[]) {
    infile = fopen(argv[1], "r");
    outfile = fopen(tmp_file, "w");
    config = fopen(argv[3], "r");
}

void close_files() {
    fclose(infile);
    fclose(outfile);
    fclose(config);
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

int generate_random(char *argv[]) {
    char c[1000];
    char a;
    infile = fopen(argv[1], "r");
    outfile = fopen(argv[2], "w");
    fscanf(infile, "%[^\n]", c);
    fprintf(outfile, "%s", c);
    while (fscanf(infile, "%c", &a) == 1) {
        fprintf(outfile, "%c", random_nucleotide(a));
    }
    fclose(infile);
    fclose(outfile);
    return 0;
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

char *fix_header_string(char *txt, int new1, char *target) {

    //>2L dna:primary_assembly primary_assembly:BDGP6.32:2L:1:23513712:1 REF

    char num[11];
    int i, sc[2], j = 0;
    sprintf(num, "%d", new1);

    int len_num = (int) strlen(num);
    int len_text = (int) strlen(txt);

    for (i = len_text - 1; (i >= 0) && (j < 2); i--)
        if (txt[i] == ':')
            sc[j++] = i;
    j = 0;

    for (i = 0; i <= sc[1]; i++)
        target[j++] = txt[i];
    for (i = 0; i < len_num; i++)
        target[j++] = num[i];
    i = sc[0];
    do {
        target[j++] = txt[i];
    } while (txt[i++] != 0);
    return target;
}

int fix_header(char *out_file, int length) {
    char a;
    infile = fopen(tmp_file, "r");
    outfile = fopen(out_file, "w");
    int cur_length = 0;
    int header_length = strlen(header);
    char target[header_length + 1];
    fprintf(outfile, "%s\n", fix_header_string(header, length, target));
    while (fscanf(infile, "%c", &a) == 1) {
        cur_length += is_nucleotide(a);
        if (is_nucleotide(a) == 1) {
            fprintf(outfile, "%c", a);
        }
        if ((cur_length % 60 == 0) & (is_nucleotide(a))) {
            fprintf(outfile, "%c", '\n');
        }
    }
    fclose(infile);
    fclose(outfile);
    return 0;
}

int add_mutations(char *argv[]) {
    char a, c;
    int start, length;
    int filesize = 0;
    int position = 0;
    int err = 0;
    int k = 0;

    open_files(argv);
    fscanf(infile, "%[^\n]", header);

    char *chromosome = get_chromosome(header);
    char copy_buffer[COPY_INTERVAL + MIN_COPY_SIZE + 1];

    while (fscanf(config, "%c %d %d", &a, &start, &length) == 3) {
        //printf("%c %d %d\n", a, start, length);
        while (position != start) {
            if (fscanf(infile, "%c", &c) != 1) {
                break;
            }
            fprintf(outfile, "%c", c);
            filesize += is_nucleotide(c);
            position += is_nucleotide(c);
        }
        switch (a) {
            case 'i':
                err = fscanf(config, "%c", &c);
                while (c == ' ') {
                    err = fscanf(config, "%c", &c);
                }
                for (int j = 0; j < length; j++) {
                    fprintf(outfile, "%c", c);
                    filesize++;
                    err = fscanf(config, "%c", &c);
                }
                break;

            case 'd':
                k = 0;
                while (k < length) {
                    if (fscanf(infile, "%c", &c) != 1) {
                        break;
                    }
                    k += is_nucleotide(c);
                }
                position += k;
                err = fscanf(config, "%c", &c);
                break;

            case 'c':
                k = 0;
                while (k < length) {
                    if (fscanf(infile, "%c", &c) != 1) {
                        length = k;
                        break;
                    } else {

                        fprintf(outfile, "%c", c);
                        filesize += is_nucleotide(c);
                        position += is_nucleotide(c);
                        if (is_nucleotide(c) == 1) {
                            copy_buffer[k] = c;
                            k++;
                        }
                    }
                }

                for (int i = 0; i < length; i++) {
                    fprintf(outfile, "%c", copy_buffer[i]);
                    filesize++;
                }

                err = fscanf(config, "%c", &c);
                break;

            default:
                break;
        }
    }
    //printf("%d", err);
    while (fscanf(infile, "%c", &c) == 1) {
        fprintf(outfile, "%c", c);
        filesize += is_nucleotide(c);
    }
    close_files();
    free(chromosome);
    fix_header(argv[2], filesize);
    return 0;
}

int main(int argc, char *argv[]) {

//  int size = atoi(argv[3]);
    int opt;
    while ((opt = getopt(argc, argv, "ar")) != -1) {
        switch (opt) {
            case 'r':
                generate_random(argv);
                break;
            case 'a':
                add_mutations(argv);
                break;
            default:
                fprintf(stderr, "Usage: %s [-ar] [input file, output file, config file]\n", argv[0]);
                fprintf(stderr, "-a add mutations -r random genome\n");
                exit(EXIT_FAILURE);
        }
    }

    return 0;
}
