(** [Async_cmdliner] is {{!Core.Command}[Core.Command]} with additional Async functions.

    TODO
*)

open! Core
open! Async

type 'a command = ?extract_exn:bool -> 'a -> (unit -> unit) Staged.t

(* TODO doc comment below *)

(** [async] is like [Core.Command.basic], except that the main function it expects returns
    [unit Deferred.t], instead of [unit].  [async] will also start the Async scheduler
    before main is run, and will stop the scheduler when main returns.

    [async] also handles top-level exceptions by wrapping the user-supplied function in a
    [Monitor.try_with]. If an exception is raised, it will print it to stderr and call
    [shutdown 1]. The [extract_exn] argument is passed along to [Monitor.try_with]; by
    default it is [false]. *)
val async : (unit -> unit Deferred.t) command

(** [async_or_error] is like [async], except that the main function it expects may
    return an error, in which case it prints out the error message and shuts down with
    exit code 1. *)
val async_or_error : (unit -> unit Deferred.Or_error.t) command

(** Staged functions allow the main function to be separated into two stages.  The first
    part is guaranteed to run before the Async scheduler is started, and the second part
    will run after the scheduler is started.  This is useful if the main function runs
    code that relies on the fact that threads have not been created yet
    (e.g., [Daemon.daemonize]).

    As an example:
    {[
      let main () =
        assert (not (Scheduler.is_running ()));
        stage (fun `Scheduler_started ->
          assert (Scheduler.is_running ());
          Deferred.unit
        )
    ]}
*)

type 'r staged = ([ `Scheduler_started ] -> 'r) Staged.t

module Staged : sig
  val async : (unit -> unit Deferred.t staged) command
  val async_or_error : (unit -> unit Deferred.Or_error.t staged) command
end
