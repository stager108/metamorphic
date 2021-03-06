#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>

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
    if ((inp != 'A') & (inp != 'G') & (inp != 'C') & (inp != 'T')) {
        return 0;
    } else {
        return 1;
    }
}

int fix_header(char *tmpfile, char *outputfile, int length) {
    FILE *infile, *outfile;
    char a;
    infile = fopen(tmpfile, "r");
    outfile = fopen(outputfile, "w");
    int cur_length = 0;
    fprintf(outfile, ">Chromosome dna:chromosome chromosome:ASM1036v1:Chromosome:1:%d:1 REF\n", length);
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

int add_point_mutations(char *argv[]) {
    char a, c[1000];
    double prob = 0.005;
    FILE *infile, *outfile, *config;

    char tmpfile[8] = "raw.txt";

    infile = fopen(argv[1], "r");
    outfile = fopen(tmpfile, "w");
    config = fopen(argv[3], "w");
    fscanf(infile, "%[^\n]", c);
    int i = 0;
    int filesize = 0;
    while (fscanf(infile, "%c", &a) == 1) {
        int x = rand() % 3;
        char b = random_point_mut(a, prob);
        double p = randfrom(0.0, 1.0);
        if ((is_nucleotide(a)) & (p < prob)) {
            // 0 - del, 1 - replace, 2 - insert
            if (x == 0) {
                fprintf(config, "Chromosome %d %d 1.00 DEL \n", i + 1, i + 2);
            }
            if (x == 1) {
                fprintf(outfile, "%c", b);
                fprintf(config, "Chromosome %d %d 1.00 DEL \n", i + 1, i + 2);
                fprintf(config, "Chromosome %d %d 1.00 INS %c\n", i + 1, i + 2, b);
                filesize += 1;
            }
            if (x > 1) {
                fprintf(outfile, "%c", b);
                fprintf(outfile, "%c", a);
                filesize += 2;
                fprintf(config, "Chromosome %d %d 1.00 INS %c\n", i + 1, i + 2, b);
            }
            i += 1;
        } else {
            fprintf(outfile, "%c", a);
            i += is_nucleotide(a);
        }
    }
    fclose(infile);
    fclose(outfile);
    fclose(config);
    fix_header(tmpfile, argv[2], filesize);
    return 0;
}

int generate_random(char *argv[]) {
    char c[1000];
    FILE *infile, *outfile;
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


int add_insertions(char *argv[]) {
    char c[1000];
    char tmpfile[8] = "raw.txt";
    FILE *infile, *outfile, *config;
    char a;
    double prob = 0.0001;
    int filesize = 0;
    infile = fopen(argv[1], "r");
    outfile = fopen(tmpfile, "w");
    config = fopen(argv[3], "w");
    fscanf(infile, "%[^\n]", c);
    int position = 0;
    while (fscanf(infile, "%c", &a) == 1) {
        double p = randfrom(0.0, 1.0);
        if (p < prob) {
            int length = (rand() % 50) + 1;
            fprintf(config, "Chromosome %d %d 1.00 INS ", filesize + 1, filesize + 2);
            for (int i = 0; i < length; i += 1) {
                char b = random_nucleotide('A');
                fprintf(outfile, "%c", b);
                fprintf(config, "%c", b);
                filesize += 1;
                if (i % 60 == 0) {
                    fprintf(outfile, "%c", '\n');
                }
            }
            fprintf(config, "%c", '\n');
        }
        filesize += is_nucleotide(a);
        position += is_nucleotide(a);
        fprintf(outfile, "%c", a);
    }
    fclose(infile);
    fclose(outfile);
    fclose(config);
    fix_header(tmpfile, argv[2], filesize);
    return 0;
}

int add_deletions(char *argv[]) {
    char c[1000];
    FILE *infile, *outfile, *config;
    char tmpfile[8] = "raw.txt";
    char a;
    int filesize = 0;
    double prob = 0.0001;
    infile = fopen(argv[1], "r");
    outfile = fopen(tmpfile, "w");
    config = fopen(argv[3], "w");
    fscanf(infile, "%[^\n]", c);
    int i = 0;
    while (fscanf(infile, "%c", &a) == 1) {
        double p = randfrom(0.0, 1.0);
        if (p < prob) {
            int length = (rand() % 50) + 1;
            fprintf(config, "Chromosome %d %d 1.00 DEL \n", i + 1, i + length + 1);
            i += length;
            for (int j = 0; j < length; j += 1) {
                if (fscanf(infile, "%c", &a) != 1) {
                    break;
                }
            }
        } else {
            fprintf(outfile, "%c", a);
            filesize += is_nucleotide(a);
            i += is_nucleotide(a);
        }
    }
    fclose(infile);
    fclose(outfile);
    fclose(config);
    fix_header(tmpfile, argv[2], filesize);
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
            case 'r':
                generate_random(argv);
                break;
            case 'd':
                add_deletions(argv);
                break;
            case 'i':
                add_insertions(argv);
                break;
            default:
                fprintf(stderr, "Usage: %s [-pr] [input file, output file, output config file]\n", argv[0]);
                fprintf(stderr, "-p point mutations -i insertions -d deletions -r random genome\n");
                exit(EXIT_FAILURE);
        }
    }

    return 0;
}
