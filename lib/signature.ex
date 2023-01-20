defmodule Dpi.App.Signature do
  def sha1(data) do
    :crypto.hash(:sha, data) |> Base.encode16() |> String.downcase()
  end

  def signature(app_name) do
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
    ^pubsha1 = sha1(pubkey)
    [{rsa_public_key, _}] = :ssh_file.decode(pubkey, :openssh_key)
    rsa_public_key
  end

  def verify(boardid, appname, pubkey) do
    msg = "#{boardid}:#{appname}"
    signature = signature(appname) |> Base.decode64!()
    :public_key.verify(msg, :sha512, signature, pubkey)
  end

  def signed(appname) do
    verify(boardid(), appname, load_pubkey())
  end

  def boardid() do
    if Dpi.App.in_nerves() do
      {boardid, 0} = System.cmd("boardid", ["-b", "rpi", "-n", "8"])
      "dpi-#{boardid |> String.trim()}"
    else
      {:ok, hostname} = :inet.gethostname()
      hostname
    end
  end
end
