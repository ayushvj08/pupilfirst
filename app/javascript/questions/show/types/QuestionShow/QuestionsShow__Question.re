type t = {
  id: string,
  title: string,
  description: string,
  creatorId: string,
  editorId: option(string),
  createdAt: string,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    title: json |> field("title", string),
    description: json |> field("description", string),
    creatorId: json |> field("creatorId", string),
    editorId:
      json |> field("editorId", nullable(string)) |> Js.Null.toOption,
    createdAt: json |> field("createdAt", string),
  };

let id = t => t.id;

let description = t => t.description;

let title = t => t.title;

let creatorId = t => t.creatorId;

let editorId = t => t.editorId;

let createdAt = t => t.createdAt;

let create = (id, title, description, creatorId, editorId, createdAt) => {
  id,
  title,
  description,
  creatorId,
  editorId,
  createdAt,
};