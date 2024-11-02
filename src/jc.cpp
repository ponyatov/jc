#include "jc.hpp"

int main(int argc, char *argv[]) {
    arg(0, argv[0]);
    for (int i = 1; i < argc; i++) {
        arg(i, argv[i]);
        yyfile = argv[i];
        assert(yyin = fopen(yyfile, "r"));
        yyparse();
        fclose(yyin);
        yyfile = nullptr;
    }
}

void arg(int argc, char *argv) {  //
    fprintf(stderr, "argv[%i] = <%s>\n", argc, argv);
}

std::list<Object *> Object::pool;

Object::Object() {
    ref = 0;
    pool.push_front(this);
}

Object::~Object() { pool.remove(this); }

Object::Object(std::string V) : Object() { value = V; }

#include <cxxabi.h>
std::string Object::tag() {
    std::string ret = abi::__cxa_demangle(typeid(*this).name(), 0, 0, nullptr);
    for (char &c : ret) c = tolower(c);
    return ret;
}

std::string Object::head(std::string prefix) {
    std::ostringstream ret;
    ret << prefix;                               // prefix
    ret << '<' << tag() << ':' << val() << '>';  // <T:V>
    ret << " @" << this << " #" << ref;          // allocation
    return ret.str();
}

std::string Hex::val() {
    std::ostringstream os;
    os << std::hex << value;
    return os.str();
}

std::string Oct::val() {
    std::ostringstream os;
    os << std::oct << value;
    return os.str();
}

// std::string Bin::val() {
//     std::ostringstream os;
//     os << std::binary << value;
//     return os.str();
// }
