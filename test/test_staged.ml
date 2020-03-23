open! Core
open! Async
open! Import

let async_main () =
  assert (not (Scheduler.is_running ()));
  stage (fun `Scheduler_started ->
    assert (Scheduler.is_running ());
    return ())
;;

let () = unstage (Staged.async async_main) ()
