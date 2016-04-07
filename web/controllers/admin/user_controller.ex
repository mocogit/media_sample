defmodule MediaSample.Admin.UserController do
  use MediaSample.Web, :admin_controller
  use MediaSample.LocalizedController
  alias MediaSample.{UserService, User}

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params, locale) do
    users = User |> User.preload_all(locale) |> Repo.slave.all
    render(conn, "index.html", users: users)
  end

  def new(conn, _params, locale) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}, locale) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.transaction(UserService.insert(changeset, user_params, locale)) do
      {:ok, %{user: user, upload: _file}} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: admin_user_path(conn, :show, locale, user)) |> halt
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        conn
        |> put_flash(:error, "User create failed")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, locale) do
    user = User |> User.preload_all(locale) |> Repo.slave.get!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}, locale) do
    user = User |> User.preload_all(locale) |> Repo.slave.get!(id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}, locale) do
    user = User |> User.preload_all(locale) |> Repo.slave.get!(id)
    changeset = User.changeset(user, user_params)

    case Repo.transaction(UserService.update(changeset, user_params, locale)) do
      {:ok, %{user: user, upload: _file}} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: admin_user_path(conn, :show, locale, user)) |> halt
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        conn
        |> put_flash(:error, "User update failed")
        |> render("edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, locale) do
    user = Repo.slave.get!(User, id)

    case Repo.transaction(UserService.delete(user)) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: admin_user_path(conn, :index, locale)) |> halt
      {:error, _failed_operation, _failed_value, _changes_so_far} ->
        conn
        |> put_flash(:error, "User delete failed")
        |> redirect(to: admin_user_path(conn, :index, locale)) |> halt
    end
  end
end
