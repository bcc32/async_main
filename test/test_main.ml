open! Core
open! Async
open! Import

let async_main () =
  let%bind z =
    let%bind x = return 1
    and y = return 2 in
    let%bind () = after (sec 0.001) in
    return (x + y)
  in
  assert (z = 3);
  return ()
;;

let () = unstage (async async_main) ()
