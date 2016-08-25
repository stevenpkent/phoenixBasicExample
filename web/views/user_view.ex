defmodule Rumbl.UserView do
  use Rumbl.Web, :view
  alias Rumbl.User

  #parse a user’s first name from that user’s name field
  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
