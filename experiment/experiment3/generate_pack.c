
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>

double randfrom(double min, double max) {
    double range = (max - min);
    double div = RAND_MAX / range;
    return min + (rand() / div);
}

int generate_tests(char *argv[], char opt) {
    char c[1000], input[100], output[100];
    char v;
    FILE *infile, *outfile;
    int n = atoi(argv[3]);
    strcpy(input, argv[1]);
    strcpy(output, argv[2]);
    int len = (int) strlen(argv[2]);
    output[len] = '0';
    output[len + 1] = '0';
    output[len + 2] = '\0';
    if (opt == 's'){    
        strcat(output, ".sam");
    } else {    
        strcat(output, ".txt");
    }
    printf("%s\n", output);
    double prob = 1.0;
    for (int i = 0; i < n; i += 1) {
        infile = fopen(input, "r");
        outfile = fopen(output, "w");
        if (opt == 's') {
            while ((fscanf(infile, "%[^\n]", c) == 1) & (c[0] == '@')) {
                fscanf(infile, "%c", &v);
                fprintf(outfile, "%s\n", c);
            }
            fscanf(infile, "%c", &v);
            double p = randfrom(0.0, 1.0);
            if (p < prob) {
                fprintf(outfile, "%s\n", c);
                for (int j = 0; j < 3; j++) {
                    if (fscanf(infile, "%[^\n]", c) == 1) {
                        fscanf(infile, "%c", &v);
                        fprintf(outfile, "%s\n", c);
                    }
                }
            }
            while (fscanf(infile, "%[^\n]", c) == 1) {
                fscanf(infile, "%c", &v);
                double p = randfrom(0.0, 1.0);
                if (p < prob) {
                    for (int j = 0; j < 4; j++) {
                        if (fscanf(infile, "%[^\n]", c) == 1) {
                            fscanf(infile, "%c", &v);
                            fprintf(outfile, "%s\n", c);
                        }
                    }
                }
            }
        } else {
            if (opt == 't') {
                while (fscanf(infile, "%[^\n]", c) == 1) {
                    fscanf(infile, "%c", &v);
                    double p = randfrom(0.0, 1.0);
                    if (p < prob) {
                        fprintf(outfile, "%s\n", c);
                    }
                }
            }
        }
        fclose(infile);
        fclose(outfile);
        strcpy(input, output);
        strcpy(output, argv[2]);
        if (i > 9) {
            output[len] = '0';
            output[len + 1] = (char) (i + 1) + '0';
            output[len + 2] = '\0';
        } else {
            output[len] = '0' + (char) ((i + 1) / 10);
            output[len + 1] = '0' + (char) ((i + 1) % 10);
            output[len + 2] = '\0';
        }
        if (opt == 's'){    
            strcat(output, ".sam");
        } else {    
            strcat(output, ".txt");
        }
        printf("%s\n", output);
        prob = 1.0 * (n - i - 1) / (n - i);
    }
    return 0;
}

int main(int argc, char *argv[]) {

//  int size = atoi(argv[3]);
    int opt;
    while ((opt = getopt(argc, argv, "st")) != -1) {
        switch (opt) {
            case 's':
            case 't':
                generate_tests(argv, (char) opt);
                break;
            default:
                fprintf(stderr, "Usage: %s [-pr] [input file, output file]\n", argv[0]);
                fprintf(stderr, "-s .sam file -t txt config\n");
                exit(EXIT_FAILURE);
        }
    }

    return 0;
}
