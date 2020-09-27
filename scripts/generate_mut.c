#include <stdio.h>
#include <stdlib.h>

double randfrom(double min, double max) {
    double range = (max - min);
    double div = RAND_MAX / range;
    return min + (rand() / div);
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
    double prob = 0.05;
    char c[1000];
    FILE *infile, *outfile;
    infile = fopen(argv[1], "r");
    outfile = fopen(argv[2], "w");

    fscanf(infile, "%[^\n]", c);
    fprintf(outfile, "%s", c);

    char a;
    while (fscanf(infile, "%c", &a) == 1) {
        fprintf(outfile, "%c", random_point_mut(a, prob));
    }
    fclose(infile);
    fclose(outfile);
    return 0;
}
