 
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>


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
    fprintf(outfile, ">Chromosome dna:chromosome chromosome:ASM1036v1:Chromosome:1:%d:1 REF", length);
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

int generate_random(char *argv[]) {
    char c[1000];
    FILE *infile, *outfile;
    char a;
    infile = fopen(argv[1], "r");
    outfile = fopen(argv[2], "w");
    fprintf(outfile, "%s", c);
    while (fscanf(infile, "%c", &a) == 1) {
        fprintf(outfile, "%c", random_nucleotide(a));
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
                fprintf(stderr, "Usage: %s [-pr] [input file, output file]\n", argv[0]);
                fprintf(stderr, "-p point mutations -i insertions -d deletions -r random genome\n");
                exit(EXIT_FAILURE);
        }
    }

    return 0;
}
