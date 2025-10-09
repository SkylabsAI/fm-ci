open Extra

let getenv : ?allow_empty:bool -> string -> string =
    fun ?(allow_empty=false) var ->
  match Option.map String.trim (Sys.getenv_opt var) with
  | None    -> panic "Environment variable %s is not defined." var
  | Some(v) ->
  if v <> "" || allow_empty then v else
  panic "Environment variable %s is defined, but empty." var

type trigger = {
  project_title : string;
  project_path : string;
  project_name : string;
  commit_sha : string;
  commit_branch : string option;
  pipeline_source : string;
  trigger_kind : string;
  trim_dune_cache : bool;
  only_full_build : bool;
}

let getenv_bool : default:bool -> string -> bool = fun ~default var ->
  match Sys.getenv_opt var with
  | None                       -> default
  | Some("false") | Some("0")  -> false
  | Some("true") | Some("1")   -> true
  | Some(s) when s = "$" ^ var -> default
  (* ^^ result from Gitlab CI expansion *)
  | Some(s)                    -> panic "Unexpected value for %s: %S." var s

let get_trigger : unit -> trigger =
    fun _ ->
  let project_title = getenv "ORIGIN_CI_PROJECT_TITLE" in
  let project_path = getenv "ORIGIN_CI_PROJECT_PATH" in
  let commit_sha = getenv "ORIGIN_CI_COMMIT_SHA" in
  let commit_branch =
    let branch = getenv ~allow_empty:true "ORIGIN_CI_COMMIT_BRANCH" in
    if branch = "" then None else Some(branch)
  in
  let pipeline_source = getenv "ORIGIN_CI_PIPELINE_SOURCE" in
  let trigger_kind = getenv "FM_CI_TRIGGER_KIND" in
  let project_name =
    let prefix = "skylabs_ai/" in
    if not (String.starts_with ~prefix project_path) then
      panic "Project path %s does not start with %s." project_path prefix;
    let prefix_len = String.length prefix in
    let len = String.length project_path in
    String.sub project_path prefix_len (len - prefix_len)
  in
  let trim_dune_cache =
    getenv_bool ~default:false "FM_CI_TRIM_DUNE_CACHE"
  in
  let only_full_build =
    getenv_bool ~default:false "FM_CI_ONLY_FULL_BUILD"
  in
  if only_full_build && not (pipeline_source = "schedule") then
    panic "Full-build-only jobs are only for scheduled pipelines.";
  {project_title; project_path; project_name; commit_sha; commit_branch;
   pipeline_source; trigger_kind; trim_dune_cache; only_full_build}

type mr = {
  mr_iid : string;
  mr_labels : string list;
  mr_project_id : string;
  mr_source_branch_name : string;
  mr_target_branch_name : string;
  pipeline_url : string;
}

let get_mr : unit -> mr option = fun _ ->
  let mr_iid = getenv ~allow_empty:true "ORIGIN_CI_MERGE_REQUEST_IID" in
  match mr_iid with "" -> None | _ ->
  let mr_labels =
    getenv ~allow_empty:true "ORIGIN_CI_MERGE_REQUEST_LABELS"
  in
  let mr_project_id =
    getenv "ORIGIN_CI_MERGE_REQUEST_PROJECT_ID"
  in
  let mr_source_branch_name =
    getenv "ORIGIN_CI_MERGE_REQUEST_SOURCE_BRANCH_NAME"
  in
  let mr_target_branch_name =
    getenv "ORIGIN_CI_MERGE_REQUEST_TARGET_BRANCH_NAME"
  in
  let pipeline_url =
    getenv "ORIGIN_CI_PIPELINE_URL"
  in
  let mr_labels = String.split_on_char ',' mr_labels in
  let mr =
    {mr_iid; mr_labels; mr_project_id; mr_source_branch_name;
     mr_target_branch_name; pipeline_url}
  in
  Some(mr)
