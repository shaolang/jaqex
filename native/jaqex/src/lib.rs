use jaq_core::load::{Arena, File, Loader};
use jaq_core::{Compiler, Ctx, Filter, Native, RcIter};
use jaq_json::Val;
use rustler::{self, Encoder, SerdeTerm};
use serde_json::Value;

#[rustler::nif(schedule="DirtyCpu")]
fn _parse(json_doc: &str, code: &str, path: &str) -> impl Encoder {
    let filter = create_filter(code, path);
    let input: Value = serde_json::from_str(json_doc).unwrap();
    let inputs = RcIter::new(core::iter::empty::<Result<Val, String>>());
    let out = filter.run((Ctx::new([], &inputs), Val::from(input)));

    SerdeTerm(out.map(|v| Value::from(v.unwrap())).collect::<Vec<Value>>())
}

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

rustler::init!("Elixir.Jaqex");
