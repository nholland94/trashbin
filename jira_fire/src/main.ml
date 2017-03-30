open Curl;;
open Yojson;;
open Core.Std;;
open Redis;;

let auth_header (username: string) (password: string) =
  ("Authorization", String.concat " " [ "Basic"; (
    B64.encode (String.concat ":" [username; password])
  )])
;;

let api_url path = String.concat "" [ "https://granicus.atlassian.net/rest/api/2/"; path ];;
let base_headers = [ (auth_header "username" "password"); ("Content-Type", "application/json") ];;

let header_string ((key, value): (string * string)) =
  String.concat ": " [ key; value ]
;;

let build_headers (ls: (string * string) list) =
  let rec recur_build_headers (ls: (string * string) list) (headers: string list) =
    match ls with
      head::tail -> recur_build_headers tail ((header_string head) :: headers)
    | _          -> headers
  in recur_build_headers ls []
;;

(*
  let header_sections = ref [] in
  List.iter (fun pair -> header_sections := (header_string pair) :: !header_sections) ls;
  !header_sections
;;
 *)

let get_http (url: string) (header_ls: (string * string) list) =
  let c = Curl.init () and buf = Buffer.create 16 in
  Curl.set_url c url;
  Curl.set_httpheader c (build_headers header_ls);
  Curl.set_followlocation c true;
  Curl.set_writefunction c (fun s ->
    try
      Buffer.add_string buf s; String.length s;
    with
    | exn -> print_string (Printexc.to_string exn); 0;
  );
  Curl.perform c;
  Curl.cleanup c;
  Buffer.contents buf
;;

let get_http_json (url: string) (header_ls: (string * string) list) =
  Yojson.Basic.from_string (get_http url header_ls)
;;

let redis_key (key_type: string) (id1: int) (id2: int) =
  String.concat ":" [ key_type; (string_of_int id1); (string_of_int id2) ]
;;

let update_redis_key_values (redis_data: (string * string) list) =

;;

let update_sprint_cache (sprint_id: int) =
  let response = get_http_json (api_url @@ String.concat "" [ "search?jql=sprint%3D"; string_of_int sprint_id ]) base_headers in
  let open Yojson.Basic.Util in
  let issues = response |> member "issues" |> to_list in

  let rec loop ls redis_data =
    match ls with
      head::tail -> (
        let issue = List.hd issues in
        let id = response |> member "id" |> to_int in
        let fields = response |> member "fields" in
        let data = Yojson.Basic.to_string fields in
        loop tail (((redis_key "sprint" sprint_id id), data) :: redis_data)
      )
    | _          -> redis_data
  in
  
  let redis_data = loop issues [] in
  update_redis_key_values redis_data
;;

print_string "\n";;
