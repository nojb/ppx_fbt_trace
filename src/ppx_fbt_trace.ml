(*
 * Copyright (c) 2008, Jeremie Dimino <jeremie@dimino.org>
 * Copyright (c) 2012-2013, Anil Madhavapeddy <anil@recoil.org>
 * Copyright (c) 2014, Nicolas Ojeda Bar <n.oje.bar@gmail.com>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of the <organization> nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * 
 *)

open Parsetree
open Asttypes
open Ast_helper
open Ast_mapper
open Ast_convenience

let add_debug_expr name expr =
  let loc = expr.pexp_loc in
  let pos = loc.Location.loc_start in
  let l = Lexing.(Printf.sprintf "[%s at %d/%d]" pos.pos_fname pos.pos_lnum pos.pos_cnum) in    
  Exp.sequence ~loc (app (evar "Fbt_trace.print") [str l; str name]) expr

let map_match_case name case =
  {case with pc_rhs=add_debug_expr name case.pc_rhs}
  
let rec map_expr name expr =
  match expr with
    {pexp_desc=Pexp_fun (l, o, p, e)} ->
      {expr with pexp_desc=Pexp_fun (l, o, p, map_expr name e)}
  | {pexp_desc=Pexp_function cases} ->
      {expr with pexp_desc=Pexp_function (List.map (map_match_case name) cases)}
  | _ ->
      add_debug_expr name expr

let rec map_binding mapper vb =
  match vb with
    {pvb_pat={ppat_desc=Ppat_var {txt=func}}; pvb_expr={pexp_desc=Pexp_fun (l, o, p, e)}} ->
      {vb with pvb_expr={vb.pvb_expr with pexp_desc=Pexp_fun (l, o, p, map_expr func e)}}
  | {pvb_pat={ppat_desc=Ppat_var {txt=func}}; pvb_expr={pexp_desc=Pexp_function cases}} ->
      {vb with pvb_expr={vb.pvb_expr with pexp_desc=Pexp_function (List.map (map_match_case func) cases)}}
  | _ ->
      default_mapper.value_binding mapper vb

let rec map_str_item mapper stri =
  match stri with
    {pstr_desc=Pstr_value (rf, vbs)} ->
      {stri with pstr_desc=Pstr_value (rf, List.map (map_binding mapper) vbs)}
  | _ ->
      default_mapper.structure_item mapper stri

let trace_mapper argv =
  {default_mapper with structure_item = map_str_item}

let () =
  register "fbt_trace" trace_mapper
