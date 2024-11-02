#include "jc.hpp"

extern "C" void app_main(void) { arg(0, "jc@esp32"); }

void arg(int argc, char *argv) {  //
    fprintf(stderr, "argv[%i] = <%s>\n", argc, argv);
}
