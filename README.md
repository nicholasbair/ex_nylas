# ExNylas

Unofficial Elixir bindings for the Nylas API.

## Notes

*Caveat Emptor*
- I am building this while learning the Nylas platform/API
- This is my first attempt at metaprogramming

## TODO
[ ] Events RSVPing - check req/res  
[ ] Availability  - check req/res  
[ ] Free busy - check req/res  
[ ] Deltas  
[ ] Files upload/download  
[ ] Contacts pictures  
[ ] Validate all models/structs vs the API  
[ ] Support build - convert raw requests (post/put) into request structs for validation  
[ ] Add Docs to readme  
[ ] Tests  
[ ] Push to Hex  

## Installation

Note - not available on Hex (yet).

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
2. Each function supports returning an ok/error tuple or raising an exception, for example
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}

# Returns {:ok, result} or {:error, reason}
{:ok, messages} = ExNylas.Messages.first(conn)

# Returns result or raises an exception
messages = ExNylas.Messages.first!(conn)
```
3. The results of each function call are transformed into a struct, with the exception of `Messages.get_raw/1`, which returns the raw content of a message, as well as any other functions that return raw data, like the files/download APIs (not yet supported).

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_nylas](https://hexdocs.pm/ex_nylas).

