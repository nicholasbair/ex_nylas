# ExNylas

Unofficial Elixir bindings for the Nylas API.

## Notes

*Caveat Emptor*
- VERY much a work in progress
- This is my first attempt at metaprogramming

## Nylas API v2 vs v3
The `main` branch of the repo now leverages Nylas API v3 (currently in beta).  The `v2` branch of this repo will track Nylas API v2, though dev work on this SDK will largely focus on Nylas API v3.

## TODO / Known Issues
- [ ] Tests 
- [ ] Push to Hex 

## Installation
```elixir
def deps do
  [
    {:ex_nylas, git: "https://github.com/nicholasbair/ex_nylas.git", tag: "v0.2.2"}
  ]
end
```

## Usage
1. Connection is a struct that stores your Nylas API credentials.
```elixir
conn = 
  %ExNylas.Connection{
    client_id: "1234",
    client_secret: "1234",
    api_key: "1234",
    grant_id: "1234",
    api_server: "https://api.us.nylas.com",
    timeout: 3_000,
    revc_timeout: 5_000
  }
```

2. Each function supports returning an ok/error tuple or raising an exception, for example:
```elixir
conn = %ExNylas.Connection{api_key: "1234", grant_id: "1234"}

# Returns {:ok, result} or {:error, reason}
{:ok, message} = ExNylas.Messages.first(conn)

# Returns result or raises an exception
message = ExNylas.Messages.first!(conn)
```

3. Queries and filters are generally expected as a map:
```elixir
{:ok, threads} = 
  %ExNylas.Connection{api_key: "1234", grant_id: "1234"}
  |> ExNylas.Threads.list(%{limit: 5})
```

4. Where `create/update` is supported, optionally use `build/1` (or `build!/1`) to validate data before sending to the Nylas API.  This is strictly optional--`create/update` will accept either a map or a struct.  Build leverages [TypedStruct](https://hex.pm/packages/typed_struct) behind the scenes so fields are validated against the struct definition, but while types are defined, they are not validated.  For example:
```elixir
{:ok, folder} = ExNylas.Folders.build(%{name: "Hello World"})

# This will return {:error, %KeyError{}} because 'display_name' is not part of the struct
ExNylas.Folder.build(%{display_name: "Hello Error"})

# This will return {:error, %ArgumentError{}} because 'name' is a required field
ExNylas.Folder.build(%{})
```

5. Use `all/2` to fetch all of a given object and let the SDK page for you:
```elixir
conn = %ExNylas.Connection{api_key: "1234", grant_id: "1234"}
{:ok, all_messages} = ExNylas.Messages.all(conn, %{to: "hello@example.com"})

# Or handle paging on your own
{:ok, first_page} = ExNylas.Messages.list(conn, %{limit: 50})
```

