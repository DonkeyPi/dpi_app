defmodule Dpi.App.Signature do
  alias Dpi.App.Nerves
  alias Dpi.App.Crypto

  def load_signature(app_name) do
    path =
      :code.priv_dir(app_name)
      |> Path.join("signature")

    if File.exists?(path), do: File.read!(path), else: ""
  end

  def load_pubkey() do
    # updated to work with dpi.keygen pub key (and ssh-keygen)
    pubsha1 = "ece37bf7ba62f4b92c1bfd728b32a76aeeb934af"
    path = Path.join(:code.priv_dir(:dpi_app), "donkeypi.pub")
    pubkey = File.read!(path) |> String.trim()
    ^pubsha1 = Crypto.sha1(pubkey)
    [{rsa_public_key, _}] = :ssh_file.decode(pubkey, :openssh_key)
    rsa_public_key
  end

  def verify(boardid, appname, pubkey) do
    msg = "#{boardid}:#{appname}"
    signature = load_signature(appname) |> Base.decode64!()
    :public_key.verify(msg, :sha512, signature, pubkey)
  end

  def signed(appname) do
    verify(Nerves.boardid(), appname, load_pubkey())
  end
end
