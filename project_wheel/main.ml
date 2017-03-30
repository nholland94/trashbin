open Thread;;

(* http://stackoverflow.com/questions/15095541/how-to-shuffle-list-in-on-in-ocaml *)
let shuffle d =
    let nd = List.map (fun c -> (Random.bits (), c)) d in
    let sond = List.sort compare nd in
    List.map snd sond
;;

let read_projects filename =
  let projects = ref [] in
  let channel = open_in filename in
  try
    while true; do
      projects := input_line channel :: !projects
    done; []
  with End_of_file ->
    close_in channel;
    shuffle !projects
;;

let spin_wheel option_ls =
  let option_ls_length = List.length option_ls in

  let longer_string a b = if (String.length a) > (String.length b) then a else b in
  let longest_option_length = String.length (List.fold_left longer_string "" option_ls) in

  let print_option ls selected_index =
    List.iteri (fun i head ->
      let identifier = if i == selected_index then "*" else " " in
      let right_padding = String.make (longest_option_length - (String.length head) + 1) ' ' in
      Printf.printf "|%s%s%s|\n" identifier head right_padding
    ) ls
  in

  let print_cap () = Printf.printf "|%s|\n" (String.make (longest_option_length + 2) '-') in

  let sleep_increment = 0.05 in
  let sleep_cap = 0.5 in
  let stop_on_index = 1 in

  let rec cycle_options current_index current_sleep =
    if current_sleep >= sleep_cap && current_index > stop_on_index then
      ()
    else begin
      print_cap ();
      print_option option_ls current_index;
      print_cap ();
      flush stdout;

      Thread.delay current_sleep;

      if current_index < (option_ls_length - 1) then
        cycle_options (current_index + 1) current_sleep
      else
        cycle_options 0 (current_sleep +. sleep_increment)
    end
  in

  cycle_options 0 0.1
;;

let projects = read_projects "projects";;

print_string "Project Wheel\n\n";;
flush stdout;;

spin_wheel projects;;
