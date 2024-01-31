(** A description of a watch-mode benchmark scenario. 3 benchmarks will be
    performed in each scenario:
      - Measure the time taken to rebuild after a benign change.
      - Measure the time taken to rebuild after a compile error is introduced.
      - Measure the time taken to rebuild after the compile error is fixe.
*)
type t = {
      (** The name of the scenario to identify it in current-bench results *)
  name : string;
      (** Path to file to change relative to the duniverse directory *)
  path_relative_to_duniverse : string;
      (** Some text in the file to replace during the scenario *)
  text_to_replace : string;
    (** A string which will replace [text_to_replace] when making the benign change *)
  text_changed_valid : string;
    (** A string which will replace [text_to_replace] when introducing a compile error *)
  text_changed_invalid : string;
}
