# ExNylas

Unofficial Elixir SDK for the Nylas API.

To get started, first sign up for a free Nylas account [here](https://nylas.com), then follow the installation and usage guide below.

## Notes

*Caveat Emptor*
- VERY much a work in progress
- This is my first attempt at metaprogramming

## Nylas API v2 vs v3
The `main` branch of the repo now leverages Nylas API v3.  The `v2` branch of this repo will track Nylas API v2, though development work on this SDK will largely focus on Nylas API v3.

## TODO / Known Issues
1. Limited test coverage
2. Not yet available on hex

## Installation
```elixir
def deps do
  [
    {:ex_nylas, git: "https://github.com/nicholasbair/ex_nylas.git", tag: "v0.7.3"}
  ]
end
```

## Usage
1. Connection is a struct that stores your Nylas API credentials.
```elixir
conn = 
  %ExNylas.Connection{
    client_id: "1234",
    api_key: "1234",
    grant_id: "1234",
    access_token: "1234", # Omited if using `grant_id` + `api_key`
    api_server: "https://api.us.nylas.com",
    options: [], # Passed to Req (HTTP client)
    telemetry: true # Enables telemetry and the default telemetry logger (defaults to `false`)
  }
```

Options from `ExNylas.Connection` are passed directly to [Req](https://hexdocs.pm/req/Req.html) and can be used to override the default behavior of the HTTP client.  You can find a complete list of options [here](https://hexdocs.pm/req/Req.html#new/1).  The most relevent Req defaults are listed below:
```elixir
[
  retry: :safe_transient,
  cache: false,
  compress_body: false,
  compressed: true, # ask server to return compressed responses
  receive_timeout: 15_000, # socket receive timeout
  pool_timeout: 5000 # pool checkout timeout
]
```

When using options, _do not_ override the value for `decode_body`, in most cases, the SDK is relying on Req to decode the response via Jason.

2. Each function supports returning an ok/error tuple or raising an exception, for example:
```elixir
conn = %ExNylas.Connection{api_key: "1234", grant_id: "1234"}

# Returns {:ok, result} or {:error, reason}
{:ok, message} = ExNylas.Messages.first(conn)

# Returns result or raises an exception
message = ExNylas.Messages.first!(conn)
```

3. Where supported, queries and filters can be passed as a map or keyword list:
```elixir
{:ok, threads} = 
  %ExNylas.Connection{api_key: "1234", grant_id: "1234"}
  |> ExNylas.Threads.list(limit: 5)
```

4. Where `create/update` is supported, optionally use `build/1` (or `build!/1`) to validate data before sending to the Nylas API.  This is strictly optional--`create/update` will accept either a map or a struct.  Build leverages [Ecto](https://hex.pm/packages/ecto) behind the scenes so fields are validated against the schema/struct definition and in the case of an error, the Ecto changeset is returned.  For example:
```elixir
{:ok, folder} = ExNylas.Folders.build(%{name: "Hello World"})

# This will return an error because 'display_name' is not part of the struct
ExNylas.Folders.build(%{display_name: "Hello Error"})

> {:error,
 #Ecto.Changeset<
   action: :build,
   changes: %{},
   errors: [name: {"can't be blank", [validation: :required]}],
   data: #ExNylas.Folder.Build<>,
   valid?: false
 >}
```

5. [Ecto](https://hex.pm/packages/ecto) is also used when transforming the API response from Nylas into structs.  Any validation errors are logged, but errors are not returned/raised in order to make to SDK resilient to changes to the API contract.

6. Use `all/2` to fetch all of a given object and let the SDK page for you.  Req will handle retries on errors by default, if retries fail, partial results are not returned (unless `send_to` is used).

Note - depending on the result set, this operation could take time, consider using a query/filter to reduce the number of results and/or making this an async operation.

Optionally include:
- `delay` to throttle requests and avoid 429s (note: strongly recommended; this delay is independent of retry delays configured in the HTTP client)
- `send_to` to pass each page to your single arity function instead of accumulating all of the result set in memory
- `with_metadata` any data that should be included when invoking the function provided in `send_to`, results are sent as a tuple `{metadata, page}`

```elixir
conn = %ExNylas.Connection{api_key: "1234", grant_id: "1234"}

# Accumulate results in memory and return them when paging is complete
{:ok, []} = ExNylas.Messages.all(conn, query: [any_email: "nick@example.com", fields: "include_headers"])

# Send results to a handler as each page is received
{:ok, []} = ExNylas.Messages.all(conn, send_to: &IO.inspect/1, delay: 3_000, query: [any_email: "nick@example.com", fields: "include_headers"])

# Or handle paging on your own
{:ok, first_page} = ExNylas.Messages.list(conn, limit: 50)
{:ok, second_page} = ExNylas.Messages.list(conn, limit: 50, page_token: first_page.next_cursor)
```

