# Anagram finder

> Let's have a simpler challenge for next week: let's write an anagram finder! That is, from a large list of words in for instance the English language, and a starting phrase, find all sequences of words that contain exactly the same letters in a different order.
>
> For instance, given the phrase "Code club is great", the program will return, among other things, "Stoic cured bagel" or "Bored acetic slug".
>
> Feel free to explore, for instance: optimizations, different languages or platforms, user interfaces, etc.

## Algorithm

Words are represented as sorted arrays of their characters' codepoints. This allows checking if `a` is a subword of `b` in one pass. The function actually returns the difference `b-a` when it exists (all the letters of `b`, minus those of `a`).

When loading the list of dictionary words, we sort it first according to decreasing length, and then lexicographically for equal lengths.

Then at each step, filter the dictionary down to subwords of the current phrase. For each subword, recurse on the difference `phrase - subword`, saving the subword on a stack.

When the phrase has 0 characters, the current stack of subwords is a solution.

## Improvement

A simple but efficient improvement is to pass down the *filtered* dictionary to the recursive call, since subwords of the difference `phrase - subword` are necessarily subwords of `phrase`, which we computed already.

This generates garbage in memory, but makes the algorithm much faster. These arrays of subwords could even be pre-allocated for even better performance.

Furthermore, to avoid duplicate entries with the whole words rearranged, when filtering down the dictionary, we ignore all words before the last word added to the solution. That way we always naturally find solutions where words are "in order" (decreasing size, then alphabetical), and ignore the others, which also makes the search faster.

## Shortcomings

Except for ASCII characters (which are fine for the English language), converting to lower/uppercase is not trivial. Since the program handles UTF-8 dictionary and input, and breaks it down properly into Unicode codepoints, we would have to implement the whole Unicode [Case Mapping](https://www.unicode.org/charts/case/) information in order to properly handle case.

Therefore, I didn't :D Input should be in lowercase, as are the dictionary files.

Similarly, some languages consider letters with diacritics variants of the base letter (like French), while others consider them different letters. Anagrams probably should reflect that.

This solver has the option to ignore diacritics, although I have half-assedly  hardcoded a only handful of them, covering mostly French and possibly a few other latin languages.

## Command line tool

Requires Lua 5.3 or later.

`Usage: lua main.lua <dict_path> <phrase> [+include] [-exclude] [>min_len] [--ignore_diacritics]`

## Web interface

Using the [Fengari](https://fengari.io/) implementation of Lua in native Javascript, we can run Lua in the browser transparently, with trivial interop between the two languages.

See the [web tool live](https://castux.github.io/code-club/anagrams/).

All the DOM manipulation and event management is even written in Lua (see `anagrams-web.lua`).

Note that since in-browser Javascript is single-threaded, we need to split the work in small units, or the page would become unresponsive until the solving call would return.

This is a perfect job for Lua's coroutines. The solver yields regularly: either a dummy value (every ~5000 subwords generated, regardless of recursion level), or a result when it finds one.

Performance is way worse than running natively, but the interactive nature of the tool makes it ok: we rarely want to generate all the anagrams and then go through the entire huge list, but rather go with trial and error of included words.
