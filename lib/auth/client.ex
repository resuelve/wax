defmodule Qbox.Whatsapp.Auth.Client do
  @moduledoc """
  GenServer client para autenticación de Whatsapp
  """

  alias Qbox.Whatsapp.Auth.Server

  @server WhatsappAuthServer

  @doc """
  Inicia el GenServer para manejo de la autenticación de Whatsapp
  """
  @spec start_link :: any()
  def start_link do
    GenServer.start_link(Server, :ok, [name: @server])
  end

  @doc """
  Lista todos los tokens guardados
  """
  @spec list_tokens() :: list
  def list_tokens() do
    GenServer.call(@server, :list)
  end

  @doc """
  Obtiene el token de autenticación del producto dado
  """
  @spec get_token(binary()) :: binary() | nil
  def get_token(product) do
    GenServer.call(@server, {:lookup_token, product})
  end
end
