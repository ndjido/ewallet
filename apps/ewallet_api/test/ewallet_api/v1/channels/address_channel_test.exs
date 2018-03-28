defmodule EWalletAPI.V1.AddressChannelTest do
  use EWalletAPI.ChannelCase
  alias EWalletAPI.V1.AddressChannel

  describe "join/3" do
    test "joins the channel" do
      {res, _, socket} =
        socket()
        |> subscribe_and_join(AddressChannel, "address:123")

      assert res == :ok
      assert socket.topic == "address:123"
    end
  end
end