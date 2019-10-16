use std::env;
use std::fs;

mod anagrams;

fn main() {
	let args: Vec<String> = env::args().collect();

	if args.len() < 2 {
		println!("Usage: anagrams <dict_path> <phrase> [+include] [-exclude] [>min_len]");
		return;
	}

	// Arguments parsing

	let dict_path = &args[1];
	let phrase = &args[2];

	println!("Dict path: {}, phrase: {}", dict_path, phrase);

	let mut includes: Vec<String> = Vec::new();
	let mut excludes: Vec<String> = Vec::new();

	let mut min_len: u32 = 1;

	for arg in &args[3..] {
		if arg.starts_with("+") && arg.len() > 1 {
			includes.push(arg[1..].to_string());
		} else if arg.starts_with("-") && arg.len() > 1 {
			excludes.push(arg[1..].to_string());
		} else if arg.starts_with(">") && arg.len() > 1 {
			match arg[1..].parse() {
				Ok(n) => min_len = n,
				Err(_) => {
					println!("Invalid argument: {}", arg);
					return;
				}
			}
		} else {
			println!("Invalid argument: {}", arg);
			return;
		}
	}

	println!("Includes: {}", includes.join(", "));
	println!("Excludes: {}", excludes.join(", "));
	println!("Min len: {}", min_len);

	// Loading dictionary

	let dict_str = match fs::read_to_string(dict_path) {
		Err(_) => {
			println!("Couldn't read file: {}", dict_path);
			return;
		}
		Ok(str) => str,
	};

	let words: Vec<&str> = dict_str.split_whitespace().collect();
	let dictionary = anagrams::load_dict(&words);

	println!("Loaded {} words", dictionary.len());

	anagrams::find_anagrams(&dictionary, phrase, &excludes, min_len);
}
