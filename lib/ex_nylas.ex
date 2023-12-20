defmodule ExNylas do
  @moduledoc """
  Generate functions that follow the 'standard' path.
  """

  alias ExNylas.Connection, as: Conn
  alias ExNylas.API, as: API

  @funcs %{
    list: %{name: :list, http_method: :get},
    first: %{name: :first, http_method: :get},
    search: %{name: :search, http_method: :get},
    find: %{name: :find, http_method: :get},
    delete: %{name: :delete, http_method: :delete},
    send: %{name: :send, http_method: :post},
    build: %{name: :build},
    all: %{name: :all},
    update: %{name: :update, http_method: :patch},
    create: %{name: :create, http_method: :post}
  }

  defp generate_funcs(opts) do
    include = Keyword.get(opts, :include, [])
    object = Keyword.get(opts, :object)
    struct_name = Keyword.get(opts, :struct)
    header_type = Keyword.get(opts, :header_type, :header_bearer)
    use_admin_url = Keyword.get(opts, :use_admin_url, false)
    readable_name = Keyword.get(opts, :readable_name, struct_name)
    use_cursor_paging = Keyword.get(opts, :use_cursor_paging, true)

    @funcs
    |> Map.keys()
    |> Enum.filter(fn k -> k in include end)
    |> Enum.map(fn k ->
      Map.get(@funcs, k)
      |> generate_api(object, struct_name, readable_name, header_type, use_admin_url, use_cursor_paging)
    end)
  end

  defp generate_api(%{name: :all} = config, _object, _struct_name, readable_name, _header_type, _use_admin_url, use_cursor_paging) do
    quote do
      @doc """
      Fetch all #{unquote(readable_name)}(s) matching the provided query (function will handle paging).

      ## Examples

          iex> {:ok, result} = #{__MODULE__}.all(conn, params)
      """
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        apply(ExNylas.Paging, :all, [conn, __MODULE__, unquote(use_cursor_paging), params])
      end

      @doc """
      Fetch all #{unquote(readable_name)}(s) matching the provided query (function will handle paging).

      ## Examples

          iex> result = #{__MODULE__}.all!(conn, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
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

          iex> {:ok, result} = #{__MODULE__}.build(payload)
      """
      def unquote(config.name)(payload) do
        try do
          res = apply(__MODULE__, "#{unquote(config.name)}!" |> String.to_atom(), [payload])
          {:ok, res}
        rescue
          e in _ -> {:error, e}
        end
      end

      @doc """
      Create and validate a #{unquote(readable_name)}, use the create/update to send to Nylas.

      ## Examples

          iex> result = #{__MODULE__}.build(payload)!
      """
      def unquote("#{config.name}!" |> String.to_atom())(payload) do
        unquote(struct_name)
        |> to_string()
        |> Kernel.<>(".Build")
        |> String.to_atom()
        |> struct!(payload)
      end
    end
  end

  defp generate_api(%{http_method: :get, name: :first} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Get the first #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{__MODULE__}.first(conn, params)
      """
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        res =
          Req.new(
            method: :get,
            url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)),
            auth: ExNylas.generate_auth(conn, unquote(header_type)),
            headers: API.base_headers(),
            params: Map.put(params, :limit, 1),
            decode_body: false
          )
          |> Req.request(conn.options)
          |> API.handle_response(apply(unquote(struct_name), :as_list, []))

        case res do
          {:ok, val} -> {:ok, %{val | data: Enum.at(val.data, 0)}}
          val -> val
        end
      end

      @doc """
      Get the first #{unquote(readable_name)}.

      ## Examples

          iex> result = #{__MODULE__}.first!(conn, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: method, name: name} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) when name in [:find, :delete] and method in [:get, :delete] do
    quote do
      @doc """
      #{unquote(config.name) |> to_string |> String.capitalize()} a(n) #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{__MODULE__}.#{unquote(config.name)}(conn, id, params)
      """
      def unquote(config.name)(%Conn{} = conn, id, params \\ %{}) do
        Req.new(
          method: unquote(method),
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)) <> "/#{id}",
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(),
          params: params,
          decode_body: false
        )
        |> Req.request(conn.options)
        |> API.handle_response(apply(unquote(struct_name), :as_struct, []))
      end

      @doc """
      #{unquote(config.name) |> to_string |> String.capitalize()} a(n) #{unquote(readable_name)}.

      ## Examples

          iex> result = #{__MODULE__}.#{unquote(config.name)}!(conn, id, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, id, params \\ %{}) do
        case unquote(config.name)(conn, id, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :get} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Fetch #{unquote(readable_name)}(s), optionally provide query params.

      ## Examples

          iex> {:ok, result} = #{__MODULE__}.#{unquote(config.name)}(conn, params)
      """
      def unquote(config.name)(%Conn{} = conn, params \\ %{}) do
        Req.new(
          method: :get,
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)),
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(),
          params: params,
          decode_body: false
        )
        |> Req.request(conn.options)
        |> API.handle_response(apply(unquote(struct_name), :as_list, []))
      end

      @doc """
      Fetch #{unquote(readable_name)}(s), optionally provide query params.

      ## Examples

          iex> result = #{__MODULE__}.#{unquote(config.name)}!(conn, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, params \\ %{}) do
        case unquote(config.name)(conn, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :patch} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Update a(n) #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{__MODULE__}.#{unquote(config.name)}(conn, id, body, params)
      """
      def unquote(config.name)(%Conn{} = conn, id, changeset, params \\ %{}) do
        Req.new(
          method: :patch,
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)) <> "/#{id}",
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(["content-type": "application/json"]),
          body: API.process_request_body(changeset),
          decode_body: false,
          params: params
        )
        |> Req.request(conn.options)
        |> API.handle_response(apply(unquote(struct_name), :as_struct, []))
      end

      @doc """
      Update a(n) #{unquote(readable_name)}.

      ## Examples

          iex> result = #{__MODULE__}.#{unquote(config.name)}!(conn, id, body, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, id, changeset, params \\ %{}) do
        case unquote(config.name)(conn, id, changeset, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  defp generate_api(%{http_method: :post} = config, object, struct_name, readable_name, header_type, use_admin_url, _use_cursor_paging) do
    quote do
      @doc """
      Create a(n) #{unquote(readable_name)}.

      ## Examples

          iex> {:ok, result} = #{__MODULE__}.#{unquote(config.name)}(conn, body, params)
      """
      def unquote(config.name)(%Conn{} = conn, body, params \\ %{}) do
        Req.new(
          method: :post,
          url: ExNylas.generate_url(conn, unquote(use_admin_url), unquote(object)),
          auth: ExNylas.generate_auth(conn, unquote(header_type)),
          headers: API.base_headers(["content-type": "application/json"]),
          body: API.process_request_body(body),
          decode_body: false,
          params: params
        )
        |> Req.request(conn.options)
        |> API.handle_response(apply(unquote(struct_name), :as_struct, []))
      end

      @doc """
      Create a(n) #{unquote(readable_name)}.

      ## Examples

          iex> result = #{__MODULE__}.#{unquote(config.name)}(conn, body, params)
      """
      def unquote("#{config.name}!" |> String.to_atom())(%Conn{} = conn, body, params \\ %{}) do
        case unquote(config.name)(conn, body, params) do
          {:ok, body} -> body
          {:error, reason} -> raise ExNylasError, reason
        end
      end
    end
  end

  def generate_url(conn, true = _use_admin_url, object) do
    "#{conn.api_server}/v3/#{object}"
  end

  def generate_url(conn, false = _use_admin_url, object) do
    "#{conn.api_server}/v3/grants/#{conn.grant_id}/#{object}"
  end

  def generate_auth(conn, :header_bearer) do
    API.auth_bearer(conn)
  end

  def generate_auth(conn, :header_basic) do
    API.auth_basic(conn)
  end

  defmacro __using__(opts) do
    quote do
      unquote(generate_funcs(opts))
    end
  end
end
