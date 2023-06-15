let read ~path =
  let in_ = In_channel.open_text path in
  let s = In_channel.input_all in_ in
  In_channel.close in_;
  s

let write ~path ~data =
  let out_channel = Out_channel.open_text path in
  Out_channel.output_string out_channel data;
  Out_channel.close out_channel
