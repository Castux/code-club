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

pub fn load_word(word: &str) -> Word {
	let mut chars: Vec<char> = word.chars().collect();
	chars.sort();

	Word {
		chars,
		string: word.to_string(),
	}
}

pub fn word_diff(b: &Word, a: &Word) -> Option<Vec<char>> {
	let mut res: Vec<char> = Vec::new();

	let mut i: usize = 0;
	let mut j: usize = 0;

	while i < a.chars.len() && j < b.chars.len() {
		if a.chars[i] < b.chars[j] {
			return None;
		} else if a.chars[i] == b.chars[j] {
			i += 1;
			j += 1;
		} else {
			// a[i] > b[j]
			res.push(b.chars[j]);
			j += 1;
		}
	}

	if i < a.chars.len() {
		return None;
	}

	res.extend_from_slice(&b.chars[j..]);
	Some(res)
}

pub fn load_dict(words: &Vec<&str>) -> Vec<Word> {
	let mut res: Vec<Word> = words.iter().map(|w| load_word(w)).collect();

	res.sort_by(Word::cmp);
	res
}
