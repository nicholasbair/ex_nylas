# ExNylas

Unofficial Elixir bindings for the Nylas API.

## Notes

*Caveat Emptor*
- VERY much a work in progress
- This is my first attempt at metaprogramming

## TODO / Known Issues
- [ ] Tests 
- [ ] Push to Hex 
- [ ] Integrations (for conferencing auto-creation) 

## Installation
```elixir
def deps do
  [
    {:ex_nylas, git: "https://github.com/nicholasbair/ex_nylas.git", tag: "0.1.0"}
  ]
end
```

## Usage
1. Connection is a struct that stores your Nylas API credentials.
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}

# Or
conn = ExNylas.Connection.new("1234", "1234", "1234")
```

2. Each function supports returning an ok/error tuple or raising an exception, for example:
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}

# Returns {:ok, result} or {:error, reason}
{:ok, message} = ExNylas.Messages.first(conn)

# Returns result or raises an exception
message = ExNylas.Messages.first!(conn)
```

3. The results of each function call are transformed into a struct, with the exception of `Messages.get_raw/1`, which returns the raw content of a message, as well as any other functions that return raw data, like the `Files.download/2` and `Contacts.get_picture/2`.

4. Queries and filters are typically expected as a map:
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}
{:ok, threads} = ExNylas.Threads.list(conn, %{limit: 5})

# Searching is the exception
{:ok, threads} = ExNylas.Threads.search(conn, "nylas")
```

5. Where `create/update` is supported, optionally use `build/1` (or `build!/1`) to validate data before sending to the Nylas API.  This is strictly optional--`save` will accept either a map or a struct.  Build leverages [TypedStruct](https://hex.pm/packages/typed_struct) behind the scenes so fields are validated against the struct definition, but while types are defined, they are not validated.  For example:
```elixir
{:ok, label} = ExNylas.Labels.build(%{display_name: "Hello World"})
# label == %ExNylas.Label.Build{display_name: "Hello World"}

# This will return {:error, message} because 'name' is not part of the struct
ExNylas.Labels.build(%{display_name: "Hello World", name: "My Label"})

# This will also return {:error, message} because 'display_name' is a required field
ExNylas.Labels.build(%{})
```

6. Use `all/2` to fetch all of a given object and let the SDK page for you:
```elixir
conn = %ExNylas.Connection{client_id: "1234", client_secret: "1234", access_token: "1234"}
{:ok, all_messages} = ExNylas.Messages.all(conn, %{to: "hello@example.com"})

# Or handle paging on your own
{:ok, first_page} = ExNylas.Messages.list(conn, %{limit: 50})
```

