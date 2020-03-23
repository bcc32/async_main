open! Core
open! Async
open! Import

let async_main_or_error () =
  assert (not (Scheduler.is_running ()));
  stage (fun `Scheduler_started ->
    assert (Scheduler.is_running ());
    Deferred.Or_error.return ())
;;

let () = unstage (Staged.async_or_error async_main_or_error) ()
