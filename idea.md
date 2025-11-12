# Generalization

I would like to generalize the code from `diagram.lua`.
Instead of focusing on supporting a few selected diagram engines,
I want to support executing _any_ command within a pandoc filter.
The core structure remains the same:

- The first class defines the _command_ (like `d2` or `duckdb`)
- The other classes the positional arguments and the attributes the key-value pairs
- The contents of the code block is written to a temporary file
- The output should be deterministic so that it can be _cached_
  - The command is executed _twice_ to quickly test if the output is reproducible
  - But allow disabling caching for commands like `cat` that may print "dynamic" content.
- For images, the `mime_type` is required to store in the `mediabag`.
  Here, I would simply provide a common list of _known_ command-mime-type pairs.

Only "defined" commands are supported.
And the definition _specifies_ how the command is structured.
For example, `duckdb` could be defined as:

name: `duckdb`
command: `duckdb` # defaults to `name`
args: `{ARGS} {KWARGS} -f {INPUT_FILE}`
comment: `--`
generates_file: False # means that the data from STDOUT should be read!
output: markdown # "image/text/code/markdown" or `pandoc` type?
mime_type: nil # required for "image" output
cache: true
header: nil # to always prefix the input text with something
footer:  nil # to always suffix the input text with something

name: `d2`
command: `d2`
args: `--bundle --pad=0 {ARGS} {KWARGS} -- {INPUT_FILE} {OUTPUT_FILE}`
comment: `#`
generates_file: True
output: image
mime_type: svg
cache: true

1. Implement reading the global config metadata file in the Lua filter
1. Implement the argument pattern builder from `args` with correctness checker for "image"
1. Implement the execution engine (relying on pipe)
1. Write the comment parser and pandoc option generator logic
1. Write the caching layer
1. Support parallel execution by simply adding the commands to an execution queue.

