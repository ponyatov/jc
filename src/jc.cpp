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
    app_main();
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

std::string Object::val() { return value; }

std::string Object::pad(int depth) {
    std::ostringstream os;
    for (int i = 0; i < depth; i++) os << '\t';
    return os.str();
}

std::string Object::dump(int depth, std::string prefix) {  //
    std::ostringstream os;
    os << std::endl << pad(depth) << head(prefix);
    return os.str();
}

std::string Object::head(std::string prefix) {
    std::ostringstream ret;
    ret << prefix;                               // prefix
    ret << '<' << tag() << ':' << val() << '>';  // <T:V>
    ret << " @" << this << " #" << ref;          // allocation
    return ret.str();
}

std::string Int::val() { return std::to_string(value); }

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

std::string Bin::val() {
    std::ostringstream os;
    os << std::bitset<8>(value);
    return os.str();
}
