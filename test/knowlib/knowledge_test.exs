defmodule Knowlib.KnowledgeTest do
  use Knowlib.DataCase

  alias Knowlib.Knowledge

  describe "blocks" do
    alias Knowlib.Knowledge.Block

    import Knowlib.KnowledgeFixtures

    @invalid_attrs %{name: nil, description: nil, icon: nil}

    test "list_blocks/0 returns all blocks" do
      block = block_fixture()
      assert Knowledge.list_blocks() == [block]
    end

    test "get_block!/1 returns the block with given id" do
      block = block_fixture()
      assert Knowledge.get_block!(block.id) == block
    end

    test "create_block/1 with valid data creates a block" do
      valid_attrs = %{name: "some name", description: "some description", icon: "some icon"}

      assert {:ok, %Block{} = block} = Knowledge.create_block(valid_attrs)
      assert block.name == "some name"
      assert block.description == "some description"
      assert block.icon == "some icon"
    end

    test "create_block/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_block(@invalid_attrs)
    end

    test "update_block/2 with valid data updates the block" do
      block = block_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", icon: "some updated icon"}

      assert {:ok, %Block{} = block} = Knowledge.update_block(block, update_attrs)
      assert block.name == "some updated name"
      assert block.description == "some updated description"
      assert block.icon == "some updated icon"
    end

    test "update_block/2 with invalid data returns error changeset" do
      block = block_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_block(block, @invalid_attrs)
      assert block == Knowledge.get_block!(block.id)
    end

    test "delete_block/1 deletes the block" do
      block = block_fixture()
      assert {:ok, %Block{}} = Knowledge.delete_block(block)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_block!(block.id) end
    end

    test "change_block/1 returns a block changeset" do
      block = block_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_block(block)
    end
  end

  describe "pages" do
    alias Knowlib.Knowledge.Page

    import Knowlib.KnowledgeFixtures

    @invalid_attrs %{title: nil, text: nil, order: nil}

    test "list_pages/0 returns all pages" do
      page = page_fixture()
      assert Knowledge.list_pages() == [page]
    end

    test "get_page!/1 returns the page with given id" do
      page = page_fixture()
      assert Knowledge.get_page!(page.id) == page
    end

    test "create_page/1 with valid data creates a page" do
      valid_attrs = %{title: "some title", text: "some text", order: 42}

      assert {:ok, %Page{} = page} = Knowledge.create_page(valid_attrs)
      assert page.title == "some title"
      assert page.text == "some text"
      assert page.order == 42
    end

    test "create_page/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Knowledge.create_page(@invalid_attrs)
    end

    test "update_page/2 with valid data updates the page" do
      page = page_fixture()
      update_attrs = %{title: "some updated title", text: "some updated text", order: 43}

      assert {:ok, %Page{} = page} = Knowledge.update_page(page, update_attrs)
      assert page.title == "some updated title"
      assert page.text == "some updated text"
      assert page.order == 43
    end

    test "update_page/2 with invalid data returns error changeset" do
      page = page_fixture()
      assert {:error, %Ecto.Changeset{}} = Knowledge.update_page(page, @invalid_attrs)
      assert page == Knowledge.get_page!(page.id)
    end

    test "delete_page/1 deletes the page" do
      page = page_fixture()
      assert {:ok, %Page{}} = Knowledge.delete_page(page)
      assert_raise Ecto.NoResultsError, fn -> Knowledge.get_page!(page.id) end
    end

    test "change_page/1 returns a page changeset" do
      page = page_fixture()
      assert %Ecto.Changeset{} = Knowledge.change_page(page)
    end
  end
end
