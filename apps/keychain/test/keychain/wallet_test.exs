# Copyright 2019 OmiseGO Pte Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule Keychain.WalletTest do
  use Keychain.DBCase
  import Keychain.Factory
  alias Ecto.UUID
  alias Keychain.{Key, Repo, Wallet}

  describe "generate/0" do
    test "generates and inserts a Key record with wallet id" do
      count = Repo.aggregate(Key, :count, :wallet_id)

      {:ok, {wallet_id, public_key}} = Wallet.generate()
      {:ok, {_, _}} = Wallet.generate()
      {:ok, {_, _}} = Wallet.generate()
      {:ok, {_, _}} = Wallet.generate()

      assert Repo.aggregate(Key, :count, :wallet_id) == count + 4

      assert is_binary(wallet_id)
      assert byte_size(wallet_id) == 42

      assert is_binary(public_key)
      assert byte_size(public_key) == 130
    end
  end

  describe "generate_keypair/0" do
    test "returns a tuple of public and private keys" do
      {public_key, private_key} = Wallet.generate_keypair()

      assert <<4::size(8), _::binary-size(64)>> = public_key
      assert <<_::binary-size(32)>> = private_key
    end
  end

  describe "generate_hd/0" do
    test "inserts a Key record and returns the uuid" do
      count = Repo.aggregate(Key, :count, :wallet_id)
      {:ok, uuid} = Wallet.generate_hd()

      assert Repo.aggregate(Key, :count, :wallet_id) == count + 1
      assert byte_size(uuid) == 36
    end
  end

  describe "derive_child_address/3" do
    test "returns the address for the given account_ref and deposit_ref" do
      public_key =
        "xpub6EGmE1yp5TMVqfoZwbQLDvSu411rZejQoGUCqFfuC71XNXN2ddMHxWqFUTtQEbL3ksL3dgDjqjTcFxFkuZ3mecaNdjvqYNWQbq3EoQCeuT5"

      key = insert(:hd_key, public_key: public_key)
      address = Wallet.derive_child_address(key.uuid, 0, 0)

      assert address == "0x42bbec7435986ad45d921d64fd130afd046f8d48"
    end

    test "returns :invalid_uuid error if the given uuid could not be found" do
      assert Wallet.derive_child_address(UUID.generate(), 0, 0) == {:error, :invalid_uuid}
    end
  end
end