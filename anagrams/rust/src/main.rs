use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() <= 3 {
        println!("Usage: anagrams <dict_path> <phrase> [+include] [-exclude] [>min_len]");
        return;
    }

    let dict_path = &args[1];
    let phrase = &args[2];

    println!("Dict path: {}, phrase: {}", dict_path, phrase);

    let mut includes: Vec<String> = Vec::new();
    let mut excludes: Vec<String> = Vec::new();

    let mut min_len: Option<u32> = None;

    for arg in &args[3..] {
        if arg.starts_with("+") && arg.len() > 1 {
            includes.push(arg[1..].to_string());
        } else if arg.starts_with("-") && arg.len() > 1 {
            excludes.push(arg[1..].to_string());
        } else if arg.starts_with(">") && arg.len() > 1 {
            match arg[1..].parse() {
                Ok(n) => min_len = Some(n),
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

    if let Some(n) = min_len {
        println!("Min len: {}", n);
    }
}
