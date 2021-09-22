use combine::{stream::position, EasyParser, StreamOnce};

use hdk::prelude::*;

use rep_lang_concrete_syntax::parse::expr;
use rep_lang_core::abstract_syntax::Program;

use rep_lang_runtime::{eval::FlatValue, types::Type};

#[hdk_extern]
fn entry_defs(_: ()) -> ExternResult<EntryDefsCallbackResult> {
    Ok(EntryDefsCallbackResult::from(vec![Path::entry_def()]))
}

#[derive(Debug, Serialize, Deserialize)]
struct Params {
    params_string: String,
}

#[hdk_extern]
fn test_output(params: Params) -> ExternResult<bool> {
    let Params {
        params_string: p_str,
    } = params;
    debug!("received input: {}", p_str);

    match expr().easy_parse(position::Stream::new(&p_str[..])) {
        Err(err) => {
            debug!("parse error:\n\n{}\n", err);
            Ok(false)
        }
        Ok((expr, extra_input)) => {
            if extra_input.is_partial() {
                debug!("error: unconsumed input: {:?}", extra_input);
                Ok(false)
            } else {
                debug!("ast: {:?}\n", expr);
                Ok(true)
            }
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
pub enum InterchangeOperand {
    RepLangEntry(EntryHash),
    OtherEntry(EntryHash),
}

#[hdk_entry(id = "interchange_entry")]
pub struct InterchangeEntry {
    pub operator: Program,
    pub operands: Vec<InterchangeOperand>,
    pub output_type: Type,
    pub output: FlatValue,
}
