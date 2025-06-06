use jaq_core::load::{Arena, File as JaqFile, Loader};
use jaq_core::{Compiler, Ctx, Filter, Native, RcIter};
use jaq_json::Val;
use rustler::{self, Encoder, Error, SerdeTerm};
use serde_json::Value;
use std::fs::File;
use std::io::Read;
use std::path::PathBuf;

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_filter(json_doc: &str, code: &str, path: &str) -> Result<impl Encoder, Error> {
    filter(json_doc, code, path)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_filter_file(fname: &str, code: &str, path: &str) -> Result<impl Encoder, Error> {
    let mut f = File::open(fname).map_err(|_| Error::RaiseAtom("file_not_found"))?;
    let mut doc = String::new();
    f.read_to_string(&mut doc)
        .map_err(|_| Error::RaiseAtom("file_error"))?;

    filter(&doc, code, path)
}

fn filter(json_doc: &str, code: &str, path: &str) -> Result<impl Encoder, Error> {
    let filter = create_filter(code, path)?;
    let input: Value =
        serde_json::from_str(json_doc).map_err(|_| Error::RaiseAtom("invalid_json"))?;
    let inputs = RcIter::new(core::iter::empty::<Result<Val, String>>());
    let out = filter.run((Ctx::new([], &inputs), Val::from(input)));

    Ok(SerdeTerm(
        out.map(|v| Value::from(v.unwrap())).collect::<Vec<Value>>(),
    ))
}

fn create_filter(code: &str, path: &str) -> Result<Filter<Native<Val>>, Error> {
    let paths: &[PathBuf] = &[path.into()];
    let loader = Loader::new(jaq_std::defs().chain(jaq_json::defs())).with_std_read(paths);
    let arena = Arena::default();
    let path: PathBuf = path.into();
    let modules = loader
        .load(&arena, JaqFile { path, code })
        .map_err(|_| Error::RaiseAtom("invalid_filter"))?;
    let compiler = Compiler::default()
        .with_funs(jaq_std::funs().chain(jaq_json::funs()))
        .compile(modules)
        .unwrap();

    Ok(compiler)
}

rustler::init!("Elixir.Jaqex");
