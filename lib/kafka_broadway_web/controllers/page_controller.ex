defmodule KafkaBroadwayWeb.PageController do
  use KafkaBroadwayWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
