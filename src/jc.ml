open Printf

let m = "jc"

let incl cpp hpp =
  fprintf cpp "#include \"%s.hpp\"\n" m;
  fprintf hpp "#pragma once\n"

let _ =
  let cpp = open_out (sprintf "src/%s.cpp" m) in
  let hpp = open_out (sprintf "inc/%s.hpp" m) in
  incl cpp hpp;
  cpp |> close_out;
  hpp |> close_out
