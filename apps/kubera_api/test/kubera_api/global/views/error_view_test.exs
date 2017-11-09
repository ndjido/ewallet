defmodule KuberaAPI.ErrorViewTest do
  use KuberaAPI.ViewCase, :v1
  alias KuberaAPI.ErrorView

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  describe "KuberaAPI.ErrorView" do
    test "renders 500.json when given a custom description" do
      assigns = %{
        reason: %{
          message: "Custom assigned error description"
        }
      }

      expected = %{
        version: "1",
        success: false,
        data: %{
          "object" => "error",
          "code" => "server:internal_server_error",
          "description" => "Custom assigned error description",
          "messages" => nil
        }
      }

      assert render(ErrorView, "500.json", assigns) == expected
    end

    test "renders invalid template as server error" do
      expected = %{
        version: "1",
        success: false,
        data: %{
          "object" => "error",
          "code" => "server:internal_server_error",
          "description" => "Something went wrong on the server",
          "messages" => nil
        }
      }

      assert render(ErrorView, "invalid_template.json", []) == expected
    end
  end
end