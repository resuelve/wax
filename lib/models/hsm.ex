defmodule Qbox.Whatsapp.HSM do
  @moduledoc """
  Estructura del mensaje HSM de Whatsapp
  """

  require Logger

  alias Qbox.Services.Google.Datastore

  @datastore_kind "whatsapp-hsm"

  @valid_language_policies ["deterministic", "fallback"]

  @default_language_policy "deterministic"

  @enforce_keys [:element_name, :language_code]

  defstruct namespace: "whatsapp:hsm:finance:resuelve",
            element_name: nil,
            language_code: nil,
            language_policy: @default_language_policy,
            params: []

  @type t :: %__MODULE__{}

  @doc """
  Crea un nuevo HSM
  """
  @spec new(String.t(), String.t(), list) :: __MODULE__.t()
  def new(element_name, language, params) do
    %__MODULE__{
      element_name: element_name,
      language_code: language,
      params: params
    }
  end

  @doc """
  Convierte una estructura HSM a JSON
  """
  @spec to_json(__MODULE__.t()) :: map
  def to_json(%__MODULE__{} = hsm) do
    %{
      namespace: hsm.namespace,
      element_name: hsm.element_name,
      language: %{
        policy: validate_policy(hsm.language_policy),
        code: hsm.language_code
      },
      localizable_params: format_params(hsm.params)
    }
  end

  # Valida que el tipo de selección de lenguaje sea válido
  @spec validate_policy(any()) :: String.t()
  defp validate_policy(language_policy)
       when language_policy in @valid_language_policies do
    language_policy
  end

  defp validate_policy(_language_policy) do
    @default_language_policy
  end

  # Formatea la lista de parametros como parametros default para el HSM
  @spec format_params([String.t()]) :: [map]
  defp format_params(params) do
    Enum.map(params, fn param -> %{default: param} end)
  end

  @doc """
  Lista los HSM guardados en el Datastore
  """
  @spec list_hsm(map) :: list
  def list_hsm(params) do
    base_query = "SELECT * FROM `#{@datastore_kind}`"

    {where, datastore_params} =
      {[], %{}}
      |> _add_param(params, "category")
      |> _add_param(params, "language")
      |> _add_param(params, "name")

    query =
      case Enum.join(where, " AND ") do
        "" ->
          base_query

        where ->
          base_query <> " WHERE " <> where
      end

    _list_hsm(query, datastore_params)
  end

  # Agrega parametros no nulos a los parámetros de la búsqueda del Datastore
  @spec _add_param(map, map, any()) :: map
  defp _add_param({where, datastore_params}, params, key) do
    case Map.get(params, key) do
      value when value in [nil, ""] ->
        {where, datastore_params}

      value ->
        {["#{key} = @#{key}" | where], Map.put(datastore_params, key, value)}
    end
  end

  # Ejecuta el query para obtener los HSM en el Datastore
  @spec _list_hsm(String.t(), map) :: list
  defp _list_hsm(query, params) do
    case Datastore.get(query, params) do
      entities when is_list(entities) ->
        entities
        |> Enum.map(&Datastore.get_properties/1)
        |> Enum.map(&_extract_hsm_params/1)

      _ ->
        []
    end
  end

  # Extrae los parámetros del mensaje del HSM y genera una lista con ellos
  @spec _extract_hsm_params(map) :: map
  defp _extract_hsm_params(%{"message" => message} = hsm) do
    # Regex para obtener los parámetros del HSM que
    # se encuentran especificados de la manera {{parametro}}
    case Regex.scan(~r/{{([^}]+)}}/, message) do
      [] ->
        _extract_hsm_params(hsm)

      params ->
        params = Enum.map(params, fn [_, param] -> param end)
        Map.put(hsm, "params", params)
    end
  end

  defp _extract_hsm_params(hsm) do
    Map.put(hsm, "params", [])
  end
end
