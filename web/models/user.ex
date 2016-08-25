defmodule Rumbl.User do

  use Rumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Rumbl.Video
    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username), []) #parms, required fields, optional fields
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username) #ensure unique username
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do #check if changeset is valid
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} -> #valid
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ -> #invalid, return to caller
        changeset
    end
  end

end
