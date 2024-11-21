use jaq_core::{Compiler, Filter, Native};
use jaq_core::load::{Arena, File, Loader};
use jaq_json::Val;

fn create_filter(code: &str, path: &str) -> Filter<Native<Val>> {
    let loader = Loader::new(jaq_std::defs().chain(jaq_json::defs()));
    let arena = Arena::default();
    let path = path.into();
    let modules = loader.load(&arena, File { path, code }).unwrap();

    Compiler::default()
        .with_funs(jaq_std::funs().chain(jaq_json::funs()))
        .compile(modules)
        .unwrap()
}

#[rustler::nif]
fn add(a: i64, b: i64) -> i64 {
    a + b
}

rustler::init!("Elixir.Jaqex");
