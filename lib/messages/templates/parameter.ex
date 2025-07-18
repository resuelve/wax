defmodule Wax.Messages.Templates.Parameter do
  @moduledoc """
  Template parameter struct

  TODO: Support for currency and date time parameters
  """

  alias Wax.Messages.Media

  @typep parameter_type :: :document | :image | :text | :video
  @type t :: %__MODULE__{
          type: parameter_type(),
          text: String.t(),
          image: Media.t(),
          document: Media.t(),
          video: Media.t()
        }

  @derive {Jason.Encoder, only: [:type, :text, :image, :document, :video]}
  defstruct [
    :type,
    :text,
    :image,
    :document,
    :video
  ]

  @doc """
  Converts a keyword list of params to a list of structs
  """
  @spec parse(Keyword.t()) :: [__MODULE__.t()]
  def parse([_ | _] = params) do
    Enum.reduce_while(params, [], fn param, acc ->
      case parse(param) do
        %__MODULE__{} = parsed_param ->
          {:cont, [parsed_param | acc]}

        {:invalid_param, invalid_param} ->
          {:halt, {:error, "Invalid param: #{inspect(invalid_param)}"}}
      end
    end)
  end

  def parse({:text, text}) when is_binary(text) do
    %__MODULE__{type: :text, text: text}
  end

  def parse({:image, %Media{} = image}) do
    %__MODULE__{type: :image, image: image}
  end

  def parse({:document, %Media{} = image}) do
    %__MODULE__{type: :document, image: image}
  end

  def parse({:video, %Media{} = image}) do
    %__MODULE__{type: :video, image: image}
  end

  def parse(param) do
    {:invalid_param, param}
  end
end
