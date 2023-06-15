type t = { program : string; args : string list }

let create program args = { program; args }
let to_string { program; args } = String.concat " " (program :: args)

module Exit_status = struct
  type t = int
end

module Running = struct
  type nonrec t = { pid : int; command : t }

  let wait_exn { pid; command } =
    let got_pid, status = Unix.waitpid [] pid in
    if got_pid <> pid then failwith "wait returned unexpected pid";
    match status with
    | Unix.WEXITED status -> status
    | _ ->
        failwith
          (Printf.sprintf "`%s` unexpected process status" (to_string command))

  let term { pid; _ } = Unix.kill pid Sys.sigterm
end

module Stdio_redirect = struct
  type t = [ `This_process | `Ignore ]
end

let dev_null = Unix.openfile "/dev/null" [ Unix.O_RDWR ] 0
let args_arr { program; args } = Array.of_list (program :: args)

let run_background t ~stdio_redirect =
  let stdin, stdout, stderr =
    match stdio_redirect with
    | `This_process -> (Unix.stdin, Unix.stdout, Unix.stderr)
    | `Ignore -> (dev_null, dev_null, dev_null)
  in
  let pid = Unix.create_process t.program (args_arr t) stdin stdout stderr in
  { Running.pid; command = t }

let run_blocking_exn t ~stdio_redirect =
  run_background t ~stdio_redirect |> Running.wait_exn
