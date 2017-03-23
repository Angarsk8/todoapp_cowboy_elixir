defmodule TodoApp.CommentHandler do
  use TodoApp.Entity.BaseHandler

  import TodoApp.CommentView, only: [render: 2]
  alias TodoApp.{Comment, Todo}

  # REST Handlers

  def handle_get(req, _state) do
    todo_id = :cowboy_req.binding(:todo_id, req)
    comment_id = :cowboy_req.binding(:comment_id, req)

    query =
      Todo
      |> Repo.get(todo_id)
      |> assoc(:comments)
      |> Repo.get(comment_id)

    case Repo.get(query, comment_id) do
      %Comment{} = comment ->
        req
        |> set_headers(default_headers)
        |> set_body(render(:show, comment: comment))
        |> reply(200)
      nil ->
        req
        |> set_headers(default_headers)
        |> set_body(render(:not_found, []))
        |> reply(404, false)
    end
  end

  def handle_update(req, _state) do
    todo_id = :cowboy_req.binding(:todo_id, req)
    comment_id = :cowboy_req.binding(:comment_id, req)
    {:ok, params, req} = :cowboy_req.read_body(req)
    decoded_params = Poison.decode!(params)

    query =
      Todo
      |> Repo.get(todo_id)
      |> assoc(:comments)

    case Repo.get(query, comment_id) do
      %Comment{} = comment ->
        changeset = Comment.changeset(comment, decoded_params)
        case Repo.update(changeset) do
          {:ok, comment} ->
            req
            |> set_headers(default_headers)
            |> set_body(render(:show, comment: comment))
            |> reply(200)
          {:error, cs} ->
            req
            |> set_headers(default_headers)
            |> set_body(render(:errors, changeset: cs))
            |> reply(422, false)
        end
      nil ->
        req
        |> set_headers(default_headers)
        |> set_body(render(:not_found, []))
        |> reply(404, false)
    end
  end

  def handle_delete(req, _state) do
    todo_id = :cowboy_req.binding(:todo_id, req)
    comment_id = :cowboy_req.binding(:comment_id, req)

    Todo
    |> Repo.get(todo_id)
    |> assoc(:comments)
    |> Repo.get(comment_id)
    |> Repo.delete!

    req
    |> set_headers(default_headers)
    |> set_body(%{ok: true})
    |> reply(200)
  end
end