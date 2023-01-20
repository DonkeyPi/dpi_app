defmodule Dpi.App.Signature do
  def sha1(data) do
    :crypto.hash(:sha, data) |> Base.encode16() |> String.downcase()
  end

  def signature(app_name) do
    path =
      :code.priv_dir(app_name)
      |> Path.join("signature.txt")

    if File.exists?(path), do: File.read!(path), else: ""
  end

  def load_pubkey() do
    # works with openssl keys but not with ssh-keygen keys
    pubsha1 = "5d25262e82f9d14500868ac2b9f8c8df7058782c"
    path = Path.join(:code.priv_dir(:dpi_app), "donkeypi.pub")
    pubkey = File.read!(path)
    ^pubsha1 = sha1(pubkey)
    [pubkey] = :public_key.pem_decode(pubkey)
    :public_key.pem_entry_decode(pubkey)
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
