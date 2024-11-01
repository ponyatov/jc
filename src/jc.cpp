#include "jc.hpp"

int main(int argc, char *argv[]) {  //
    arg(0, argv[0]);
}

void arg(int argc, char *argv) {  //
    fprintf(stderr, "argv[%i] = <%s>\n", argc, argv);
}
