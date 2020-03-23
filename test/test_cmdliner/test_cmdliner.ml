open! Core
open! Async
open! Import

let nat_pipe start =
  Pipe.create_reader ~close_on_exception:false (fun w ->
    Deferred.forever start (fun start -> Pipe.write w start >>| Fn.const (start + 1));
    never ())
;;

let filter_multiples_of ~divisor = Pipe.filter ~f:(fun n -> n % divisor <> 0)

let prime_pipe () =
  Pipe.create_reader ~close_on_exception:false (fun w ->
    let rec loop input =
      match%bind Pipe.read input with
      | `Eof -> failwith "unexpected EOF"
      | `Ok n ->
        let%bind () = Pipe.write w n in
        loop (filter_multiples_of input ~divisor:n)
    in
    loop (nat_pipe 2))
;;

let print_first_n_primes num_values () =
  match%map Pipe.read_exactly ~num_values (prime_pipe ()) with
  | `Eof | `Fewer _ -> failwith "not enough values produced"
  | `Exactly primes -> print_s [%sexp (primes : int Queue.t)]
;;

let limit = Arg.(value & opt int 10 & info ~docv:"LIMIT" [ "l"; "limit" ])

let () =
  let main =
    Term.(
      const unstage
      $ (const (async ?extract_exn:None) $ (const print_first_n_primes $ limit))
      $ const ())
  in
  let info = Term.info "test executable" in
  Term.exit @@ Term.eval (main, info)
;;
