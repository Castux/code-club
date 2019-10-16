use std::cmp::Ordering;

pub struct Word {
	chars: Vec<char>,
	string: String,
}

impl Word {
	fn len(&self) -> usize {
		self.chars.len()
	}

	fn cmp(&self, other: &Self) -> Ordering {
		match self.len().cmp(&other.len()) {
			Ordering::Greater => Ordering::Less,
			Ordering::Less => Ordering::Greater,
			Ordering::Equal => self.string.cmp(&other.string),
		}
	}
}

fn load_word(word: &str) -> Word {
	let lowercase = word.to_lowercase().to_string();
	let mut chars: Vec<char> = lowercase.chars().filter(|c| c.is_alphabetic()).collect();
	chars.sort();
	Word {
		chars,
		string: lowercase,
	}
}

fn word_diff(b: &Vec<char>, a: &Vec<char>) -> Option<Vec<char>> {
	let mut res: Vec<char> = Vec::new();

	let mut i: usize = 0;
	let mut j: usize = 0;

	while i < a.len() && j < b.len() {
		if a[i] < b[j] {
			return None;
		} else if a[i] == b[j] {
			i += 1;
			j += 1;
		} else {
			// a[i] > b[j]
			res.push(b[j]);
			j += 1;
		}
	}

	if i < a.len() {
		return None;
	}

	res.extend_from_slice(&b[j..]);
	Some(res)
}

pub fn load_dict(words: &Vec<&str>) -> Vec<Word> {
	let mut res: Vec<Word> = words.iter().map(|w| load_word(w)).collect();

	res.sort_by(Word::cmp);
	res
}

fn filter_dict<'a>(
	dict: &Vec<&'a Word>,
	chars: &Vec<char>,
	start_at: Option<&Word>,
	min_len: u32,
) -> (Vec<&'a Word>, Vec<Vec<char>>) {
	let mut subs: Vec<&'a Word> = Vec::new();
	let mut diffs: Vec<Vec<char>> = Vec::new();

	for word in dict {
		if word.len() < min_len as usize
			|| (match start_at {
				Some(w) => word.cmp(w) == Ordering::Less,
				None => false,
			}) {
			continue;
		}

		match word_diff(chars, &word.chars) {
			Some(diff) => {
				subs.push(word);
				diffs.push(diff);
			}
			None => (), //println!("{} not a sub of {:?}", word.string, chars),
		}
	}

	(subs, diffs)
}

fn find_anagrams_rec<'a>(
	dict: &Vec<&'a Word>,
	phrase: &Vec<char>,
	current: &mut Vec<&'a Word>,
	excludes: &Vec<&str>,
	min_len: u32,
) {
	if phrase.len() == 0 {
		for w in current {
			print!("{} ", w.string);
		}
		print!("\n");

		return;
	}

	let start_at = if current.is_empty() {
		None
	} else {
		Some(current[0])
	};

	let (subs, diffs) = filter_dict(dict, phrase, start_at, min_len);
	for i in 0..subs.len() {
		let sub = subs[i];
		let diff = &diffs[i];
		if excludes.contains(&sub.string.as_str()) {
			continue;
		}

		current.push(&sub);
		find_anagrams_rec(&subs, diff, current, excludes, min_len);
		current.pop();
	}
}

pub fn find_anagrams(dict: &Vec<Word>, phrase: &String, excludes: &Vec<String>, min_len: u32) {
	find_anagrams_rec(
		&dict.iter().collect(),
		&load_word(phrase).chars,
		&mut Vec::new(),
		&excludes.iter().map(|s| s.as_str()).collect(),
		min_len,
	)
}
