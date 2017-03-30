defmodule RouterTest do
  use ExUnit.Case

  defmodule SimpleResourceRouter do
    use Zeus.DSL.Router

    resource_route :GET, "/test", :test, :some_action
  end

  test "simple resource_route can be looked up" do
    {:test, :some_action, [], []} = SimpleResourceRouter.lookup(:GET, ["test"])
  end

  defmodule LongPathResourceRouter do
    use Zeus.DSL.Router

    resource_route :GET, "/some/really/long/nested/path", :test, :some_action
  end

  test "long resource_route can be looked up" do
    lookup_path = ["some", "really", "long", "nested", "path"]
    {:test, :some_action, [], []} = LongPathResourceRouter.lookup(:GET, lookup_path)
  end

  defmodule SimpleMatchingResourceRouter do
    use Zeus.DSL.Router

    resource_route :GET, "/test/*", :test, :some_action, :id
  end

  test "simple matching resource_route can be looked up" do
    {:test, :some_action, _, _} = SimpleMatchingResourceRouter.lookup(:GET, ["test", "1"])
  end

  test "simple matching resource_route matches correctly" do
    {:test, :some_action, [:id], ["1"]} = SimpleMatchingResourceRouter.lookup(:GET, ["test", "1"])
  end

  # defmodule MultiMatchingResourceRouter do
  #   use Zeus.DSL.Router

  #   resource_route :GET, "/test/*/abc/*", :test, :some_action, 
  # end

  defmodule FullRestResourceRouter do
    use Zeus.DSL.Router

    full_rest_resource "/test", test: :some_arg
  end

  test "full_rest_resource creates all rest routes" do
    {:test, :index, [], []} = FullRestResourceRouter.lookup(:GET, ["test"])
    {:test, :create, [], []} = FullRestResourceRouter.lookup(:POST, ["test"])
    {:test, :show, [:some_arg], ["1"]} = FullRestResourceRouter.lookup(:GET, ["test", "1"])
    {:test, :update, [:some_arg], ["1"]} = FullRestResourceRouter.lookup(:PUT, ["test", "1"])
    {:test, :destroy, [:some_arg], ["1"]} = FullRestResourceRouter.lookup(:DELETE, ["test", "1"])
  end

  defmodule ShorthandFullRestResourceRouter do
    use Zeus.DSL.Router

    full_rest_resource "/test", :test
  end

  test "shorthand full_rest_resource defaults argument to id" do
    {:test, :index, [], []} = ShorthandFullRestResourceRouter.lookup(:GET, ["test"])
    {:test, :create, [], []} = ShorthandFullRestResourceRouter.lookup(:POST, ["test"])
    {:test, :show, [:id], ["1"]} = ShorthandFullRestResourceRouter.lookup(:GET, ["test", "1"])
    {:test, :update, [:id], ["1"]} = ShorthandFullRestResourceRouter.lookup(:PUT, ["test", "1"])
    {:test, :destroy, [:id], ["1"]} = ShorthandFullRestResourceRouter.lookup(:DELETE, ["test", "1"])
  end

  # TODO: conflict resolution tests
end
