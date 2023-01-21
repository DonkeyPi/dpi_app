defmodule Dpi.App.Recovery do
  alias Dpi.App.Nerves
  @keys "/data/keys"

  def list(), do: list(Nerves.on())
  def list(false), do: []

  def list(true) do
    File.mkdir_p!(@keys)
    pattern = "#{@keys}/#{Nerves.boardid()}-*.pub"
    Path.wildcard(pattern) |> Enum.map(&Path.basename/1)
  end

  def generate(comment) do
    {:RSAPrivateKey, _, modulus, publicExponent, _, _, _, _exponent1, _, _, _otherPrimeInfos} =
      rsa_private_key = :public_key.generate_key({:rsa, 4096, 65537})

    pem_entry = :public_key.pem_entry_encode(:RSAPrivateKey, rsa_private_key)
    private_key = :public_key.pem_encode([pem_entry])

    rsa_public_key = {:RSAPublicKey, modulus, publicExponent}
    public_key = :ssh_file.encode([{rsa_public_key, [{:comment, comment}]}], :openssh_key)

    {private_key, public_key}
  end
end
