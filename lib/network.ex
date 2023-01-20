defmodule Dpi.App.Network do
  @node :dpi@localhost

  def get_by_prefix(filter) do
    :rpc.call(@node, VintageNet, :get_by_prefix, [filter])
  end

  def configure(nic, config) do
    :rpc.call(@node, VintageNet, :configure, [nic, config])
  end

  def deconfigure(nic) do
    :rpc.call(@node, VintageNet, :deconfigure, [nic])
  end

  def subnet_mask_to_prefix_length(netmask) do
    {:ok, netmask} = netmask |> String.to_charlist() |> :inet.parse_address()

    {:ok, prefix_length} =
      :rpc.call(@node, VintageNet.IP, :subnet_mask_to_prefix_length, [netmask])

    prefix_length
  end

  def get_mac(nic) do
    case get_by_prefix(["interface", nic, "mac_address"]) do
      [{["interface", ^nic, "mac_address"], value}] -> value
      _ -> ""
    end
  end

  def get_address_netmask(nic) do
    list =
      case(get_by_prefix(["interface", nic, "addresses"])) do
        [] -> []
        [{["interface", ^nic, "addresses"], list}] -> list
      end

    Enum.find_value(list, "", fn m ->
      %{family: f, address: ip, netmask: nm} = m

      case f do
        :inet -> "#{ips(ip)}/#{ips(nm)}"
        _ -> false
      end
    end)
  end

  def same_segment?(netmask, address, gateway) do
    {:ok, {n0, n1, n2, n3}} = :inet.parse_address(String.to_charlist(netmask))
    {:ok, {a0, a1, a2, a3}} = :inet.parse_address(String.to_charlist(address))
    {:ok, {g0, g1, g2, g3}} = :inet.parse_address(String.to_charlist(gateway))
    as = {Bitwise.band(n0, a0), Bitwise.band(n1, a1), Bitwise.band(n2, a2), Bitwise.band(n3, a3)}
    gs = {Bitwise.band(n0, g0), Bitwise.band(n1, g1), Bitwise.band(n2, g2), Bitwise.band(n3, g3)}
    as == gs
  end

  def valid_ip?(text) do
    case String.split(text, ".") do
      [_, _, _, _] = list -> Enum.all?(list, &byte?/1)
      _ -> false
    end
  end

  def byte?(text) do
    case Integer.parse(text) do
      {val, ""} -> val in 0..255
      _ -> false
    end
  end

  def ips({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
end
