defmodule Rumbl.Auth do

  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  alias Rumbl.Router.Helpers
  alias Rumbl.User

  def init(opts) do
    Keyword.fetch!(opts, :repo) #exception if key does not exist
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id) #is :user_id in session?
    user = user_id && repo.get(User, user_id) #look up user, assign the result in connection
    assign(conn, :current_user, user) #assign result (could be nil) to conn.assigns
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn #if there is a current user, return conn unchanged
    else
      conn
      |> put_flash(:error, "You must be logged int to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt() #stop any downstream transformations
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user) #store the current user in the :current_user assign
    |> put_session(:user_id, user.id) #put the user id in the session
    |> configure_session(renew: true) #configure the session. send the session cookie back to the client with a different identifier
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo) #fetch repo from give opts
    user = repo.get_by(User, username: username) #lookup user by username

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)} #found matching user. login()
      user ->
        {:error, :unauthorized, conn} #user exists. password does not match
      true -> #any other case. simulate a password check with variable timing. This hardens our authentication layer against timing attacks
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

end
