# ExNylas

Unofficial Elixir bindings for the Nylas API.

## Notes

*Caveat Emptor*
- I am building this while learning the Nylas platform/API
- VERY much a work in progress
- This is my first attempt at metaprogramming

## TODO
[ ] Events RSVPing - check req/res  
[ ] Availability  - check req/res  
[ ] Free busy - check req/res  
[ ] Validate all models/structs vs the API  (responses done, need to check get by ID)  
[ ] Tests  
[ ] Push to Hex  

## Installation

*Note* - not available on Hex (yet).

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_nylas` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_nylas, "~> 0.1.0"}
  ]
end
```

## Usage
```elixir
%ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}
|> ExNylas.Messages.list(%{limit: 5})
```

1. Connection is a struct that stores your Nylas API credentials.
2. Each function supports returning an ok/error tuple or raising an exception, for example:
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}

# Returns {:ok, result} or {:error, reason}
{:ok, messages} = ExNylas.Messages.first(conn)

# Returns result or raises an exception
messages = ExNylas.Messages.first!(conn)
```
3. The results of each function call are transformed into a struct, with the exception of `Messages.get_raw/1`, which returns the raw content of a message, as well as any other functions that return raw data, like the `Files.download/2` and `Contacts.get_picture/2`.
4. Queries and filters are typically expected as a map:
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}
{:ok, threads} = ExNylas.Threads.list(%{limit: 5})

# Searching is the exception
{:ok, threads} = ExNylas.Threads.search("nylas")
```
5. Where `save/1`, `save!/1`, `save/2`, or `save!/2` is supported, optionally use `build/1` (or `build!/1`) to validate data before sending to the Nylas API.  This is strictly optional--`save` will accept either a map or a struct.  Build leverages [TypedStruct](https://hex.pm/packages/typed_struct) behind the scenes--so fields are validated against the struct definition, but while types are defined, they are not validated.  For example:
```elixir
{:ok, label} = ExNylas.Labels.build(%{display_name: "Hello World"})
# label is %ExNylas.Label.Build{display_name: "Hello World"}

# This will return {:error, message} because 'name' is not part of the struct
ExNylas.Labels.build(%{display_name: "Hello World", name: "My Label"})

# This will also return {:error, message} because 'display_name' is a required field
ExNylas.Labels.build(%{})
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_nylas](https://hexdocs.pm/ex_nylas).

