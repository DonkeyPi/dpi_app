defmodule Dpi.App.Recovery do
  alias Dpi.App.UsbDisk
  alias Dpi.App.Nerves
  alias Dpi.App.Time
  @keys "/data/keys"

  def root(), do: @keys
  def join(path), do: Path.join(root(), path)

  def list(), do: list(Nerves.on())
  def list(false), do: []

  def list(true) do
    File.mkdir_p!(@keys)
    pattern = "#{@keys}/#{Nerves.boardid()}-*.pub"
    Path.wildcard(pattern) |> Enum.map(&Path.basename/1)
  end

  # up to millis
  def timestamp() do
    Time.get_time()
    |> DateTime.to_iso8601()
    |> String.replace("-", "")
    |> String.replace(" ", "")
    |> String.replace(":", "")
    |> String.replace(".", "")
    |> String.slice(0..17)
  end

  def generate(disk) do
    timestamp = timestamp()
    boardid = Nerves.boardid()
    filename = "#{boardid}-#{timestamp}"
    {priv, pub} = generate_pair(filename)

    # catch disk removal first
    disk
    |> Path.join("#{filename}.key")
    |> UsbDisk.join()
    |> File.write!(priv)

    # pub last
    "#{filename}.pub"
    |> join()
    |> File.write!(pub)

    Nerves.add_pubkey(pub)
    Nerves.sync!()
  end

  def rm(file), do: file |> join() |> File.rm()
  def read!(file), do: file |> join() |> File.read!()

  def remove_key(file) do
    file |> read!() |> Nerves.remove_pubkey()
    file |> rm()
    Nerves.sync!()
  end

  # Tool.cat "/data/nerves_ssh/default_user/authorized_keys"
  # File.rm "/data/nerves_ssh/default_user/authorized_keys"
  def remove_all_keys() do
    Nerves.rm_authorized()

    for file <- list() do
      file |> remove_key()
    end

    Nerves.remove_pubkey("")
    Nerves.sync!()
  end

  def generate_pair(timestamp) do
    {:RSAPrivateKey, _, modulus, publicExponent, _, _, _, _exponent1, _, _, _otherPrimeInfos} =
      rsa_private_key = :public_key.generate_key({:rsa, 4096, 65537})

    pem_entry = :public_key.pem_entry_encode(:RSAPrivateKey, rsa_private_key)
    private_key = :public_key.pem_encode([pem_entry])

    rsa_public_key = {:RSAPublicKey, modulus, publicExponent}
    public_key = :ssh_file.encode([{rsa_public_key, [{:comment, timestamp}]}], :openssh_key)

    {private_key, public_key |> String.trim()}
  end
end
