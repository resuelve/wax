defmodule Wax.Messages.Template do
  @moduledoc """
  Whatsapp Template Message structure and management
  """

  alias Wax.Messages.Templates.{ButtonParameter, Component, Language, Parameter}

  @type t :: %__MODULE__{
          name: String.t(),
          language: Language.t(),
          components: [component()]
        }

  @derive {Jason.Encoder, only: [:name, :language, :components]}
  defstruct [
    :name,
    :language,
    components: []
  ]

  @doc """
  Creates a new Template struct

  Accepts both language and language_locale formats (e.g., en and en_US).
  """
  @spec new(String.t(), String.t()) :: __MODULE__.t()
  def new(name, language_code) do
    %__MODULE__{
      name: name,
      language: Language.new(language_code)
    }
  end

  @doc """
  Adds a header object to the template

  ## Parameters

  These are received as a Keyword list where the key is the parameter type.
  The accepted parameter types are:
  - currency
  - date_time
  - document
  - image
  - text
  -video

  """
  @spec add_header(__MODULE__.t(), Keyword.t()) :: __MODULE__.t()
  def add_header(%__MODULE__{} = template, [_ | _] = params) do
    case Parameter.parse(params) do
      [%Parameter{} | _] = params ->
        header = Component.new_header(params)
        %{template | components: [header | template.components]}

      {:error, error} ->
        # We are raising errors for now until token validation is implemented
        raise error
    end
  end

  @doc """
  Adds a body object to the template

  ## Parameters

  These are received as a Keyword list where the key is the parameter type.
  The accepted parameter types are:
  - currency
  - date_time
  - document
  - image
  - text
  -video

  """
  @spec add_body(__MODULE__.t(), Keyword.t()) :: __MODULE__.t()
  def add_body(%__MODULE__{} = template, [_ | _] = params) do
    case Parameter.parse(params) do
      [%Parameter{} | _] = params ->
        body = Component.new_body(params)
        %{template | components: [body | template.components]}

      {:error, error} ->
        # We are raising errors for now until token validation is implemented
        raise error
    end
  end

  @doc """
  Adds a button object to the template

  ## Parameters

  These are received as a Keyword list where the key is the parameter type.
  The accepted parameter types are:
  - payload
  - text

  """
  @spec add_button(__MODULE__.t(), Keyword.t()) :: __MODULE__.t()
  def add_button(%__MODULE__{} = template, sub_type, index, [_ | _] = params)
      when index in 0..9 do
    with :ok <- Component.validate_button_params(sub_type, params) |> dbg(),
         [%ButtonParameter{} | _] = params = ButtonParameter.parse(params) do
      button = Component.new_button(sub_type, index, params)
      %{template | components: [button | template.components]}
    else
      {:error, error} ->
        raise error
    end
  end
end
