open Printf

let m = "jc"

let _ =
  open_out (sprintf "src/%s.cpp" m) |> close_out;
  open_out (sprintf "inc/%s.hpp" m) |> close_out
