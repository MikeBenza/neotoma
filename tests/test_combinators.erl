-module(test_combinators).
-author("Sean Cribbs <seancribbs@gmail.com>").
-include_lib("eunit/include/eunit.hrl").

% Test the parser-combinators in the 'peg' module
-define(STARTINDEX, {{line,1},{column,1}}).
eof_test_() ->
  [
   ?_assertEqual({fail,{expected,eof,?STARTINDEX}}, (peg:p_eof())("abc",?STARTINDEX)),
   ?_assertEqual({eof, [], ?STARTINDEX}, (peg:p_eof())("",?STARTINDEX))
  ].

optional_test_() ->
  [
   ?_assertEqual({[], "xyz",?STARTINDEX}, (peg:p_optional(peg:p_string("abc")))("xyz",?STARTINDEX)),
   ?_assertEqual({"abc", "xyz",{{line,1},{column,4}}}, (peg:p_optional(peg:p_string("abc")))("abcxyz",?STARTINDEX))
  ].

not_test_() ->
  [
   ?_assertEqual({[], "xyzabc",?STARTINDEX}, (peg:p_not(peg:p_string("abc")))("xyzabc",?STARTINDEX)),
   ?_assertEqual({fail,{expected, {no_match, "abc"}, ?STARTINDEX}}, (peg:p_not(peg:p_string("abc")))("abcxyz",?STARTINDEX))
  ].

assert_test_() ->
  [
   ?_assertEqual({fail,{expected, {string, "abc"}, ?STARTINDEX}}, (peg:p_assert(peg:p_string("abc")))("xyzabc",?STARTINDEX)),
   ?_assertEqual({[], "abcxyz",?STARTINDEX}, (peg:p_assert(peg:p_string("abc")))("abcxyz",?STARTINDEX))
  ].

seq_test_() ->
  [
   ?_assertEqual({["abc","def"], "xyz",{{line,1},{column,7}}}, (peg:p_seq([peg:p_string("abc"), peg:p_string("def")]))("abcdefxyz",?STARTINDEX)),
   ?_assertEqual({fail,{expected, {string, "def"}, {{line,1},{column,4}}}}, (peg:p_seq([peg:p_string("abc"), peg:p_string("def")]))("abcxyz",?STARTINDEX))
  ].

choose_test_() ->
  [
   ?_assertEqual({"abc", "xyz", {{line,1},{column,4}}}, (peg:p_choose([peg:p_string("abc"), peg:p_string("def")]))("abcxyz",?STARTINDEX)),
   ?_assertEqual({"def", "xyz", {{line,1},{column,4}}}, (peg:p_choose([peg:p_string("abc"), peg:p_string("def")]))("defxyz",?STARTINDEX)),
   ?_assertEqual({"xyz", "xyz", {{line,1},{column,4}}}, (peg:p_choose([peg:p_string("abc"), peg:p_string("def"), peg:p_string("xyz")]))("xyzxyz",?STARTINDEX)),
   ?_assertEqual({fail,{expected,{string,"abc"},?STARTINDEX}}, (peg:p_choose([peg:p_string("abc"),peg:p_string("def")]))("xyz", ?STARTINDEX))
  ].

zero_or_more_test_() ->
  [
   ?_assertEqual({[], [], ?STARTINDEX}, (peg:p_zero_or_more(peg:p_string("abc")))("",?STARTINDEX)),
   ?_assertEqual({[], "def",?STARTINDEX}, (peg:p_zero_or_more(peg:p_string("abc")))("def",?STARTINDEX)),
   ?_assertEqual({["abc"], "def",{{line,1},{column,4}}}, (peg:p_zero_or_more(peg:p_string("abc")))("abcdef",?STARTINDEX)),
   ?_assertEqual({["abc", "abc"], "def",{{line,1},{column,7}}}, (peg:p_zero_or_more(peg:p_string("abc")))("abcabcdef",?STARTINDEX))
  ].

one_or_more_test_() ->
  [
   ?_assertEqual({fail,{expected, {at_least_one, {string, "abc"}}, ?STARTINDEX}}, (peg:p_one_or_more(peg:p_string("abc")))("def",?STARTINDEX)),
   ?_assertEqual({["abc"], "def",{{line,1},{column,4}}}, (peg:p_one_or_more(peg:p_string("abc")))("abcdef",?STARTINDEX)),
   ?_assertEqual({["abc","abc"], "def",{{line,1},{column,7}}}, (peg:p_one_or_more(peg:p_string("abc")))("abcabcdef",?STARTINDEX))
  ].

label_test_() ->
  [
   ?_assertEqual({fail,{expected, {string, "!"}, ?STARTINDEX}}, (peg:p_label(bang, peg:p_string("!")))("?",?STARTINDEX)),
   ?_assertEqual({{bang, "!"}, "",{{line,1},{column,2}}}, (peg:p_label(bang, peg:p_string("!")))("!",?STARTINDEX))
  ].

string_test_() ->
  [
   ?_assertEqual({"abc", "def",{{line,1},{column,4}}}, (peg:p_string("abc"))("abcdef",?STARTINDEX)),
   ?_assertEqual({fail,{expected, {string, "abc"}, ?STARTINDEX}}, (peg:p_string("abc"))("defabc",?STARTINDEX))
  ].

anything_test_() ->
  [
   ?_assertEqual({$a,"bcde",{{line,1},{column,2}}}, (peg:p_anything())("abcde",?STARTINDEX)),
   ?_assertEqual({fail,{expected, any_character, ?STARTINDEX}}, (peg:p_anything())("",?STARTINDEX))
  ].

charclass_test_() ->
  [
   ?_assertEqual({$+,"----",{{line,1},{column,2}}}, (peg:p_charclass("[+]"))("+----",?STARTINDEX)),
   ?_assertEqual({fail,{expected, {character_class, "[+]"}, ?STARTINDEX}}, (peg:p_charclass("[+]"))("----",?STARTINDEX))
  ].
