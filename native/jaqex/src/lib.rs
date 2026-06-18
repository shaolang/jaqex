use jaq_core::data::JustLut;
use jaq_core::load::{Arena, File, Loader};
use jaq_core::{Compiler, Ctx, Filter, Vars, data, unwrap_valr};
use jaq_json::{Val, read::parse_single};
use rustler::{self, Encoder, Error, SerdeTerm};
use serde_json::Value;
use std::fs;
use std::io::Read;

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_filter(json_doc: &str, code: &str, path: &str) -> Result<impl Encoder, Error> {
    filter(json_doc, code, path)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_filter_file(fname: &str, code: &str, path: &str) -> Result<impl Encoder, Error> {
    let mut f = fs::File::open(fname).map_err(|_| Error::RaiseAtom("file_not_found"))?;
    let mut doc = String::new();
    f.read_to_string(&mut doc)
        .map_err(|_| Error::RaiseAtom("file_error"))?;

    filter(doc, code, path)
}

fn filter(json_doc: impl AsRef<[u8]>, code: &str, path: &str) -> Result<impl Encoder, Error> {
    let filter = create_filter(code, path)?;
    let ctx = Ctx::<data::JustLut<Val>>::new(&filter.lut, Vars::new([]));
    let out = filter
        .id
        .run((ctx, parse_single(json_doc.as_ref()).unwrap()))
        .map(unwrap_valr);

    Ok(SerdeTerm(
        out.map(|v| serde_json::from_str(&v.unwrap().to_string()).unwrap())
            .collect::<Vec<Value>>(),
    ))
}

fn create_filter(code: &str, path: &str) -> Result<Filter<JustLut<Val>>, Error> {
    let defs = jaq_core::defs()
        .chain(jaq_std::defs())
        .chain(jaq_json::defs());
    let funs = jaq_core::funs()
        .chain(jaq_std::funs())
        .chain(jaq_json::funs());
    let loader = Loader::new(defs);
    let arena = Arena::default();

    let program = File { path, code };
    let modules = loader
        .load(&arena, program)
        .map_err(|_| Error::RaiseAtom("invalid_json"))?;

    Compiler::default()
        .with_funs(funs)
        .compile(modules)
        .map_err(|_| Error::RaiseAtom("compilation_error"))
}

rustler::init!("Elixir.Jaqex");
