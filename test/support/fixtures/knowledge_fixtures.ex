defmodule Knowlib.KnowledgeFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Knowlib.Knowledge` context.
  """

  @doc """
  Generate a block.
  """
  def block_fixture(attrs \\ %{}) do
    {:ok, block} =
      attrs
      |> Enum.into(%{
        description: "some description",
        icon: "some icon",
        name: "some name"
      })
      |> Knowlib.Knowledge.create_block()

    block
  end

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        order: 42,
        text: "some text",
        title: "some title"
      })
      |> Knowlib.Knowledge.create_page()

    page
  end
end
