defmodule ExNylas do
  @moduledoc """
  ExNylas - Unofficial Elixir SDK for Nylas API.
  """

  import Ecto.Changeset

  alias ExNylas.API
  alias ExNylas.Connection, as: Conn
  alias ExNylas.Response
  alias ExNylas.Util

  @funcs [
    %{name: :all},
    %{name: :build},
    %{name: :create, http_method: :post},
    %{name: :delete, http_method: :delete},
    %{name: :find, http_method: :get},
    %{name: :first, http_method: :get},
    %{name: :list, http_method: :get},
    %{name: :update, http_method: :patch},
  ]

  defp generate_funcs(opts) do
    include = Keyword.get(opts, :include, [])

    @funcs
    |> Enum.filter(fn k -> k.name in include end)
    |> Enum.map(fn k ->
      generate_api(
        k,
        Keyword.get(opts, :object),
        Keyword.get(opts, :struct),
        Keyword.get(opts, :readable_name, Keyword.get(opts, :struct)),
        Keyword.get(opts, :header_type, :header_bearer),
        Keyword.get(opts, :use_admin_url, false),
        Keyword.get(opts, :use_cursor_paging, true)
      )
    end)
  end

  defp generate_api(%{name: :all} = config, _object, _struct_name, readable_name, _header_type, _use_admin_url, use_cursor_paging) do
    quote do
      @doc """
      Fetch all #{unquote(readable_name)}(s) matching the provided query (the SDK will handle paging).

      The second argument can be a keyword list of options + query parameters to pass to the Nylas API (map is also supported).  Options supports:
      - `:send_to` - a single arity function to send each page of results (default is nil, e.g. results will be accumulated and returned as a list)
      - `:delay` - the number of milliseconds to wait between each page request (default is 0; strongly recommended to avoid rate limiting)
      - `:query` - a keyword list or map of query parameters to pass to the Nylas API (default is an empty list)

      ## Examples
          iex> opts = [send_to: &IO.inspect/1, delay: 3_000, query: [key: "value"]]
          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.all(conn, opts)
      """
      @spec unquote(config.name)(Conn.t(), Keyword.t() | map()) :: {:ok, [struct()]} | {:error, Response.t()}
      def unquote(config.name)(%Conn{} = conn, opts \\ []) do
        ExNylas.Paging.all(conn, __MODULE__, unquote(use_cursor_paging), opts)
      end

      @doc """
      Fetch all #{unquote(readable_name)}(s) matching the provided query (the SDK will handle paging).

      The second argument can be a keyword list of options + query parameters to pass to the Nylas API (map is also supported).  Options supports:
      - `:send_to` - a single arity function to send each page of results (default is nil, e.g. results will be accumulated and returned as a list)
      - `:delay` - the number of milliseconds to wait between each page request (default is 0; strongly recommended to avoid rate limiting)
      - `:query` - a keyword list or map of query parameters to pass to the Nylas API (default is an empty list)

      ## Examples
          iex> opts = [send_to: &IO.inspect/1, delay: 3_000, query: [key: "value"]]
          iex> result = #{ExNylas.format_module_name(__MODULE__)}.all!(conn, opts)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(Conn.t(), Keyword.t() | map()) :: [struct()]
      def unquote(String.to_atom("#{config.name}!"))(%Conn{} = conn, opts \\ []) do
        case unquote(config.name)(conn, opts) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{name: :build} = config, _object, struct_name, readable_name, _header_type, _use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Create and validate a #{unquote(readable_name)}, use create/update to send to Nylas.

      ## Examples

          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.build(payload)
      """
      @spec unquote(config.name)(map() | struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
      def unquote(config.name)(payload) do
        payload = ExNylas.from_struct(payload)

        unquote(struct_name)
        |> to_string()
        |> Kernel.<>(".Build")
        |> String.to_atom()
        |> then(fn model -> model.changeset(model.__struct__(), payload) end)
        |> apply_action(:build)
      end

      @doc """
      Create and validate a #{unquote(readable_name)}, use create/update to send to Nylas.

      ## Examples

          iex> result = #{ExNylas.format_module_name(__MODULE__)}.build!(payload)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(map() | struct()) :: struct()
      def unquote(String.to_atom("#{config.name}!"))(payload) do
        payload = ExNylas.from_struct(payload)

        unquote(struct_name)
        |> to_string()
        |> Kernel.<>(".Build")
        |> String.to_atom()
        |> then(fn model -> model.changeset(model.__struct__(), payload) end)
        |> apply_action!(:build)
      end
    end
  end

  defp generate_api(%{name: :first} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Get the first #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.first(conn, params)
      """
      @spec unquote(config.name)(Conn.t(), Keyword.t() | map()) :: {:ok, Response.t()} | {:error, Response.t()}
      def unquote(config.name)(%Conn{} = conn, params \\ []) do
        res =
          Req.new(
            method: :get,
            url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)),
            auth: ExNylas.generate_auth(conn, unquote(header_type)),
            headers: API.base_headers(),
            params: Util.indifferent_put_new(params, :limit, 1)
          )
          |> API.maybe_attach_telemetry(conn)
          |> Req.request(conn.options)
          |> API.handle_response(unquote(struct_name))

        case res do
          {:ok, val} -> {:ok, %{val | data: Enum.at(val.data, 0)}}
          val -> val
        end
      end

      @doc """
      Get the first #{unquote(readable_name)}.

      ## Examples

          iex> result = #{ExNylas.format_module_name(__MODULE__)}.first!(conn, params)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(Conn.t(), Keyword.t() | map()) :: Response.t()
      def unquote(String.to_atom("#{config.name}!"))(%Conn{} = conn, params \\ []) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: method, name: name} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) when name in [:find, :delete] do
    quote do
      @doc """
      #{ExNylas.format_config_name(unquote(config.name))} a(n) #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}(conn, id, params)
      """
      @spec unquote(config.name)(Conn.t(), String.t(), Keyword.t() | map()) :: {:ok, Response.t()} | {:error, Response.t()}
      def unquote(config.name)(%Conn{} = conn, id, params \\ []) do
        Req.new(
          method: unquote(method),
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)) <> "/#{id}",
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(),
          params: params
        )
        |> API.maybe_attach_telemetry(conn)
        |> Req.request(conn.options)
        |> API.handle_response(unquote(struct_name))
      end

      @doc """
      #{ExNylas.format_config_name(unquote(config.name))} a(n) #{unquote(readable_name)}.

      ## Examples

          iex> result = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}!(conn, id, params)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(Conn.t(), String.t(), Keyword.t() | map()) :: Response.t()
      def unquote(String.to_atom("#{config.name}!"))(%Conn{} = conn, id, params \\ []) do
        case unquote(config.name)(conn, id, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{name: :list} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Fetch #{unquote(readable_name)}(s), optionally provide query params.

      ## Examples

          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}(conn, params)
      """
      @spec unquote(config.name)(Conn.t(), Keyword.t() | map()) :: {:ok, Response.t()} | {:error, Response.t()}
      def unquote(config.name)(%Conn{} = conn, params \\ []) do
        Req.new(
          method: :get,
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)),
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(),
          params: params
        )
        |> API.maybe_attach_telemetry(conn)
        |> Req.request(conn.options)
        |> API.handle_response(unquote(struct_name))
      end

      @doc """
      Fetch #{unquote(readable_name)}(s), optionally provide query params.

      ## Examples

          iex> result = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}!(conn, params)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(Conn.t(), Keyword.t() | map()) :: Response.t()
      def unquote(String.to_atom("#{config.name}!"))(%Conn{} = conn, params \\ []) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{name: :update} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Update a(n) #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}(conn, id, body, params)
      """
      @spec unquote(config.name)(Conn.t(), String.t(), map(), Keyword.t() | map()) :: {:ok, Response.t()} | {:error, Response.t()}
      def unquote(config.name)(%Conn{} = conn, id, changeset, params \\ []) do
        Req.new(
          method: :patch,
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)) <> "/#{id}",
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(["content-type": "application/json"]),
          json: changeset,
          params: params
        )
        |> API.maybe_attach_telemetry(conn)
        |> Req.request(conn.options)
        |> API.handle_response(unquote(struct_name))
      end

      @doc """
      Update a(n) #{unquote(readable_name)}.

      ## Examples

          iex> result = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}!(conn, id, body, params)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(Conn.t(), String.t(), map(), Keyword.t() | map()) :: Response.t()
      def unquote(String.to_atom("#{config.name}!"))(%Conn{} = conn, id, changeset, params \\ []) do
        case unquote(config.name)(conn, id, changeset, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{name: :create} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Create a(n) #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}(conn, body, params)
      """
      @spec unquote(config.name)(Conn.t(), map(), Keyword.t() | map()) :: {:ok, Response.t()} | {:error, Response.t()}
      def unquote(config.name)(%Conn{} = conn, body, params \\ []) do
        Req.new(
          method: :post,
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)),
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(["content-type": "application/json"]),
          json: body,
          params: params
        )
        |> API.maybe_attach_telemetry(conn)
        |> Req.request(conn.options)
        |> API.handle_response(unquote(struct_name))
      end

      @doc """
      Create a(n) #{unquote(readable_name)}.

      ## Examples

          iex> result = #{ExNylas.format_module_name(__MODULE__)}.#{unquote(config.name)}(conn, body, params)
      """
      @spec unquote(String.to_atom("#{config.name}!"))(Conn.t(), map(), Keyword.t() | map()) :: Response.t()
      def unquote(String.to_atom("#{config.name}!"))(%Conn{} = conn, body, params \\ []) do
        case unquote(config.name)(conn, body, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  @doc false
  def generate_url(conn, true = _use_admin_url, object), do: "#{conn.api_server}/v3/#{object}"
  def generate_url(conn, false = _use_admin_url, object), do: "#{conn.api_server}/v3/grants/#{conn.grant_id}/#{object}"

  @doc false
  def generate_auth(conn, :header_bearer), do: API.auth_bearer(conn)

  @doc false
  def format_module_name(module_name) do
    module_name
    |> Atom.to_string()
    |> String.replace("Elixir.", "")
    |> String.to_atom()
  end

  @doc false
  def format_config_name(name) do
    name
    |> to_string()
    |> String.capitalize()
  end

  @doc false
  def from_struct(payload) when is_struct(payload) do
    payload
    |> Miss.Map.from_nested_struct()
  end

  def from_struct(payload), do: payload

  defmacro __using__(opts) do
    quote do
      unquote(generate_funcs(opts))
    end
  end
end
