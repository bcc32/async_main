open! Core
open! Async
open! Import

let async_main_or_error () =
  let%map z =
    let%bind x = return 1
    and y = return 2 in
    let%bind () = after (sec 0.001) in
    return (x + y)
  in
  if z <> 3 then Or_error.errorf "expected 3, got %d" z else Ok ()
;;

let () = unstage (async_or_error async_main_or_error) ()
