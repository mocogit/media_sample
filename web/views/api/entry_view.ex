defmodule MediaSample.API.EntryView do
  use MediaSample.Web, :view
  alias MediaSample.{Enums.Status, EntryImageUploader}

  def render("show.json", %{entry: entry}) do
    %{
      entry: render_one(entry, __MODULE__, "entry.json")
    }
  end

  def render("entry.json", %{entry: entry}) do
    %{
      id: entry.id,
      title: entry.title,
      content: entry.content,
      image: EntryImageUploader.url({entry.image, entry}, :medium),
      status: Status.get(entry.status).text
    }
  end
end
