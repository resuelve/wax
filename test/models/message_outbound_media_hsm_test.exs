defmodule Whatsapp.Models.MessageOutboundMediaHsmTest do
  use ExUnit.Case

  alias Whatsapp.Models.MessageOutboundMediaHsm

  @document_parameter %{
    type: "document",
    document: %{
      id: "media_id",
      filename: "mi_archivo.pdf"
    }
  }

  @image_parameter %{type: "image", image: %{id: "media_id"}}

  @text_parameter %{type: "text", text: "replacement_text"}

  @video_parameter %{type: "video", video: %{id: "media_id", caption: "mi_video.mp4"}}

  test "Creates a payload" do
    args = [
      to: "15162837151",
      namespace: "resuelve:fintech",
      element_name: "welcome",
      language_code: "es",
      file_name: "mi_archivo.pdf",
      data: "data:text/plain;base64,SGVsbG8gd29ybGQh",
      type: "document",
      params: [%{"text" => "replacement_text"}]
    ]

    message =
      MessageOutboundMediaHsm.new(args)
      |> MessageOutboundMediaHsm.set_media_id("media_id")

    parsed_response = MessageOutboundMediaHsm.to_json(message)

    [
      %{
        type: "header",
        parameters: header
      },
      %{
        type: "body",
        parameters: body
      }
    ] = parsed_response.template.components

    assert length(header) == 1
    assert header == [@document_parameter]
    assert length(body) == 1
    assert body == [@text_parameter]
  end

  describe "Formatting parameters" do
    test "Formats a text parameter" do
      parameter = [%{"text" => "replacement_text"}]
      formatted = MessageOutboundMediaHsm._format_params(parameter)
      assert formatted == [@text_parameter]
    end

    test "Formats a simple text parameter" do
      parameter = ["replacement_text"]
      formatted = MessageOutboundMediaHsm._format_params(parameter)
      assert formatted == [@text_parameter]
    end

    test "Formats a document parameter" do
      parameter = [%{"document" => "media_id", "caption" => "mi_archivo.pdf"}]
      formatted = MessageOutboundMediaHsm._format_params(parameter)
      assert formatted == [@document_parameter]
    end

    test "Formats a video parameter" do
      parameter = [%{"video" => "media_id", "caption" => "mi_video.mp4"}]
      formatted = MessageOutboundMediaHsm._format_params(parameter)
      assert formatted == [@video_parameter]
    end

    test "Formats a image parameter" do
      parameter = [%{"image" => "media_id"}]
      formatted = MessageOutboundMediaHsm._format_params(parameter)
      assert formatted == [@image_parameter]
    end

    test "Formats multiple parameters" do
      parameter = [
        %{"document" => "media_id", "caption" => "mi_archivo.pdf"},
        %{"video" => "media_id", "caption" => "mi_video.mp4"}
      ]

      formatted = MessageOutboundMediaHsm._format_params(parameter)
      assert formatted == [@document_parameter, @video_parameter]
    end

    test "Returns an error when creating an invalid parameter" do
      parameter = [%{memes: "lmao"}]

      assert_raise FunctionClauseError, fn ->
        MessageOutboundMediaHsm._format_params(parameter)
      end
    end
  end
end
