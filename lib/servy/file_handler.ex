defmodule Servy.FileHandler do
  require Logger

  def handle_file({:ok, content}, conv) do
    %{conv | resp_body: content, status: 200}
  end

  def handle_file({:error, :enoent}, conv) do
    %{conv | resp_body: "Oops, something is missing here", status: 404}
  end

  def handle_file({:error, reason}, conv) do
    Logger.error(IO.iodata_to_binary(reason))
    %{conv | resp_body: "Oops, somethings seems to be broken...", status: 500}
  end
end
