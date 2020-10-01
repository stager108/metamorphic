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

int main(int argc, char *argv[]) {
    char c[1000];
    double prob = 0.05;
    FILE *infile, *outfile;
//  int size = atoi(argv[3]);
    int opt;
    char a;
    while ((opt = getopt(argc, argv, "pr")) != -1) {
        switch (opt) {
            case 'p':
                infile = fopen(argv[1], "r");
                outfile = fopen(argv[2], "w");
                fscanf(infile, "%[^\n]", c);
                fprintf(outfile, "%s", c);
                while (fscanf(infile, "%c", &a) == 1) {
                    fprintf(outfile, "%c", random_point_mut(a, prob));
                }
                break;
            case 'r':
                infile = fopen(argv[1], "r");
                outfile = fopen(argv[2], "w");
                fscanf(infile, "%[^\n]", c);
                fprintf(outfile, "%s", c);
                while (fscanf(infile, "%c", &a) == 1) {
                    fprintf(outfile, "%c", random_nucleotide(a));
                }
                break;
            default:
                fprintf(stderr, "Usage: %s [-pr] [input file, output file]\n", argv[0]);
                fprintf(stderr, "-p point mutations -r random genome\n");
                exit(EXIT_FAILURE);
        }
    }

    fclose(infile);
    fclose(outfile);
    return 0;
}
